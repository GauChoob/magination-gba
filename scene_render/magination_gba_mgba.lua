-- mGBA lua script to dump a scene's binary data

function get_background_palette()
    return emu:readRange(0x05000000, 0x200)
end

function get_tileset()
    return emu:readRange(0x06000000, 0x8000)
end

local Scene = {}
Scene.__index = Scene

function Scene.new()
    self = setmetatable({}, Scene)
    
    self.address = emu:read32(0x03000A38)
    if self.address == 0 then
        return self
    end
    self.scene_id = emu:read16(self.address + 0x0C)
    self.scene_data = emu:read32(self.address + 0x38)
    self.width = emu:read32(self.scene_data + 0x08)
    self.height = emu:read32(self.scene_data + 0x0C)
    if self.height > 0x500 or self.width > 0x500 then
        return self
    end
    collmap = emu:read32(self.address + 0x5C)
    self.collmap = emu:readRange(collmap, 2*self.width*self.height)
    tilemap = emu:read32(self.address + 0x60)
    self.tilemap = emu:readRange(tilemap, 2*self.width*self.height)
    self.palette = get_background_palette()
    self.tileset = get_tileset()
    return self
end

function Scene:save(scene_id)
    console:log(string.format('Saving ./scene_%04X.bin', scene_id))
    console:log(string.format('SceneID: 0x%04X, Width: %d, Height: %d', self.scene_id, self.width, self.width))
    local f = io.open(string.format('./scene_%04X.bin', self.scene_id), 'wb')
    f:write(string.pack('<i', self.scene_id))
    f:write(string.pack('<i', self.width))
    f:write(string.pack('<i', self.height))
    f:write(self.palette)
    f:write(self.tileset)
    f:write(self.tilemap)
    f:write(self.collmap)
    f:close()
end

local scene_directories = {
    [0] = true,
    [68] = true,
    [73] = true,
    [129] = true,
    [145] = true,
    [185] = true,
    [219] = true,
    [227] = true,
    [265] = true,
    [271] = true,
    [320] = true,
    [341] = true,
}
local bad_scenes = {
    [0x47] = true, -- instantly loads a different scene
    -- The next 7 scenes don't exist in the scene directory
    [0xC9] = true, -- crash
    [0xF4] = true, -- crash
    [0xF6] = true, -- crash
    [0x156] = true, -- crash
    [0x157] = true, -- crash
    [0x158] = true, -- crash
    [0x159] = true, -- crash
}

function next_scene()
    -- Reset for next scene
    scene_id = scene_id + 1
    while scene_directories[scene_id] or bad_scenes[scene_id] do
        -- skip scene directories as they don't actually contain a scene
        -- skip problematic scenes
        scene_id = scene_id + 1
    end
    emu:loadStateFile('scene_downloader.ss0')
end

function loop()
    ticker = emu:read32(0x030016C0)
    script_list = emu:read32(0x03003508)
    script_scene = emu:read16(0x08186B0E)
    current_scene = emu:read16(emu:read32(0x03000A38) + 0x0C)
    buffer:clear()
    buffer:print(string.format('Ticker: 0x%08X\n', ticker))
    buffer:print(string.format('Target Scene: 0x%04X\n', scene_id))
    buffer:print(string.format('Current Scene: 0x%04X\n', current_scene))
    buffer:print(string.format('Script Scene ID: 0x%04X\n', script_scene))
    buffer:print(string.format('Script Linked List: 0x%04X\n', script_list))
    if scene_id >= scenes then
        return
    end
    if ticker == 0x865 then
        -- First frame of the save file
        emu.memory.cart0:write16(0x186B0E, scene_id)
    elseif (script_list == 0x300350C or ticker >= 0xA00) and scene_id == current_scene then
        -- All scripts are done, dump the scene image
        -- Or we time out after a few seconds because some scripts never end
        scene = Scene.new()
        scene:save(scene_id)
        next_scene()
    elseif ticker >= 0xB00 and scene_id ~= current_scene then
        console:error(string.format('SKIPPING 0x%04X', scene_id))
        next_scene()
    end
end


console:log(string.format('Automatically saving dumps of all scenes'))
buffer = console:createBuffer('info')
scene_id = 0x185
scenes = 398
next_scene()
callbacks:add('frame', loop)


--scene = Scene.new()
--scene:save()