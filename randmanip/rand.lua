max_int = 2^32

local Rand = {}
Rand.__index = Rand

function Rand.new()
    self = setmetatable({}, Rand)
    self:reset()
    return self
end

function Rand:reset()
    self.rand1 = 0xDEADBEEF
    self.rand2 = 0x4191961
    self.element = 0
end

function Rand:next()
    r1 = self.rand1
    r0 = self.rand2
    r0 = r0 << 1
    if r0 >= max_int then
        r0 = r0 - max_int
    end
    r0 = r0 ~ r1
    if r1 & 0x80000000 > 0 then
        r0 = r0 ~ 1
    end
    self.rand1 = r0
    self.rand2 = r1
    self.element = self.element + 1
    -- console:log(string.format('element: %d r0: 0x%08X r1: 0x%08X', self.element, self.rand1, self.rand2))
    return self.rand1
end

function Rand:ram()
    return emu:read32(0x030028FC)
end

function Rand:find_ram()
    target = self:ram()
    loop_count = 0
    while target ~= self.rand1 do
        self:next()
        loop_count = loop_count + 1
        if loop_count > 100000 then
            console:log('Unable to find random value! Maybe you loaded an earlier state? Resetting to 0xDEADBEEF\n')
            self:reset()
            break
        end
    end
end

function frame()
    rand:find_ram()
    buffer:clear()
    buffer:print(string.format('RandRam:  0x%08X\n', rand.ram()))
    buffer:print(string.format('RandCount:  %d\n', rand.element))
end

function reset()
    rand:reset()
end

rand = Rand.new()
buffer = console:createBuffer('info')
callbacks:add('frame', frame)
callbacks:add('reset', reset)