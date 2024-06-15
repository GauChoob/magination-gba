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

function Rand.ram()
    return emu:read32(0x030028FC)
end

function Rand:update()
    target = self.ram()
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


local Awl = {}
Awl.__index = Awl

function Awl.new()
    self = setmetatable({}, Awl)
    self:reset()
    return self
end

function Awl:reset()
    self.last_id = -1
    self.last_scene = -1
end

function Awl:update()
    new_awl = self.ram_id()
    if self.last_id ~= new_awl then
        self.last_scene = scene_id()
        self.last_id = new_awl
    end
end

function Awl:saved()
    self.last_scene = scene_id()
    self.last_id = ram_id()
end

function Awl.ram_id()
    return emu:read32(0x03002EB4)
end

function Awl.ram_can_warp()
    if emu:read8(0x03002B1E) == 0 then
        return 'Yes'
    end
    return 'No'
end


scene_names = {
    [0] = 'null',
    -- Set: Naroom
    [1] = 'Scene_Naroom_Forest_Deep_Intersection',
    [2] = 'Scene_Naroom_Forest_Deep_Pathway',
    [3] = 'Scene_Naroom_Forest_Deep_Connection',
    [4] = 'Scene_Naroom_Forest_Deep_Heart',
    [5] = 'Scene_Naroom_Forest_Deep_Cache',
    [6] = 'Scene_Naroom_Forest_Deep_House',
    [7] = 'Scene_Naroom_Forest_Deep_WenceRoom',
    [8] = 'Scene_Naroom_Geyser_Southeast',
    [9] = 'Scene_Naroom_Geyser_South',
    [10] = 'Scene_Naroom_Geyser_Southwest',
    [11] = 'Scene_Naroom_Geyser_West',
    [12] = 'Scene_Naroom_Geyser_Center',
    [13] = 'Scene_Naroom_Geyser_East',
    [14] = 'Scene_Naroom_Geyser_Northeast',
    [15] = 'Scene_Naroom_Geyser_North',
    [16] = 'Scene_Naroom_Geyser_Northwest',
    [17] = 'Scene_Naroom_Geyser_Doorway',
    [18] = 'Scene_Naroom_Geyser_CoreStone',
    [19] = 'Scene_Naroom_Geyser_Entrance',
    [20] = 'Scene_Naroom_Grove_Pathway',
    [21] = 'Scene_Naroom_Grove_Entrance',
    [22] = 'Scene_Naroom_Vash_Entrance',
    [23] = 'Scene_Naroom_Glade_GuardEntrance',
    [24] = 'Scene_Naroom_Glade_RingRoad',
    [25] = 'Scene_Naroom_Glade_Intersection',
    [26] = 'Scene_Naroom_Glade_Field',
    [27] = 'Scene_Naroom_Glade_Pathway',
    [28] = 'Scene_Naroom_Glade_Geyser',
    [29] = 'Scene_Naroom_Glade_Cave_Exterior',
    [30] = 'Scene_Naroom_Forest_Puzzle',
    [31] = 'Scene_Underneath_Tunnels_Hyren_Forest',
    [32] = 'Scene_Naroom_Seers_House',
    [33] = 'Scene_Naroom_Seers_Room',
    [34] = 'Scene_Naroom_Seers_Pathway',
    [35] = 'Scene_Naroom_Seers_Hyren_UnderwaterEntrance',
    [36] = 'Scene_Naroom_Seers_Hyren_UnderwaterExit',
    [37] = 'Scene_Naroom_Seers_Hyren_SeaCave',
    [38] = 'Scene_Naroom_Grove_River',
    [39] = 'Scene_Naroom_Grove_Cache',
    [40] = 'Scene_Misc_Debug',
    [41] = 'Scene_Naroom_Forest_Exit',
    [42] = 'Scene_Naroom_Forest_Exit_UNUSED1',
    [43] = 'Scene_Naroom_Forest_Exit_UNUSED2',
    [44] = 'Scene_Naroom_Vash_BottomStairs',
    [45] = 'Scene_Naroom_Vash_South',
    [46] = 'Scene_Naroom_Vash_Southwest',
    [47] = 'Scene_Naroom_Vash_Southeast',
    [48] = 'Scene_Naroom_Vash_North',
    [49] = 'Scene_Naroom_Vash_Northwest',
    [50] = 'Scene_Naroom_Vash_TopStairs',
    [51] = 'Scene_Naroom_Vash_Top',
    [52] = 'Scene_Naroom_Vash_Southwest_InnRoom',
    [53] = 'Scene_Naroom_Vash_Southwest_ShopRoom',
    [54] = 'Scene_Naroom_Vash_Southeast_SmithRoom',
    [55] = 'Scene_Naroom_Vash_Northwest_HistorianRoom',
    [56] = 'Scene_Naroom_Vash_Training',
    [57] = 'Scene_Naroom_Vash_Northwest_TrynRoom',
    [58] = 'Scene_Naroom_Vash_Top_OrwinRoom_Entrance',
    [59] = 'Scene_Naroom_Vash_Top_OrwinRoom_Observatory',
    [60] = 'Scene_Naroom_Vash_North_RoomA',
    [61] = 'Scene_Naroom_Vash_North_RoomB',
    [62] = 'Scene_Naroom_Vash_Southeast_Room',
    [63] = 'Scene_Naroom_Vash_North_SpookyRoom_Normal',
    [64] = 'Scene_Naroom_Vash_Sky',
    [65] = 'Scene_Naroom_Vash_Training_Closet',
    [66] = 'Scene_Naroom_Vash_Southeast_CurioRoom',
    [67] = 'Scene_Cald_Archery',
    [340] = 'Scene_Naroom_Vash_South_AgovoRoom',
    [384] = 'Scene_Naroom_Vash_Southwest_PipesRoom_Pathway_West',
    [385] = 'Scene_Naroom_Vash_Southwest_PipesRoom_Back',
    [388] = 'Scene_Naroom_Vash_Southwest_PipesRoom_Pathway_East',
    [395] = 'Scene_Naroom_Vash_North_SpookyRoom_Overgrown',
    -- Set: Tavel Gorge
    [69] = 'Scene_Misc_Tavel_Outside',
    [70] = 'Scene_Misc_Tavel_Entrance',
    [71] = 'Scene_Misc_Tavel_Maze',
    [72] = 'Scene_Misc_Tavel_Crystal',
    -- Set: Underneath
    [74] = 'Scene_Underneath_Mushroom_WestEntrance',
    [75] = 'Scene_Underneath_Mushroom_North',
    [76] = 'Scene_Underneath_Mushroom_East',
    [77] = 'Scene_Underneath_Mushroom_South',
    [78] = 'Scene_Underneath_Mushroom_Center',
    [79] = 'Scene_Underneath_Garage_House',
    [80] = 'Scene_Underneath_Garage_Room',
    [81] = 'Scene_Underneath_Mushroom_East_RescueRoom',
    [82] = 'Scene_Underneath_Mushroom_East_Ormagon',
    [83] = 'Scene_Underneath_Geyser_SouthEntrance',
    [84] = 'Scene_Underneath_Geyser_Southwest',
    [85] = 'Scene_Underneath_Geyser_Altar',
    [86] = 'Scene_Underneath_Geyser_CavedIn',
    [87] = 'Scene_Underneath_Geyser_Northwest',
    [88] = 'Scene_Underneath_Geyser_Northeast',
    [89] = 'Scene_Underneath_Geyser_CulDeSac',
    [90] = 'Scene_Underneath_Geyser_Southeast',
    [91] = 'Scene_Underneath_Geyser_CoreStone',
    [92] = 'Scene_Cald_Vents_Hyren',
    [93] = 'Scene_Underneath_Mushroom_House',
    [94] = 'Scene_Underneath_Mushroom_GrukRoom',
    [95] = 'Scene_Underneath_Bogrom_Normal',
    [96] = 'Scene_Underneath_Bogrom_Destroyed',
    [97] = 'Scene_Underneath_Bogrom_GenericRoom',
    [98] = 'Scene_Underneath_Bogrom_InnRoom',
    [99] = 'Scene_Underneath_Bogrom_HistorianRoom',
    [100] = 'Scene_Underneath_Bogrom_GogorRoom',
    [101] = 'Scene_Underneath_Bogrom_MotashRoom',
    [102] = 'Scene_Underneath_Bogrom_UlkRoom',
    [103] = 'Scene_Underneath_Bogrom_BrubRoom',
    [104] = 'Scene_Underneath_Whackamole',
    [105] = 'Scene_Underneath_Tunnels_Mouth',
    [106] = 'Scene_Underneath_Tunnels_IntersectionHyren',
    [107] = 'Scene_Underneath_Tunnels_StairsHyren',
    [108] = 'Scene_Underneath_Tunnels_PathwayHyrenFortIntersections',
    [109] = 'Scene_Underneath_Tunnels_IntersectionFort',
    [110] = 'Scene_Underneath_Tunnels_PathwayFort',
    [111] = 'Scene_Underneath_Tunnels_PathwayFortLoopIntersections_A',
    [112] = 'Scene_Underneath_Tunnels_PathwayFortLoopIntersections_B_Unused',
    [113] = 'Scene_Underneath_Tunnels_PathwayFortLoopIntersections_C',
    [114] = 'Scene_Underneath_Tunnels_PathwayFortLoopIntersections_D',
    [115] = 'Scene_Underneath_Tunnels_WestCache_Rock',
    [116] = 'Scene_Underneath_Tunnels_WestCache_End',
    [117] = 'Scene_Underneath_Tunnels_WestCache_Pathway',
    [118] = 'Scene_Underneath_Tunnels_Loop_IntersectionWestCache',
    [119] = 'Scene_Underneath_Tunnels_Loop_PathwayLoopWestCacheIntersections',
    [120] = 'Scene_Underneath_Tunnels_Loop_LoopIntersection',
    [121] = 'Scene_Underneath_Tunnels_Loop_Center',
    [122] = 'Scene_Underneath_Tunnels_Loop_PathwayLoopEndEastCacheIntersections',
    [123] = 'Scene_Underneath_Tunnels_Loop_IntersectionEndEastCache',
    [124] = 'Scene_Underneath_Tunnels_EastCache',
    [125] = 'Scene_Underneath_Tunnels_Exit',
    [126] = 'Scene_Underneath_EastTunnel_Intersection',
    [127] = 'Scene_Underneath_EastTunnel_PathwayFort',
    [128] = 'Scene_Underneath_EastTunnel_PathwayTunnels',
    [346] = 'Scene_Underneath_Mushroom_Geyser',
    -- Set: Weave
    [130] = 'Scene_Core_End_Greenery',
    [131] = 'Scene_Orothe_Dock_Western_Ferry',
    [132] = 'Scene_Orothe_Dock_Eastern_Ferry',
    [133] = 'Scene_Orothe_Ocean_Ferry',
    [134] = 'Scene_Naroom_Gia_House_Normal',
    [135] = 'Scene_Naroom_Gia_Room',
    [136] = 'Scene_Naroom_Weave_Entrance',
    [137] = 'Scene_Naroom_Weave_Ponds',
    [138] = 'Scene_Naroom_Weave_River',
    [139] = 'Scene_Naroom_Windmill_Outside',
    [140] = 'Scene_Naroom_Weave_Exit',
    [141] = 'Scene_Naroom_Weave_KeyMaze',
    [142] = 'Scene_Underneath_Tunnels_Outside',
    [143] = 'Scene_Naroom_Windmill_Room',
    [144] = 'Scene_Naroom_Glade_Cave_Entrance',
    [347] = 'Scene_Orothe_Dock_Eastern_Empty',
    [389] = 'Scene_Orothe_Dock_Western_Empty',
    [396] = 'Scene_Naroom_Gia_House_Destroyed',
    -- Set: Orothe
    [146] = 'Scene_Orothe_Mar_Town',
    [147] = 'Scene_Orothe_Mar_InnRoom',
    [148] = 'Scene_Orothe_Mar_MobisRoom',
    [149] = 'Scene_Orothe_Mar_LibraryRoom',
    [150] = 'Scene_Orothe_Tunnels_PathwayMarUnderwater_Unused',
    [151] = 'Scene_Orothe_Coral_Entrance',
    [152] = 'Scene_Orothe_Coral_PathwayHorizontal',
    [153] = 'Scene_Orothe_Coral_PathwayVertical',
    [154] = 'Scene_Orothe_Coral_End',
    [155] = 'Scene_Orothe_Coral_TunnelsChute',
    [156] = 'Scene_Orothe_Geyser_Pathway',
    [157] = 'Scene_Orothe_Geyser_Middle',
    [158] = 'Scene_Orothe_Geyser_North',
    [159] = 'Scene_Orothe_Geyser_East',
    [160] = 'Scene_Orothe_Geyser_South',
    [161] = 'Scene_Orothe_Geyser_West',
    [162] = 'Scene_Orothe_Geyser_SouthwestPathway',
    [163] = 'Scene_Orothe_Geyser_SoutheastPathway',
    [164] = 'Scene_Orothe_Geyser_Southeast',
    [165] = 'Scene_Orothe_Geyser_Southwest',
    [166] = 'Scene_Orothe_Geyser_Currents',
    [167] = 'Scene_Orothe_Geyser_Entrance',
    [168] = 'Scene_Orothe_Geyser_CoreStone',
    [169] = 'Scene_Orothe_Island_Room',
    [170] = 'Scene_Orothe_Island_Outside',
    [171] = 'Scene_Orothe_Ruins_Entrance',
    [172] = 'Scene_Orothe_Ruins_Blurry',
    [173] = 'Scene_Orothe_Ruins_Southwest',
    [174] = 'Scene_Orothe_Tunnels_Entrance',
    [175] = 'Scene_Orothe_Tunnels_IntersectionMain',
    [176] = 'Scene_Orothe_Tunnels_PathwayMarA',
    [177] = 'Scene_Orothe_Tunnels_PathwayMarB',
    [178] = 'Scene_Orothe_Tunnels_Whirlpool',
    [179] = 'Scene_Orothe_Tunnels_Alcove',
    [180] = 'Scene_Orothe_Tunnels_IntersectionCache',
    [181] = 'Scene_Orothe_Tunnels_Cache',
    [182] = 'Scene_Orothe_Tunnels_VaultEntrance',
    [183] = 'Scene_Orothe_Tunnels_VaultRoom',
    [184] = 'Scene_Orothe_Tunnels_PathwayMarUnderwater',
    [387] = 'Scene_Orothe_Ocean_Raft',
    -- Set: Shadowhold
    [186] = 'Scene_Core_Shadowhold_Middle_StartCells',
    [187] = 'Scene_Core_Shadowhold_Middle_Door',
    [188] = 'Scene_Core_Shadowhold_Marina_Start',
    [189] = 'Scene_Core_Shadowhold_Marina_FalseIntersection',
    [190] = 'Scene_Core_Shadowhold_Marina_Room',
    [191] = 'Scene_Core_Shadowhold_Marina_Pathway',
    [192] = 'Scene_Core_Shadowhold_Marina_Jump',
    [193] = 'Scene_Core_Shadowhold_Middle_FirstPuzzle',
    [194] = 'Scene_Core_Shadowhold_Middle_FirstPathway',
    [195] = 'Scene_Core_Shadowhold_Middle_FirstIntersection',
    [196] = 'Scene_Core_Shadowhold_Middle_NorthPathway_Door',
    [197] = 'Scene_Core_Shadowhold_Middle_NorthPathway_Cells',
    [198] = 'Scene_Core_Shadowhold_Middle_SouthPathway_Cell',
    [199] = 'Scene_Core_Shadowhold_Middle_SouthPathway_ScrewRoom',
    [200] = 'Scene_Core_Shadowhold_Middle_EastPathway_Door',
    [202] = 'Scene_Core_Shadowhold_Middle_EastPathway_BigPuzzle',
    [203] = 'Scene_Core_Shadowhold_Middle_EastPathway_ArrowRoom',
    [204] = 'Scene_Core_Shadowhold_Labyrinth_Entrance',
    [205] = 'Scene_Core_Shadowhold_Labyrinth_South',
    [206] = 'Scene_Core_Shadowhold_Labyrinth_North',
    [207] = 'Scene_Core_Shadowhold_Labyrinth_PuzzlePathway',
    [208] = 'Scene_Core_Shadowhold_Deep_Cells',
    [209] = 'Scene_Core_Shadowhold_Deep_Intersection',
    [210] = 'Scene_Core_Shadowhold_Deep_FirstPuzzle',
    [211] = 'Scene_Core_Shadowhold_Deep_TwoPuzzles',
    [212] = 'Scene_Core_Shadowhold_Deep_SouthPathway',
    [213] = 'Scene_Core_Shadowhold_Deep_NorthPathway',
    [214] = 'Scene_Core_Shadowhold_Deep_End',
    [215] = 'Scene_Core_Smith_Smith',
    [216] = 'Scene_Core_Smith_Backyard_Entrance',
    [217] = 'Scene_Core_Smith_Backyard_Pathway',
    [218] = 'Scene_Core_Smith_Backyard_End',
    -- Set: Core
    [220] = 'Scene_Core_End_Bridge',
    [221] = 'Scene_Core_End_Agram',
    [222] = 'Scene_Core_End_Entrance',
    [223] = 'Scene_Core_End_Pathway',
    [224] = 'Scene_Core_End_Room',
    [225] = 'Scene_Core_End_Field',
    [226] = 'Scene_Core_End_Antechamber',
    -- Set: Hidden/Fort
    [228] = 'Scene_Underneath_Mushroom_Room_UNUSED1',
    [229] = 'Scene_Underneath_Mushroom_Room_UNUSED2',
    [230] = 'Scene_Underneath_Fort_Outside',
    [231] = 'Scene_Underneath_Fort_GroundFloorRoom',
    [232] = 'Scene_Underneath_Fort_SecondFloorRoom_OpenDoor',
    [233] = 'Scene_Underneath_Fort_SecondFloorRoom_ClosedDoor',
    [234] = 'Scene_Arderial_Fort_Outside',
    [235] = 'Scene_Arderial_Fort_UNUSED',
    [236] = 'Scene_Naroom_Forest_Puzzle_CacheRoom',
    [237] = 'Scene_Naroom_Forest_Puzzle_CacheRoom_BlastRoom',
    [238] = 'Scene_Underneath_Tunnels_Hyren_Entrance',
    [239] = 'Scene_Underneath_Tunnels_Hyren_Exit',
    [240] = 'Scene_Cald_Caverns_PathwayU_CacheRoom_UNUSED1',
    [241] = 'Scene_Cald_Caverns_PathwayU_CacheRoom_UNUSED2',
    [242] = 'Scene_Cald_Caverns_PathwayU_CacheRoom',
    [243] = 'Scene_Misc_StartScreen_Main',
    [245] = 'Scene_Misc_StartScreen_Pathway',
    [247] = 'Scene_Misc_StartScreen_Jukebox',
    [248] = 'Scene_Underneath_Mushroom_GrukRoom_BasementRoom',
    [249] = 'Scene_Underneath_Mushroom_GrukRoom_TeleportCore',
    [250] = 'Scene_Naroom_Glade_Cave_TeleportCore',
    [251] = 'Scene_Underneath_Tunnels_Hyren_IntersectionCald',
    [252] = 'Scene_Underneath_Tunnels_FortConnectionCacheRoom',
    [253] = 'Scene_Naroom_Vash_ChallengeAgovo',
    [254] = 'Scene_Underneath_EastTunnel_Intersection_BlastRoom',
    [255] = 'Scene_Underneath_Tunnels_Loop_PathwayLoopEndEastCacheIntersections_BlastRoom',
    [256] = 'Scene_Underneath_Tunnels_Exit_CacheRoom',
    [257] = 'Scene_Underneath_Tunnels_Exit_CacheRoom_RockRoom',
    [258] = 'Scene_Misc_Teleport_UNUSED1',
    [259] = 'Scene_Misc_Teleport_UNUSED2',
    [260] = 'Scene_Misc_Teleport_UNUSED3',
    [261] = 'Scene_Arderial_Fort_TeleportNaroom',
    [262] = 'Scene_Naroom_Vash_Sky_TeleportArderialRoom',
    [263] = 'Scene_Core_Smith_TeleportNaroom',
    [264] = 'Scene_Core_Smith_TeleportUnderneath',
    -- Set: Overworld
    [266] = 'Scene_Overworld_Naroom',
    [267] = 'Scene_Overworld_Underneath',
    [268] = 'Scene_Overworld_Cald',
    [269] = 'Scene_Overworld_Orothe',
    [270] = 'Scene_Overworld_Arderial',
    -- Set: Cald
    [272] = 'Scene_Cald_Geyser_Entrance',
    [273] = 'Scene_Cald_Geyser_PuzzlesA',
    [274] = 'Scene_Cald_Geyser_PuzzlesB',
    [275] = 'Scene_Cald_Geyser_Antechamber',
    [276] = 'Scene_Cald_Geyser_CoreStone',
    [277] = 'Scene_Cald_Volcano_Hyren',
    [278] = 'Scene_Cald_Ashyn_NorthGeyser',
    [279] = 'Scene_Cald_Ashyn_Center',
    [280] = 'Scene_Cald_Ashyn_West',
    [281] = 'Scene_Cald_Ashyn_East',
    [282] = 'Scene_Cald_Ashyn_SouthBridge',
    [283] = 'Scene_Cald_Ashyn_Center_HistorianRoom',
    [284] = 'Scene_Cald_Ashyn_Center_ErynRoom',
    [285] = 'Scene_Cald_Ashyn_Center_AshgarRoom',
    [286] = 'Scene_Cald_Ashyn_East_Room',
    [287] = 'Scene_Cald_Ashyn_West_InnRoom',
    [288] = 'Scene_Cald_Ashyn_West_SmithRoom',
    [289] = 'Scene_Cald_Valkan_House',
    [290] = 'Scene_Cald_Valkan_Room',
    [291] = 'Scene_Cald_Ashyn_UNUSED',
    [292] = 'Scene_Cald_Caverns_Entrance',
    [293] = 'Scene_Cald_Caverns_PathwayEntranceHorizontal',
    [294] = 'Scene_Cald_Caverns_IntersectionX',
    [295] = 'Scene_Cald_Caverns_PathwayZ',
    [296] = 'Scene_Cald_Caverns_Pathway7',
    [297] = 'Scene_Cald_Caverns_PathwayI',
    [298] = 'Scene_Cald_Caverns_IntersectionTriple',
    [299] = 'Scene_Cald_Caverns_Detour_Pathway',
    [300] = 'Scene_Cald_Caverns_Detour_End',
    [301] = 'Scene_Cald_Caverns_PathwayU',
    [302] = 'Scene_Cald_Caverns_PathwayExitHorizontal',
    [303] = 'Scene_Cald_Caverns_Exit',
    [304] = 'Scene_Cald_Tunnels_Entrance',
    [305] = 'Scene_Cald_Tunnels_IntersectionNorth',
    [306] = 'Scene_Cald_Tunnels_PathwayWest',
    [307] = 'Scene_Cald_Tunnels_PathwayCenter',
    [308] = 'Scene_Cald_Tunnels_PathwayEast',
    [309] = 'Scene_Cald_Tunnels_IntersectionExit',
    [310] = 'Scene_Cald_Vents_PathwayA',
    [311] = 'Scene_Cald_Vents_PathwayB',
    [312] = 'Scene_Cald_Vents_Intersection',
    [313] = 'Scene_Cald_Vents_PathwayIsland',
    [314] = 'Scene_Cald_Vents_Island',
    [315] = 'Scene_Cald_Vents_BrokenBridge',
    [316] = 'Scene_Cald_Vents_Entrance',
    [317] = 'Scene_Cald_Vents_BrokenBridgeEnd',
    [318] = 'Scene_Cald_Vents_CacheRoomA',
    [392] = 'Scene_Cald_Vents_CacheRoomB',
    [394] = 'Scene_Cald_Vents_CacheRoomC',
    [319] = 'Scene_Cald_Vents_PathwayIsland_RescueRoom',
    -- Set: Arderial
    [321] = 'Scene_Arderial_Palace_Outside',
    [322] = 'Scene_Arderial_Inn_Outside',
    [323] = 'Scene_Arderial_Historian_Outside',
    [324] = 'Scene_Arderial_Shop_Outside',
    [325] = 'Scene_Arderial_Palace_EntranceRoom',
    [326] = 'Scene_Arderial_Palace_DoubleRoom',
    [327] = 'Scene_Arderial_Palace_SecondFloorRoom',
    [328] = 'Scene_Arderial_Middle_House_BasementRoom',
    [329] = 'Scene_Arderial_Historian_WestRoom',
    [330] = 'Scene_Arderial_Historian_UpstairsRoom',
    [331] = 'Scene_Arderial_Shop_Room',
    [332] = 'Scene_Arderial_Historian_EastRoom',
    [348] = 'Scene_Arderial_Geyser_Remix_Arderial_Entrance',
    [349] = 'Scene_Arderial_Geyser_Remix_Arderial_KeyMaze',
    [333] = 'Scene_Arderial_Geyser_Remix_Underneath_West',
    [350] = 'Scene_Arderial_Geyser_Remix_Cald_West',
    [334] = 'Scene_Arderial_Geyser_Remix_Underneath_East',
    [351] = 'Scene_Arderial_Geyser_Remix_Cald_East',
    [335] = 'Scene_Arderial_Geyser_Remix_Cache_East',
    [336] = 'Scene_Arderial_Geyser_Remix_Cache_West',
    [337] = 'Scene_Arderial_Geyser_Remix_Naroom_West',
    [338] = 'Scene_Arderial_Geyser_Remix_Naroom_East',
    [352] = 'Scene_Arderial_Geyser_Remix_Orothe_West',
    [353] = 'Scene_Arderial_Geyser_Remix_Orothe_East',
    [354] = 'Scene_Arderial_Geyser_Pipes1_Entrance',
    [355] = 'Scene_Arderial_Geyser_Pipes1_Entrance_BackroomCache',
    [356] = 'Scene_Arderial_Geyser_Pipes1_StarryCache',
    [357] = 'Scene_Arderial_Geyser_Pipes1_PipeToStarryCache',
    [358] = 'Scene_Arderial_Geyser_Pipes1_MiddlePipeSwitch',
    [359] = 'Scene_Arderial_Geyser_Pipes1_End',
    [360] = 'Scene_Arderial_Geyser_Pipes2_Entrance',
    [361] = 'Scene_Arderial_Geyser_Pipes2_PipeAnalysis',
    [362] = 'Scene_Arderial_Geyser_Pipes2_MiddlePipeSwitch',
    [363] = 'Scene_Arderial_Geyser_Pipes2_End',
    [364] = 'Scene_Arderial_Geyser_End_GlassMaze',
    [365] = 'Scene_Arderial_Geyser_End_CoreStone',
    [366] = 'Scene_Arderial_Geyser_Pipes2_GlassField',
    [367] = 'Scene_Arderial_Geyser_End_CaldCache',
    [368] = 'Scene_Arderial_Middle_Entrance',
    [369] = 'Scene_Arderial_Middle_PathwayEntrance',
    [370] = 'Scene_Arderial_Middle_Intersection',
    [371] = 'Scene_Arderial_Middle_PathwayHouse',
    [372] = 'Scene_Arderial_Middle_House',
    [373] = 'Scene_Arderial_Middle_End',
    [374] = 'Scene_Arderial_North_SoutheastEntrance',
    [375] = 'Scene_Arderial_North_Southwest',
    [376] = 'Scene_Arderial_North_East',
    [377] = 'Scene_Arderial_North_Center',
    [378] = 'Scene_Arderial_North_West',
    [379] = 'Scene_Arderial_North_Northeast',
    [380] = 'Scene_Arderial_North_NorthwestExit',
    [381] = 'Scene_Arderial_Entrance',
    [382] = 'Scene_Arderial_South_North',
    [383] = 'Scene_Arderial_South_South',
    [339] = 'Scene_Arderial_Palace_Throneroom',
    [386] = 'Scene_Arderial_Inn_Room',
    [390] = 'Scene_Arderial_Geyser_HorizontalPipe_Unused',
    [391] = 'Scene_Arderial_Geyser_VerticalPipe_Unused',
    -- Set: Misc
    [393] = 'Scene_Misc_Whackamole_Debug',
    [397] = 'Scene_Misc_MagiNationSplashScreen',
}

function scene_id()
    scene_pointer = emu:read32(0x03000A38)
    if scene_pointer == 0 then
        return 0
    end
    return emu:read16(scene_pointer + 0x0C)
end

function scene_name(scene_id)
    return scene_names[scene_id]
end

function frame()
    buffer:clear()
    rand:update()
    buffer:print(string.format('RandRam:  0x%08X\n', rand.ram()))
    buffer:print(string.format('RandCount:  %d\n', rand.element))
    buffer:print('\n')
    awl:update()
    buffer:print(string.format('Current Scene:  %s\n', scene_name(scene_id())))
    buffer:print(string.format('Awl Can Use:  %s\n', awl.ram_can_warp()))
    buffer:print(string.format('Awl Warp ID:  0x%04X\n', awl.last_id))
    buffer:print(string.format('Awl Last Changed At:  %s\n', scene_name(awl.last_scene)))
end

function reset()
    rand:reset()
    awl:reset()
end

function saved()
    awl:saved()
end

rand = Rand.new()
awl = Awl.new()
buffer = console:createBuffer('info')
callbacks:add('frame', frame)
callbacks:add('reset', reset)
callbacks:add('savedataUpdated', saved)