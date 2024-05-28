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
    
    self.address =  emu:read32(0x03000A38)
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

function Scene:save()
    local f = io.open(string.format('./scene_%04X.bin', self.scene_id), 'wb')
    f:write(string.pack('<i', self.scene_id))
    f:write(string.pack('<i', self.width))
    f:write(string.pack('<i', self.height))
    f:write(self.palette)
    f:write(self.tileset)
    f:write(self.tilemap)
    f:write(self.collmap)
    f:close()
    console:log(string.format('Saved ./scene_%04X.bin',self.scene_id))
end


scene = Scene.new()
scene:save()