// Magi Nation
// #ID = 13941

// GBADoc: https://gbadev.net/gbadoc/intro.html
// no$gba reference: http://problemkaputt.de/gbatek-gba-reference.htm

// Gameboy Advance Memory map: https://github.com/RetroAchievements/rcheevos/blob/develop/src/rcheevos/consoleinfo.c#L449
// static const rc_memory_region_t _rc_memory_regions_gameboy_advance[] = {
//    { 0x000000U, 0x007FFFU, 0x03000000U, RC_MEMORY_TYPE_SYSTEM_RAM, "System RAM" }, /* 32KB  Internal Work RAM */
//    { 0x008000U, 0x047FFFU, 0x02000000U, RC_MEMORY_TYPE_SYSTEM_RAM, "System RAM" }, /* 256KB External Work RAM */
//    { 0x048000U, 0x057FFFU, 0x0E000000U, RC_MEMORY_TYPE_SAVE_RAM, "Save RAM" }      /* 64KB  Game Pak SRAM */
//};


////////////
// Memory //
////////////

GBA_EWRAM = 0x02000000
GBA_NONSTATIC_HEAP_START = 0x02000400
GBA_NONSTATIC_HEAP_END = 0x02027610
GBA_IWRAM = 0x03000000
GBA_EEPROM = 0x0E000000
RETRO_EWRAM = 0x008000
RETRO_IWRAM = 0x000000
RETRO_EEPROM = 0x048000
SIZE_EWRAM = 0x040000
SIZE_IWRAM = 0x008000
SIZE_EEPROM = 0x002000
THROW_ERROR = 0x88888888
// Maps a GBA memory address to a RetroAchievements memory address
// map(0x03000000) -> 0x000000
// map(0x02000000) -> 0x008000
// map(0x0E000000) -> 0x048000
// Returns garbage value (THROW_ERROR) for memory addresses within the nonstatic part of the heap, or for unmapped addresses
function map(address) {
    if(address >= GBA_IWRAM && address <= GBA_IWRAM + SIZE_IWRAM)
        return address - GBA_IWRAM + RETRO_IWRAM
    if(address >= GBA_NONSTATIC_HEAP_START && address < GBA_NONSTATIC_HEAP_END)
        return THROW_ERROR
    if(address >= GBA_EWRAM && address <= GBA_EWRAM + SIZE_EWRAM)
        return address - GBA_EWRAM + RETRO_EWRAM
    if(address >= GBA_EEPROM && address <= GBA_EEPROM + SIZE_EEPROM)
        return address - GBA_EEPROM + RETRO_EEPROM
    return THROW_ERROR
}

// Dereference an address containing a pointer to the heap
// We use dword and subtract GBA_EWRAM so that null pointers point outside of the
// addressing scheme and return a value of 0.
// If we use tbyte and just add a positive offset, null pointers will resolve a
// value from the beginning of the memory map, which leaks random data and could
// potentially cause false triggers
function pointer(address, offset) =>
    dword(address) - GBA_EWRAM + RETRO_EWRAM + offset
// Dereference an address containing a pointer to IWRAM
//function iram_pointer(address, offset) =>
//    dword(address) - GBA_IWRAM + RETRO_IWRAM + offset


// Traverse through a linked list
LinkedListStruct_NextNode = 0x00
LinkedListStruct_PrevNode = 0x04
LinkedListStruct_Struct = 0x08
function _traverse_n_linked_list_nodes(n, linked_list) {
    if(n == 1)
        return linked_list
    else
        return pointer(_traverse_n_linked_list_nodes(n-1, linked_list), LinkedListStruct_NextNode)
}
function get_nth_linked_list_entry(n, linked_list) {
    return pointer(_traverse_n_linked_list_nodes(n, linked_list), LinkedListStruct_Struct)
}

///////////
// Enums //
///////////


// Creature IDs
Creature_Abaquist = 0x00
Creature_Agovo = 0x01
Creature_Alaban = 0x02
Creature_Arbolit = 0x03
Creature_Arboll = 0x04
Creature_Ayebaw = 0x05
Creature_Balamant = 0x06
Creature_Bhatar = 0x07
Creature_Bisiwog = 0x08
Creature_BlackAgovo = 0x09
Creature_Borgor = 0x0A
Creature_Brub = 0x0B
Creature_Bwill = 0x0C
Creature_CaveHyren = 0x0D
Creature_CaveRudwot = 0x0E
Creature_ChaosJile = 0x0F
Creature_ChaosPlith = 0x10
Creature_CoralHyren = 0x11
Creature_CoreHyren = 0x12
Creature_DarkAyebaw = 0x13
Creature_DarkbreedHyren = 0x14
Creature_DarkFurok = 0x15
Creature_DarkVellup = 0x16
Creature_DeepHyren = 0x17
Creature_Diobor = 0x18
Creature_Drakan = 0x19
Creature_Drush = 0x1A
Creature_DryteFiend = 0x1B
Creature_Eebit = 0x1C
Creature_Epik = 0x1D
Creature_Ergar = 0x1E
Creature_FlameHyren = 0x1F
Creature_Furok = 0x20
Creature_GhostBwisp = 0x21
Creature_GiantKorit = 0x22
Creature_Gorath = 0x23
Creature_Grax = 0x24
Creature_Grubble = 0x25
Creature_GumGum = 0x26
Creature_Harban = 0x27
Creature_HunterJile = 0x28
Creature_Jore = 0x29
Creature_Karak = 0x2A
Creature_Kelthet = 0x2B
Creature_Koil = 0x2C
Creature_LavaAq = 0x2D
Creature_LavaArboll = 0x2E
Creature_LavaBalamant = 0x2F
Creature_LeafHyren = 0x30
Creature_LightningHyren = 0x31
Creature_MagmaHyren = 0x32
Creature_MagmaJile = 0x33
Creature_Megathan = 0x34
Creature_MushroomHyren = 0x35
Creature_OrathanFlyer = 0x36
Creature_Orish = 0x37
Creature_Ormagon = 0x38
Creature_Orpus = 0x39
Creature_Paralit = 0x3A
Creature_Parmalag = 0x3B
Creature_Platheus = 0x3C
Creature_Plith = 0x3D
Creature_Pyloluf = 0x3E
Creature_Quor = 0x3F
Creature_Rabbage = 0x40
Creature_Raxis = 0x41
Creature_Rudwot = 0x42
Creature_ShadowKarak = 0x43
Creature_ShadowVinoc = 0x44
Creature_Shryque = 0x45
Creature_Sphor = 0x46
Creature_Szalak = 0x47
Creature_ThunderHyren = 0x48
Creature_ThunderVashp = 0x49
Creature_TimberHyren = 0x4A
Creature_Tragan = 0x4B
Creature_TreeHinko = 0x4C
Creature_Twee = 0x4D
Creature_Vellup = 0x4E
Creature_Vinoc = 0x4F
Creature_Vulbor = 0x50
Creature_Wasperine = 0x51
Creature_Weebat = 0x52
Creature_Weebo = 0x53
Creature_Weethan = 0x54
Creature_Xyx = 0x55
Creature_Placeholder1 = 0x56
Creature_Placeholder2 = 0x57
Creature_Dan = 0x58
Creature_Togoth = 0x59
Creature_Ogar = 0x5A
Creature_Korremar = 0x5B
Creature_Warrada = 0x5C
Creature_Korg = 0x5D
Creature_Zet = 0x5E
Creature_Morag = 0x5F
Creature_Agram = 0x60
Creature_Agram2 = 0x61
Creature_Agram3 = 0x62
Creature_ShadowMagi1 = 0x63
Creature_ShadowMagi2 = 0x64
Creature_ShadowMagi3 = 0x65
Creature_ShadowMagi4 = 0x66
Creature_ShadowMagi5 = 0x67
Creature_ShadowMagi6 = 0x68
Creature_ShadowMagi7 = 0x69
Creature_ShadowMagi8 = 0x6A
Creature_Salafy = 0x6B
Creature_Null = 0x6E


// Spell IDs
Spell_Null = 0x00
Spell_LeafCut = 0x01
Spell_Grow = 0x02
Spell_Burrow = 0x03
Spell_CaveIn = 0x04
Spell_Thunderquake = 0x05
Spell_Fireball = 0x06
Spell_FlameGeyser = 0x07
Spell_Entangle = 0x08
Spell_TidalWave = 0x09
Spell_DispelX = 0x0A
Spell_Updraft = 0x0B
Spell_Lightning = 0x0C
Spell_Condemn = 0x0D
Spell_Singularity = 0x0E
Spell_Judge = 0x0F
Spell_Jury = 0x10
Spell_Executioner = 0x11
Spell_Flood = 0x12
Spell_CunningBlow = 0x13


// Scenes
// Autogenerated by scene_to_rascript.py
// Set: Naroom
Scene_Naroom_Forest_Deep_Intersection = 1
Scene_Naroom_Forest_Deep_Pathway = 2
Scene_Naroom_Forest_Deep_Connection = 3
Scene_Naroom_Forest_Deep_Heart = 4
Scene_Naroom_Forest_Deep_Cache = 5
Scene_Naroom_Forest_Deep_House = 6
Scene_Naroom_Forest_Deep_WenceRoom = 7
Scene_Naroom_Geyser_Southeast = 8
Scene_Naroom_Geyser_South = 9
Scene_Naroom_Geyser_Southwest = 10
Scene_Naroom_Geyser_West = 11
Scene_Naroom_Geyser_Center = 12
Scene_Naroom_Geyser_East = 13
Scene_Naroom_Geyser_Northeast = 14
Scene_Naroom_Geyser_North = 15
Scene_Naroom_Geyser_Northwest = 16
Scene_Naroom_Geyser_Doorway = 17
Scene_Naroom_Geyser_CoreStone = 18
Scene_Naroom_Geyser_Entrance = 19
Scene_Naroom_Grove_Pathway = 20
Scene_Naroom_Grove_Entrance = 21
Scene_Naroom_Vash_Entrance = 22
Scene_Naroom_Glade_GuardEntrance = 23
Scene_Naroom_Glade_RingRoad = 24
Scene_Naroom_Glade_Intersection = 25
Scene_Naroom_Glade_Field = 26
Scene_Naroom_Glade_Pathway = 27
Scene_Naroom_Glade_Geyser = 28
Scene_Naroom_Glade_Cave_Exterior = 29
Scene_Naroom_Forest_Puzzle = 30
Scene_Underneath_Tunnels_Hyren_Forest = 31
Scene_Naroom_Seers_House = 32
Scene_Naroom_Seers_Room = 33
Scene_Naroom_Seers_Pathway = 34
Scene_Naroom_Seers_Hyren_UnderwaterEntrance = 35
Scene_Naroom_Seers_Hyren_UnderwaterExit = 36
Scene_Naroom_Seers_Hyren_SeaCave = 37
Scene_Naroom_Grove_River = 38
Scene_Naroom_Grove_Cache = 39
Scene_Misc_Debug = 40
Scene_Naroom_Forest_Exit = 41
Scene_Naroom_Forest_Exit_UNUSED1 = 42
Scene_Naroom_Forest_Exit_UNUSED2 = 43
Scene_Naroom_Vash_BottomStairs = 44
Scene_Naroom_Vash_South = 45
Scene_Naroom_Vash_Southwest = 46
Scene_Naroom_Vash_Southeast = 47
Scene_Naroom_Vash_North = 48
Scene_Naroom_Vash_Northwest = 49
Scene_Naroom_Vash_TopStairs = 50
Scene_Naroom_Vash_Top = 51
Scene_Naroom_Vash_Southwest_InnRoom = 52
Scene_Naroom_Vash_Southwest_ShopRoom = 53
Scene_Naroom_Vash_Southeast_SmithRoom = 54
Scene_Naroom_Vash_Northwest_HistorianRoom = 55
Scene_Naroom_Vash_Training = 56
Scene_Naroom_Vash_Northwest_TrynRoom = 57
Scene_Naroom_Vash_Top_OrwinRoom_Entrance = 58
Scene_Naroom_Vash_Top_OrwinRoom_Observatory = 59
Scene_Naroom_Vash_North_RoomA = 60
Scene_Naroom_Vash_North_RoomB = 61
Scene_Naroom_Vash_Southeast_Room = 62
Scene_Naroom_Vash_North_SpookyRoom_Normal = 63
Scene_Naroom_Vash_Sky = 64
Scene_Naroom_Vash_Training_Closet = 65
Scene_Naroom_Vash_Southeast_CurioRoom = 66
Scene_Cald_Archery = 67
Scene_Naroom_Vash_South_AgovoRoom = 340
Scene_Naroom_Vash_Southwest_PipesRoom_Pathway_West = 384
Scene_Naroom_Vash_Southwest_PipesRoom_Back = 385
Scene_Naroom_Vash_Southwest_PipesRoom_Pathway_East = 388
Scene_Naroom_Vash_North_SpookyRoom_Overgrown = 395
// Set: Tavel Gorge
Scene_Misc_Tavel_Outside = 69
Scene_Misc_Tavel_Entrance = 70
Scene_Misc_Tavel_Maze = 71
Scene_Misc_Tavel_Crystal = 72
// Set: Underneath
Scene_Underneath_Mushroom_WestEntrance = 74
Scene_Underneath_Mushroom_North = 75
Scene_Underneath_Mushroom_East = 76
Scene_Underneath_Mushroom_South = 77
Scene_Underneath_Mushroom_Center = 78
Scene_Underneath_Garage_House = 79
Scene_Underneath_Garage_Room = 80
Scene_Underneath_Mushroom_East_RescueRoom = 81
Scene_Underneath_Mushroom_East_Ormagon = 82
Scene_Underneath_Geyser_SouthEntrance = 83
Scene_Underneath_Geyser_Southwest = 84
Scene_Underneath_Geyser_Altar = 85
Scene_Underneath_Geyser_CavedIn = 86
Scene_Underneath_Geyser_Northwest = 87
Scene_Underneath_Geyser_Northeast = 88
Scene_Underneath_Geyser_CulDeSac = 89
Scene_Underneath_Geyser_Southeast = 90
Scene_Underneath_Geyser_CoreStone = 91
Scene_Cald_Vents_Hyren = 92
Scene_Underneath_Mushroom_House = 93
Scene_Underneath_Mushroom_GrukRoom = 94
Scene_Underneath_Bogrom_Normal = 95
Scene_Underneath_Bogrom_Destroyed = 96
Scene_Underneath_Bogrom_GenericRoom = 97
Scene_Underneath_Bogrom_InnRoom = 98
Scene_Underneath_Bogrom_HistorianRoom = 99
Scene_Underneath_Bogrom_GogorRoom = 100
Scene_Underneath_Bogrom_MotashRoom = 101
Scene_Underneath_Bogrom_UlkRoom = 102
Scene_Underneath_Bogrom_BrubRoom = 103
Scene_Underneath_Whackamole = 104
Scene_Underneath_Tunnels_Mouth = 105
Scene_Underneath_Tunnels_IntersectionHyren = 106
Scene_Underneath_Tunnels_StairsHyren = 107
Scene_Underneath_Tunnels_PathwayHyrenFortIntersections = 108
Scene_Underneath_Tunnels_IntersectionFort = 109
Scene_Underneath_Tunnels_PathwayFort = 110
Scene_Underneath_Tunnels_PathwayFortLoopIntersections_A = 111
Scene_Underneath_Tunnels_PathwayFortLoopIntersections_B_Unused = 112
Scene_Underneath_Tunnels_PathwayFortLoopIntersections_C = 113
Scene_Underneath_Tunnels_PathwayFortLoopIntersections_D = 114
Scene_Underneath_Tunnels_WestCache_Rock = 115
Scene_Underneath_Tunnels_WestCache_End = 116
Scene_Underneath_Tunnels_WestCache_Pathway = 117
Scene_Underneath_Tunnels_Loop_IntersectionWestCache = 118
Scene_Underneath_Tunnels_Loop_PathwayLoopWestCacheIntersections = 119
Scene_Underneath_Tunnels_Loop_LoopIntersection = 120
Scene_Underneath_Tunnels_Loop_Center = 121
Scene_Underneath_Tunnels_Loop_PathwayLoopEndEastCacheIntersections = 122
Scene_Underneath_Tunnels_Loop_IntersectionEndEastCache = 123
Scene_Underneath_Tunnels_EastCache = 124
Scene_Underneath_Tunnels_Exit = 125
Scene_Underneath_EastTunnel_Intersection = 126
Scene_Underneath_EastTunnel_PathwayFort = 127
Scene_Underneath_EastTunnel_PathwayTunnels = 128
Scene_Underneath_Mushroom_Geyser = 346
// Set: Weave
Scene_Core_End_Greenery = 130
Scene_Orothe_Dock_Western_Ferry = 131
Scene_Orothe_Dock_Eastern_Ferry = 132
Scene_Orothe_Ocean_Ferry = 133
Scene_Naroom_Gia_House_Normal = 134
Scene_Naroom_Gia_Room = 135
Scene_Naroom_Weave_Entrance = 136
Scene_Naroom_Weave_Ponds = 137
Scene_Naroom_Weave_River = 138
Scene_Naroom_Windmill_Outside = 139
Scene_Naroom_Weave_Exit = 140
Scene_Naroom_Weave_KeyMaze = 141
Scene_Underneath_Tunnels_Outside = 142
Scene_Naroom_Windmill_Room = 143
Scene_Naroom_Glade_Cave_Entrance = 144
Scene_Orothe_Dock_Eastern_Empty = 347
Scene_Orothe_Dock_Western_Empty = 389
Scene_Naroom_Gia_House_Destroyed = 396
// Set: Orothe
Scene_Orothe_Mar_Town = 146
Scene_Orothe_Mar_InnRoom = 147
Scene_Orothe_Mar_MobisRoom = 148
Scene_Orothe_Mar_LibraryRoom = 149
Scene_Orothe_Tunnels_PathwayMarUnderwater_Unused = 150
Scene_Orothe_Coral_Entrance = 151
Scene_Orothe_Coral_PathwayHorizontal = 152
Scene_Orothe_Coral_PathwayVertical = 153
Scene_Orothe_Coral_End = 154
Scene_Orothe_Coral_TunnelsChute = 155
Scene_Orothe_Geyser_Pathway = 156
Scene_Orothe_Geyser_Middle = 157
Scene_Orothe_Geyser_North = 158
Scene_Orothe_Geyser_East = 159
Scene_Orothe_Geyser_South = 160
Scene_Orothe_Geyser_West = 161
Scene_Orothe_Geyser_SouthwestPathway = 162
Scene_Orothe_Geyser_SoutheastPathway = 163
Scene_Orothe_Geyser_Southeast = 164
Scene_Orothe_Geyser_Southwest = 165
Scene_Orothe_Geyser_Currents = 166
Scene_Orothe_Geyser_Entrance = 167
Scene_Orothe_Geyser_CoreStone = 168
Scene_Orothe_Island_Room = 169
Scene_Orothe_Island_Outside = 170
Scene_Orothe_Ruins_Entrance = 171
Scene_Orothe_Ruins_Blurry = 172
Scene_Orothe_Ruins_Southwest = 173
Scene_Orothe_Tunnels_Entrance = 174
Scene_Orothe_Tunnels_IntersectionMain = 175
Scene_Orothe_Tunnels_PathwayMarA = 176
Scene_Orothe_Tunnels_PathwayMarB = 177
Scene_Orothe_Tunnels_Whirlpool = 178
Scene_Orothe_Tunnels_Alcove = 179
Scene_Orothe_Tunnels_IntersectionCache = 180
Scene_Orothe_Tunnels_Cache = 181
Scene_Orothe_Tunnels_VaultEntrance = 182
Scene_Orothe_Tunnels_VaultRoom = 183
Scene_Orothe_Tunnels_PathwayMarUnderwater = 184
Scene_Orothe_Ocean_Raft = 387
// Set: Shadowhold
Scene_Core_Shadowhold_Middle_StartCells = 186
Scene_Core_Shadowhold_Middle_Door = 187
Scene_Core_Shadowhold_Marina_Start = 188
Scene_Core_Shadowhold_Marina_FalseIntersection = 189
Scene_Core_Shadowhold_Marina_Room = 190
Scene_Core_Shadowhold_Marina_Pathway = 191
Scene_Core_Shadowhold_Marina_Jump = 192
Scene_Core_Shadowhold_Middle_FirstPuzzle = 193
Scene_Core_Shadowhold_Middle_FirstPathway = 194
Scene_Core_Shadowhold_Middle_FirstIntersection = 195
Scene_Core_Shadowhold_Middle_NorthPathway_Door = 196
Scene_Core_Shadowhold_Middle_NorthPathway_Cells = 197
Scene_Core_Shadowhold_Middle_SouthPathway_Cell = 198
Scene_Core_Shadowhold_Middle_SouthPathway_ScrewRoom = 199
Scene_Core_Shadowhold_Middle_EastPathway_Door = 200
Scene_Core_Shadowhold_Middle_EastPathway_BigPuzzle = 202
Scene_Core_Shadowhold_Middle_EastPathway_ArrowRoom = 203
Scene_Core_Shadowhold_Labyrinth_Entrance = 204
Scene_Core_Shadowhold_Labyrinth_South = 205
Scene_Core_Shadowhold_Labyrinth_North = 206
Scene_Core_Shadowhold_Labyrinth_PuzzlePathway = 207
Scene_Core_Shadowhold_Deep_Cells = 208
Scene_Core_Shadowhold_Deep_Intersection = 209
Scene_Core_Shadowhold_Deep_FirstPuzzle = 210
Scene_Core_Shadowhold_Deep_TwoPuzzles = 211
Scene_Core_Shadowhold_Deep_SouthPathway = 212
Scene_Core_Shadowhold_Deep_NorthPathway = 213
Scene_Core_Shadowhold_Deep_End = 214
Scene_Core_Smith_Smith = 215
Scene_Core_Smith_Backyard_Entrance = 216
Scene_Core_Smith_Backyard_Pathway = 217
Scene_Core_Smith_Backyard_End = 218
// Set: Core
Scene_Core_End_Bridge = 220
Scene_Core_End_Agram = 221
Scene_Core_End_Entrance = 222
Scene_Core_End_Pathway = 223
Scene_Core_End_Room = 224
Scene_Core_End_Field = 225
Scene_Core_End_Antechamber = 226
// Set: Hidden/Fort
Scene_Underneath_Mushroom_Room_UNUSED1 = 228
Scene_Underneath_Mushroom_Room_UNUSED2 = 229
Scene_Underneath_Fort_Outside = 230
Scene_Underneath_Fort_GroundFloorRoom = 231
Scene_Underneath_Fort_SecondFloorRoom_OpenDoor = 232
Scene_Underneath_Fort_SecondFloorRoom_ClosedDoor = 233
Scene_Arderial_Fort_Outside = 234
Scene_Arderial_Fort_UNUSED = 235
Scene_Naroom_Forest_Puzzle_CacheRoom = 236
Scene_Naroom_Forest_Puzzle_CacheRoom_BlastRoom = 237
Scene_Underneath_Tunnels_Hyren_Entrance = 238
Scene_Underneath_Tunnels_Hyren_Exit = 239
Scene_Cald_Caverns_PathwayU_CacheRoom_UNUSED1 = 240
Scene_Cald_Caverns_PathwayU_CacheRoom_UNUSED2 = 241
Scene_Cald_Caverns_PathwayU_CacheRoom = 242
Scene_Misc_StartScreen_Main = 243
Scene_Misc_StartScreen_Pathway = 245
Scene_Misc_StartScreen_Jukebox = 247
Scene_Underneath_Mushroom_GrukRoom_BasementRoom = 248
Scene_Underneath_Mushroom_GrukRoom_TeleportCore = 249
Scene_Naroom_Glade_Cave_TeleportCore = 250
Scene_Underneath_Tunnels_Hyren_IntersectionCald = 251
Scene_Underneath_Tunnels_FortConnectionCacheRoom = 252
Scene_Naroom_Vash_ChallengeAgovo = 253
Scene_Underneath_EastTunnel_Intersection_BlastRoom = 254
Scene_Underneath_Tunnels_Loop_PathwayLoopEndEastCacheIntersections_BlastRoom = 255
Scene_Underneath_Tunnels_Exit_CacheRoom = 256
Scene_Underneath_Tunnels_Exit_CacheRoom_RockRoom = 257
Scene_Misc_Teleport_UNUSED1 = 258
Scene_Misc_Teleport_UNUSED2 = 259
Scene_Misc_Teleport_UNUSED3 = 260
Scene_Arderial_Fort_TeleportNaroom = 261
Scene_Naroom_Vash_Sky_TeleportArderialRoom = 262
Scene_Core_Smith_TeleportNaroom = 263
Scene_Core_Smith_TeleportUnderneath = 264
// Set: Overworld
Scene_Overworld_Naroom = 266
Scene_Overworld_Underneath = 267
Scene_Overworld_Cald = 268
Scene_Overworld_Orothe = 269
Scene_Overworld_Arderial = 270
// Set: Cald
Scene_Cald_Geyser_Entrance = 272
Scene_Cald_Geyser_PuzzlesA = 273
Scene_Cald_Geyser_PuzzlesB = 274
Scene_Cald_Geyser_Antechamber = 275
Scene_Cald_Geyser_CoreStone = 276
Scene_Cald_Volcano_Hyren = 277
Scene_Cald_Ashyn_NorthGeyser = 278
Scene_Cald_Ashyn_Center = 279
Scene_Cald_Ashyn_West = 280
Scene_Cald_Ashyn_East = 281
Scene_Cald_Ashyn_SouthBridge = 282
Scene_Cald_Ashyn_Center_HistorianRoom = 283
Scene_Cald_Ashyn_Center_ErynRoom = 284
Scene_Cald_Ashyn_Center_AshgarRoom = 285
Scene_Cald_Ashyn_East_Room = 286
Scene_Cald_Ashyn_West_InnRoom = 287
Scene_Cald_Ashyn_West_SmithRoom = 288
Scene_Cald_Valkan_House = 289
Scene_Cald_Valkan_Room = 290
Scene_Cald_Ashyn_UNUSED = 291
Scene_Cald_Caverns_Entrance = 292
Scene_Cald_Caverns_PathwayEntranceHorizontal = 293
Scene_Cald_Caverns_IntersectionX = 294
Scene_Cald_Caverns_PathwayZ = 295
Scene_Cald_Caverns_Pathway7 = 296
Scene_Cald_Caverns_PathwayI = 297
Scene_Cald_Caverns_IntersectionTriple = 298
Scene_Cald_Caverns_Detour_Pathway = 299
Scene_Cald_Caverns_Detour_End = 300
Scene_Cald_Caverns_PathwayU = 301
Scene_Cald_Caverns_PathwayExitHorizontal = 302
Scene_Cald_Caverns_Exit = 303
Scene_Cald_Tunnels_Entrance = 304
Scene_Cald_Tunnels_IntersectionNorth = 305
Scene_Cald_Tunnels_PathwayWest = 306
Scene_Cald_Tunnels_PathwayCenter = 307
Scene_Cald_Tunnels_PathwayEast = 308
Scene_Cald_Tunnels_IntersectionExit = 309
Scene_Cald_Vents_PathwayA = 310
Scene_Cald_Vents_PathwayB = 311
Scene_Cald_Vents_Intersection = 312
Scene_Cald_Vents_PathwayIsland = 313
Scene_Cald_Vents_Island = 314
Scene_Cald_Vents_BrokenBridge = 315
Scene_Cald_Vents_Entrance = 316
Scene_Cald_Vents_BrokenBridgeEnd = 317
Scene_Cald_Vents_CacheRoomA = 318
Scene_Cald_Vents_CacheRoomB = 392
Scene_Cald_Vents_CacheRoomC = 394
Scene_Cald_Vents_PathwayIsland_RescueRoom = 319
// Set: Arderial
Scene_Arderial_Palace_Outside = 321
Scene_Arderial_Inn_Outside = 322
Scene_Arderial_Historian_Outside = 323
Scene_Arderial_Shop_Outside = 324
Scene_Arderial_Palace_EntranceRoom = 325
Scene_Arderial_Palace_DoubleRoom = 326
Scene_Arderial_Palace_SecondFloorRoom = 327
Scene_Arderial_Middle_House_BasementRoom = 328
Scene_Arderial_Historian_WestRoom = 329
Scene_Arderial_Historian_UpstairsRoom = 330
Scene_Arderial_Shop_Room = 331
Scene_Arderial_Historian_EastRoom = 332
Scene_Arderial_Geyser_Remix_Arderial_Entrance = 348
Scene_Arderial_Geyser_Remix_Arderial_KeyMaze = 349
Scene_Arderial_Geyser_Remix_Underneath_West = 333
Scene_Arderial_Geyser_Remix_Cald_West = 350
Scene_Arderial_Geyser_Remix_Underneath_East = 334
Scene_Arderial_Geyser_Remix_Cald_East = 351
Scene_Arderial_Geyser_Remix_Cache_East = 335
Scene_Arderial_Geyser_Remix_Cache_West = 336
Scene_Arderial_Geyser_Remix_Naroom_West = 337
Scene_Arderial_Geyser_Remix_Naroom_East = 338
Scene_Arderial_Geyser_Remix_Orothe_West = 352
Scene_Arderial_Geyser_Remix_Orothe_East = 353
Scene_Arderial_Geyser_Pipes1_Entrance = 354
Scene_Arderial_Geyser_Pipes1_Entrance_BackroomCache = 355
Scene_Arderial_Geyser_Pipes1_StarryCache = 356
Scene_Arderial_Geyser_Pipes1_PipeToStarryCache = 357
Scene_Arderial_Geyser_Pipes1_MiddlePipeSwitch = 358
Scene_Arderial_Geyser_Pipes1_End = 359
Scene_Arderial_Geyser_Pipes2_Entrance = 360
Scene_Arderial_Geyser_Pipes2_PipeAnalysis = 361
Scene_Arderial_Geyser_Pipes2_MiddlePipeSwitch = 362
Scene_Arderial_Geyser_Pipes2_End = 363
Scene_Arderial_Geyser_End_GlassMaze = 364
Scene_Arderial_Geyser_End_CoreStone = 365
Scene_Arderial_Geyser_Pipes2_GlassField = 366
Scene_Arderial_Geyser_End_CaldCache = 367
Scene_Arderial_Middle_Entrance = 368
Scene_Arderial_Middle_PathwayEntrance = 369
Scene_Arderial_Middle_Intersection = 370
Scene_Arderial_Middle_PathwayHouse = 371
Scene_Arderial_Middle_House = 372
Scene_Arderial_Middle_End = 373
Scene_Arderial_North_SoutheastEntrance = 374
Scene_Arderial_North_Southwest = 375
Scene_Arderial_North_East = 376
Scene_Arderial_North_Center = 377
Scene_Arderial_North_West = 378
Scene_Arderial_North_Northeast = 379
Scene_Arderial_North_NorthwestExit = 380
Scene_Arderial_Entrance = 381
Scene_Arderial_South_North = 382
Scene_Arderial_South_South = 383
Scene_Arderial_Palace_Throneroom = 339
Scene_Arderial_Inn_Room = 386
Scene_Arderial_Geyser_HorizontalPipe_Unused = 390
Scene_Arderial_Geyser_VerticalPipe_Unused = 391
// Set: Misc
Scene_Misc_Whackamole_Debug = 393
Scene_Misc_MagiNationSplashScreen = 397
// End of autogenerated scene_to_rascript.py

Script_LinkedList = map(0x03003508)
ScriptStruct_Frame = 0x04
ScriptStruct_FrameOffset = 0x14
function get_nth_script_frame(n) {
    return dword(pointer(get_nth_linked_list_entry(n, Script_LinkedList), ScriptStruct_Frame))
}
function get_nth_script_offset(n) {
    return dword(pointer(get_nth_linked_list_entry(n, Script_LinkedList), ScriptStruct_FrameOffset))
}




// Gets Scene ID via pointer
BaseStruct_SceneRelatedStruct_SceneObjectPointer = map(0x03000A38)
BaseStruct_SceneRelatedStruct_SceneObjectPointer_Offset_SceneID = 0x0C
function scene_id() =>
    word(pointer(BaseStruct_SceneRelatedStruct_SceneObjectPointer, BaseStruct_SceneRelatedStruct_SceneObjectPointer_Offset_SceneID))

/////////////////////////
// Scene ID Identifier //
/////////////////////////
function frame_counter() =>
    byte(0x00000030) // Dword that increments every frame, so triggers every 256 frames. Memory address has not been investigated and could have unexpected behaviour
leaderboard(
    title = "SceneID",
    description = "Debug display of SceneID",
    start = frame_counter() == 0x01,
    cancel = always_false(),
    submit = always_false(),
    value = scene_id(),
    format = "VALUE",
    lower_is_better = false,
    id = 0
)


///////////////////
// Rich Presence //
///////////////////

// Autogenerated by scene_to_rascript.py
scene_lookup = {
    // Set: Naroom
    Scene_Naroom_Forest_Deep_Intersection: "Naroom Forest",
    Scene_Naroom_Forest_Deep_Pathway: "Naroom Forest",
    Scene_Naroom_Forest_Deep_Connection: "Naroom Forest",
    Scene_Naroom_Forest_Deep_Heart: "Naroom Forest",
    Scene_Naroom_Forest_Deep_Cache: "Naroom Forest",
    Scene_Naroom_Forest_Deep_House: "Wence's House",
    Scene_Naroom_Forest_Deep_WenceRoom: "Wence's House",
    Scene_Naroom_Geyser_Southeast: "Naroom Geyser",
    Scene_Naroom_Geyser_South: "Naroom Geyser",
    Scene_Naroom_Geyser_Southwest: "Naroom Geyser",
    Scene_Naroom_Geyser_West: "Naroom Geyser",
    Scene_Naroom_Geyser_Center: "Naroom Geyser",
    Scene_Naroom_Geyser_East: "Naroom Geyser",
    Scene_Naroom_Geyser_Northeast: "Naroom Geyser",
    Scene_Naroom_Geyser_North: "Naroom Geyser",
    Scene_Naroom_Geyser_Northwest: "Naroom Geyser",
    Scene_Naroom_Geyser_Doorway: "Naroom Geyser",
    Scene_Naroom_Geyser_CoreStone: "Naroom Geyser",
    Scene_Naroom_Geyser_Entrance: "Naroom Geyser",
    Scene_Naroom_Grove_Pathway: "Naroom Grove",
    Scene_Naroom_Grove_Entrance: "Naroom Grove",
    Scene_Naroom_Vash_Entrance: "Vash Naroom",
    Scene_Naroom_Glade_GuardEntrance: "Naroom Glade",
    Scene_Naroom_Glade_RingRoad: "Naroom Glade",
    Scene_Naroom_Glade_Intersection: "Naroom Glade",
    Scene_Naroom_Glade_Field: "Naroom Glade",
    Scene_Naroom_Glade_Pathway: "Naroom Glade",
    Scene_Naroom_Glade_Geyser: "Naroom Glade",
    Scene_Naroom_Glade_Cave_Exterior: "Naroom Cave",
    Scene_Naroom_Forest_Puzzle: "Naroom Forest",
    Scene_Underneath_Tunnels_Hyren_Forest: "Hyren's Glade",
    Scene_Naroom_Seers_House: "Seer's House",
    Scene_Naroom_Seers_Room: "Seer's House",
    Scene_Naroom_Seers_Pathway: "Seer's House",
    Scene_Naroom_Seers_Hyren_UnderwaterEntrance: "Under the Seer's House",
    Scene_Naroom_Seers_Hyren_UnderwaterExit: "Under the Seer's House",
    Scene_Naroom_Seers_Hyren_SeaCave: "Under the Seer's House",
    Scene_Naroom_Grove_River: "Naroom Grove",
    Scene_Naroom_Grove_Cache: "Naroom Grove",
    Scene_Misc_Debug: "Hacking! Unused Location!",
    Scene_Naroom_Forest_Exit: "Naroom Forest",
    Scene_Naroom_Forest_Exit_UNUSED1: "Hacking! Unused Location!",
    Scene_Naroom_Forest_Exit_UNUSED2: "Hacking! Unused Location!",
    Scene_Naroom_Vash_BottomStairs: "Vash Naroom",
    Scene_Naroom_Vash_South: "Vash Naroom",
    Scene_Naroom_Vash_Southwest: "Vash Naroom",
    Scene_Naroom_Vash_Southeast: "Vash Naroom",
    Scene_Naroom_Vash_North: "Vash Naroom",
    Scene_Naroom_Vash_Northwest: "Vash Naroom",
    Scene_Naroom_Vash_TopStairs: "Vash Naroom",
    Scene_Naroom_Vash_Top: "Vash Naroom",
    Scene_Naroom_Vash_Southwest_InnRoom: "Poad's Inn",
    Scene_Naroom_Vash_Southwest_ShopRoom: "Vash Naroom Shop",
    Scene_Naroom_Vash_Southeast_SmithRoom: "Pruitt's Ring Shop",
    Scene_Naroom_Vash_Northwest_HistorianRoom: "Evu's House",
    Scene_Naroom_Vash_Training: "Training Grounds",
    Scene_Naroom_Vash_Northwest_TrynRoom: "Tryn's House",
    Scene_Naroom_Vash_Top_OrwinRoom_Entrance: "Orwin's House",
    Scene_Naroom_Vash_Top_OrwinRoom_Observatory: "Orwin's House",
    Scene_Naroom_Vash_North_RoomA: "Vash Naroom",
    Scene_Naroom_Vash_North_RoomB: "Vash Naroom",
    Scene_Naroom_Vash_Southeast_Room: "Vash Naroom",
    Scene_Naroom_Vash_North_SpookyRoom_Normal: "Spooky Kid's House",
    Scene_Naroom_Vash_Sky: "Vash Naroom",
    Scene_Naroom_Vash_Training_Closet: "Training Grounds Closet",
    Scene_Naroom_Vash_Southeast_CurioRoom: "Curio Shop",
    Scene_Cald_Archery: "Hacking! Unused Location!",
    Scene_Naroom_Vash_South_AgovoRoom: "Avoid the Agovos",
    Scene_Naroom_Vash_Southwest_PipesRoom_Pathway_West: "Vash Naroom",
    Scene_Naroom_Vash_Southwest_PipesRoom_Back: "Vash Naroom",
    Scene_Naroom_Vash_Southwest_PipesRoom_Pathway_East: "Vash Naroom",
    Scene_Naroom_Vash_North_SpookyRoom_Overgrown: "Spooky Kid's House",
    // Set: Tavel Gorge
    Scene_Misc_Tavel_Outside: "Tavel Gorge",
    Scene_Misc_Tavel_Entrance: "Tavel Gorge Cave",
    Scene_Misc_Tavel_Maze: "Tavel Gorge Cave",
    Scene_Misc_Tavel_Crystal: "Tavel Gorge Cave",
    // Set: Underneath
    Scene_Underneath_Mushroom_WestEntrance: "Underneath Caverns",
    Scene_Underneath_Mushroom_North: "Underneath Caverns",
    Scene_Underneath_Mushroom_East: "Underneath Caverns",
    Scene_Underneath_Mushroom_South: "Underneath Caverns",
    Scene_Underneath_Mushroom_Center: "Underneath Caverns",
    Scene_Underneath_Garage_House: "Prospector Garage",
    Scene_Underneath_Garage_Room: "Prospector Garage",
    Scene_Underneath_Mushroom_East_RescueRoom: "Underneath Caverns' Secret House",
    Scene_Underneath_Mushroom_East_Ormagon: "Underneath Caverns' Secret Area",
    Scene_Underneath_Geyser_SouthEntrance: "Underneath Geyser",
    Scene_Underneath_Geyser_Southwest: "Underneath Geyser",
    Scene_Underneath_Geyser_Altar: "Underneath Geyser",
    Scene_Underneath_Geyser_CavedIn: "Underneath Geyser",
    Scene_Underneath_Geyser_Northwest: "Underneath Geyser",
    Scene_Underneath_Geyser_Northeast: "Underneath Geyser",
    Scene_Underneath_Geyser_CulDeSac: "Underneath Geyser",
    Scene_Underneath_Geyser_Southeast: "Underneath Geyser",
    Scene_Underneath_Geyser_CoreStone: "Underneath Geyser",
    Scene_Cald_Vents_Hyren: "Lava Vent Cavern",
    Scene_Underneath_Mushroom_House: "Gruk's Mushroom Farm",
    Scene_Underneath_Mushroom_GrukRoom: "Gruk's Mushroom Farm",
    Scene_Underneath_Bogrom_Normal: "Bogrom",
    Scene_Underneath_Bogrom_Destroyed: "Bogrom",
    Scene_Underneath_Bogrom_GenericRoom: "Bogrom",
    Scene_Underneath_Bogrom_InnRoom: "Underneath Inn",
    Scene_Underneath_Bogrom_HistorianRoom: "Bogrom Historian's House",
    Scene_Underneath_Bogrom_GogorRoom: "Gogor's House",
    Scene_Underneath_Bogrom_MotashRoom: "Motash's House",
    Scene_Underneath_Bogrom_UlkRoom: "Ulk's House",
    Scene_Underneath_Bogrom_BrubRoom: "Scrub the Brub",
    Scene_Underneath_Whackamole: "Scrub the Brub",
    Scene_Underneath_Tunnels_Mouth: "Underneath Tunnels",
    Scene_Underneath_Tunnels_IntersectionHyren: "Underneath Tunnels",
    Scene_Underneath_Tunnels_StairsHyren: "Underneath Tunnels",
    Scene_Underneath_Tunnels_PathwayHyrenFortIntersections: "Underneath Tunnels",
    Scene_Underneath_Tunnels_IntersectionFort: "Underneath Tunnels",
    Scene_Underneath_Tunnels_PathwayFort: "Underneath Tunnels",
    Scene_Underneath_Tunnels_PathwayFortLoopIntersections_A: "Underneath Tunnels",
    Scene_Underneath_Tunnels_PathwayFortLoopIntersections_B_Unused: "Hacking! Unused Location!",
    Scene_Underneath_Tunnels_PathwayFortLoopIntersections_C: "Underneath Tunnels",
    Scene_Underneath_Tunnels_PathwayFortLoopIntersections_D: "Underneath Tunnels",
    Scene_Underneath_Tunnels_WestCache_Rock: "Underneath Tunnels",
    Scene_Underneath_Tunnels_WestCache_End: "Underneath Tunnels",
    Scene_Underneath_Tunnels_WestCache_Pathway: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_IntersectionWestCache: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_PathwayLoopWestCacheIntersections: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_LoopIntersection: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_Center: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_PathwayLoopEndEastCacheIntersections: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_IntersectionEndEastCache: "Underneath Tunnels",
    Scene_Underneath_Tunnels_EastCache: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Exit: "Underneath Tunnels",
    Scene_Underneath_EastTunnel_Intersection: "East Underneath Tunnels",
    Scene_Underneath_EastTunnel_PathwayFort: "East Underneath Tunnels",
    Scene_Underneath_EastTunnel_PathwayTunnels: "East Underneath Tunnels",
    Scene_Underneath_Mushroom_Geyser: "Underneath Geyser",
    // Set: Weave
    Scene_Core_End_Greenery: "Core Entrance",
    Scene_Orothe_Dock_Western_Ferry: "Ferry",
    Scene_Orothe_Dock_Eastern_Ferry: "Ferry",
    Scene_Orothe_Ocean_Ferry: "Ferry",
    Scene_Naroom_Gia_House_Normal: "Gia's Farm",
    Scene_Naroom_Gia_Room: "Gia's Farm",
    Scene_Naroom_Weave_Entrance: "Weave",
    Scene_Naroom_Weave_Ponds: "Weave",
    Scene_Naroom_Weave_River: "Weave",
    Scene_Naroom_Windmill_Outside: "Wheat Farm",
    Scene_Naroom_Weave_Exit: "Weave",
    Scene_Naroom_Weave_KeyMaze: "Weave",
    Scene_Underneath_Tunnels_Outside: "Underneath Tunnels",
    Scene_Naroom_Windmill_Room: "Wheat Farm",
    Scene_Naroom_Glade_Cave_Entrance: "Naroom Cave",
    Scene_Orothe_Dock_Eastern_Empty: "Ferry",
    Scene_Orothe_Dock_Western_Empty: "Ferry",
    Scene_Naroom_Gia_House_Destroyed: "Gia's Farm",
    // Set: Orothe
    Scene_Orothe_Mar_Town: "Oscent Mar",
    Scene_Orothe_Mar_InnRoom: "Oscent Mar Inn",
    Scene_Orothe_Mar_MobisRoom: "Oscent Mar",
    Scene_Orothe_Mar_LibraryRoom: "Oscent Mar Library",
    Scene_Orothe_Tunnels_PathwayMarUnderwater_Unused: "Hacking! Unused Location!",
    Scene_Orothe_Coral_Entrance: "Orothe Corals",
    Scene_Orothe_Coral_PathwayHorizontal: "Orothe Corals",
    Scene_Orothe_Coral_PathwayVertical: "Orothe Corals",
    Scene_Orothe_Coral_End: "Orothe Corals",
    Scene_Orothe_Coral_TunnelsChute: "Orothe Corals",
    Scene_Orothe_Geyser_Pathway: "Orothe Geyser",
    Scene_Orothe_Geyser_Middle: "Orothe Geyser",
    Scene_Orothe_Geyser_North: "Orothe Geyser",
    Scene_Orothe_Geyser_East: "Orothe Geyser",
    Scene_Orothe_Geyser_South: "Orothe Geyser",
    Scene_Orothe_Geyser_West: "Orothe Geyser",
    Scene_Orothe_Geyser_SouthwestPathway: "Orothe Geyser",
    Scene_Orothe_Geyser_SoutheastPathway: "Orothe Geyser",
    Scene_Orothe_Geyser_Southeast: "Orothe Geyser",
    Scene_Orothe_Geyser_Southwest: "Orothe Geyser",
    Scene_Orothe_Geyser_Currents: "Orothe Geyser",
    Scene_Orothe_Geyser_Entrance: "Orothe Geyser",
    Scene_Orothe_Geyser_CoreStone: "Orothe Geyser",
    Scene_Orothe_Island_Room: "Orothe Island",
    Scene_Orothe_Island_Outside: "Orothe Island",
    Scene_Orothe_Ruins_Entrance: "Underwater Ruins",
    Scene_Orothe_Ruins_Blurry: "Underwater Ruins",
    Scene_Orothe_Ruins_Southwest: "Underwater Ruins",
    Scene_Orothe_Tunnels_Entrance: "Orothe Tunnels",
    Scene_Orothe_Tunnels_IntersectionMain: "Orothe Tunnels",
    Scene_Orothe_Tunnels_PathwayMarA: "Orothe Tunnels",
    Scene_Orothe_Tunnels_PathwayMarB: "Orothe Tunnels",
    Scene_Orothe_Tunnels_Whirlpool: "Orothe Tunnels",
    Scene_Orothe_Tunnels_Alcove: "Orothe Tunnels",
    Scene_Orothe_Tunnels_IntersectionCache: "Orothe Tunnels",
    Scene_Orothe_Tunnels_Cache: "Orothe Tunnels",
    Scene_Orothe_Tunnels_VaultEntrance: "Orothe Vault",
    Scene_Orothe_Tunnels_VaultRoom: "Orothe Vault",
    Scene_Orothe_Tunnels_PathwayMarUnderwater: "Orothe Tunnels",
    Scene_Orothe_Ocean_Raft: "Ocean",
    // Set: Shadowhold
    Scene_Core_Shadowhold_Middle_StartCells: "Shadowhold",
    Scene_Core_Shadowhold_Middle_Door: "Shadowhold",
    Scene_Core_Shadowhold_Marina_Start: "Shadowhold",
    Scene_Core_Shadowhold_Marina_FalseIntersection: "Shadowhold",
    Scene_Core_Shadowhold_Marina_Room: "Shadowhold",
    Scene_Core_Shadowhold_Marina_Pathway: "Shadowhold",
    Scene_Core_Shadowhold_Marina_Jump: "Shadowhold Marina",
    Scene_Core_Shadowhold_Middle_FirstPuzzle: "Shadowhold",
    Scene_Core_Shadowhold_Middle_FirstPathway: "Shadowhold",
    Scene_Core_Shadowhold_Middle_FirstIntersection: "Shadowhold",
    Scene_Core_Shadowhold_Middle_NorthPathway_Door: "Shadowhold",
    Scene_Core_Shadowhold_Middle_NorthPathway_Cells: "Shadowhold",
    Scene_Core_Shadowhold_Middle_SouthPathway_Cell: "Shadowhold",
    Scene_Core_Shadowhold_Middle_SouthPathway_ScrewRoom: "Shadowhold",
    Scene_Core_Shadowhold_Middle_EastPathway_Door: "Shadowhold",
    Scene_Core_Shadowhold_Middle_EastPathway_BigPuzzle: "Shadowhold",
    Scene_Core_Shadowhold_Middle_EastPathway_ArrowRoom: "Shadowhold",
    Scene_Core_Shadowhold_Labyrinth_Entrance: "Shadowhold",
    Scene_Core_Shadowhold_Labyrinth_South: "Shadowhold",
    Scene_Core_Shadowhold_Labyrinth_North: "Shadowhold",
    Scene_Core_Shadowhold_Labyrinth_PuzzlePathway: "Shadowhold",
    Scene_Core_Shadowhold_Deep_Cells: "Shadowhold",
    Scene_Core_Shadowhold_Deep_Intersection: "Shadowhold",
    Scene_Core_Shadowhold_Deep_FirstPuzzle: "Shadowhold",
    Scene_Core_Shadowhold_Deep_TwoPuzzles: "Shadowhold",
    Scene_Core_Shadowhold_Deep_SouthPathway: "Shadowhold",
    Scene_Core_Shadowhold_Deep_NorthPathway: "Shadowhold",
    Scene_Core_Shadowhold_Deep_End: "Shadowhold",
    Scene_Core_Smith_Smith: "Core Ringsmith",
    Scene_Core_Smith_Backyard_Entrance: "Core Ringsmith's Playground",
    Scene_Core_Smith_Backyard_Pathway: "Core Ringsmith's Playground",
    Scene_Core_Smith_Backyard_End: "Core Ringsmith's Playground",
    // Set: Core
    Scene_Core_End_Bridge: "Core",
    Scene_Core_End_Agram: "Core Throne Room",
    Scene_Core_End_Entrance: "Core",
    Scene_Core_End_Pathway: "Core",
    Scene_Core_End_Room: "Core",
    Scene_Core_End_Field: "Core",
    Scene_Core_End_Antechamber: "Core",
    // Set: Hidden/Fort
    Scene_Underneath_Mushroom_Room_UNUSED1: "Hacking! Unused Location!",
    Scene_Underneath_Mushroom_Room_UNUSED2: "Hacking! Unused Location!",
    Scene_Underneath_Fort_Outside: "Abandoned Tower",
    Scene_Underneath_Fort_GroundFloorRoom: "Abandoned Tower",
    Scene_Underneath_Fort_SecondFloorRoom_OpenDoor: "Abandoned Tower",
    Scene_Underneath_Fort_SecondFloorRoom_ClosedDoor: "Abandoned Tower",
    Scene_Arderial_Fort_Outside: "Abandoned Tower",
    Scene_Arderial_Fort_UNUSED: "Hacking! Unused Location!",
    Scene_Naroom_Forest_Puzzle_CacheRoom: "Naroom Forest",
    Scene_Naroom_Forest_Puzzle_CacheRoom_BlastRoom: "Naroom Forest",
    Scene_Underneath_Tunnels_Hyren_Entrance: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Hyren_Exit: "Underneath Tunnels",
    Scene_Cald_Caverns_PathwayU_CacheRoom_UNUSED1: "Hacking! Unused Location!",
    Scene_Cald_Caverns_PathwayU_CacheRoom_UNUSED2: "Hacking! Unused Location!",
    Scene_Cald_Caverns_PathwayU_CacheRoom: "East Lava Tubes' Secret Room",
    Scene_Misc_StartScreen_Main: "Start Screen",
    Scene_Misc_StartScreen_Pathway: "Hacking! Unused Location!",
    Scene_Misc_StartScreen_Jukebox: "Hacking! Unused Location!",
    Scene_Underneath_Mushroom_GrukRoom_BasementRoom: "Gruk's Mushroom Farm",
    Scene_Underneath_Mushroom_GrukRoom_TeleportCore: "Gruk's Mushroom Farm",
    Scene_Naroom_Glade_Cave_TeleportCore: "Naroom-Underneath Shortcut",
    Scene_Underneath_Tunnels_Hyren_IntersectionCald: "Underneath Tunnels",
    Scene_Underneath_Tunnels_FortConnectionCacheRoom: "Underneath Tunnels",
    Scene_Naroom_Vash_ChallengeAgovo: "Avoid the Agovos",
    Scene_Underneath_EastTunnel_Intersection_BlastRoom: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Loop_PathwayLoopEndEastCacheIntersections_BlastRoom: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Exit_CacheRoom: "Underneath Tunnels",
    Scene_Underneath_Tunnels_Exit_CacheRoom_RockRoom: "Underneath Tunnels",
    Scene_Misc_Teleport_UNUSED1: "Hacking! Unused Location!",
    Scene_Misc_Teleport_UNUSED2: "Hacking! Unused Location!",
    Scene_Misc_Teleport_UNUSED3: "Hacking! Unused Location!",
    Scene_Arderial_Fort_TeleportNaroom: "Arderial Fort",
    Scene_Naroom_Vash_Sky_TeleportArderialRoom: "Vash Naroom",
    Scene_Core_Smith_TeleportNaroom: "Naroom-Underneath Shortcut",
    Scene_Core_Smith_TeleportUnderneath: "Naroom-Underneath Shortcut",
    // Set: Overworld
    Scene_Overworld_Naroom: "Naroom Overworld",
    Scene_Overworld_Underneath: "Underneath Overworld",
    Scene_Overworld_Cald: "Cald Overworld",
    Scene_Overworld_Orothe: "Orothe Overworld",
    Scene_Overworld_Arderial: "Arderial Overworld",
    // Set: Cald
    Scene_Cald_Geyser_Entrance: "Cald Geyser",
    Scene_Cald_Geyser_PuzzlesA: "Cald Geyser",
    Scene_Cald_Geyser_PuzzlesB: "Cald Geyser",
    Scene_Cald_Geyser_Antechamber: "Cald Geyser",
    Scene_Cald_Geyser_CoreStone: "Cald Geyser",
    Scene_Cald_Volcano_Hyren: "Volcano",
    Scene_Cald_Ashyn_NorthGeyser: "Ashyn",
    Scene_Cald_Ashyn_Center: "Ashyn",
    Scene_Cald_Ashyn_West: "Ashyn",
    Scene_Cald_Ashyn_East: "Ashyn",
    Scene_Cald_Ashyn_SouthBridge: "Ashyn",
    Scene_Cald_Ashyn_Center_HistorianRoom: "Ashyn Historian's House",
    Scene_Cald_Ashyn_Center_ErynRoom: "Eryn and Karyn's House",
    Scene_Cald_Ashyn_Center_AshgarRoom: "Ashgar's House",
    Scene_Cald_Ashyn_East_Room: "Ashyn",
    Scene_Cald_Ashyn_West_InnRoom: "Ashyn Inn",
    Scene_Cald_Ashyn_West_SmithRoom: "Magam's Ring Shop",
    Scene_Cald_Valkan_House: "Valkan's House",
    Scene_Cald_Valkan_Room: "Valkan's House",
    Scene_Cald_Ashyn_UNUSED: "Hacking! Unused Location!",
    Scene_Cald_Caverns_Entrance: "East Lava Tubes",
    Scene_Cald_Caverns_PathwayEntranceHorizontal: "East Lava Tubes",
    Scene_Cald_Caverns_IntersectionX: "East Lava Tubes",
    Scene_Cald_Caverns_PathwayZ: "East Lava Tubes",
    Scene_Cald_Caverns_Pathway7: "East Lava Tubes",
    Scene_Cald_Caverns_PathwayI: "East Lava Tubes",
    Scene_Cald_Caverns_IntersectionTriple: "East Lava Tubes",
    Scene_Cald_Caverns_Detour_Pathway: "East Lava Tubes",
    Scene_Cald_Caverns_Detour_End: "East Lava Tubes",
    Scene_Cald_Caverns_PathwayU: "East Lava Tubes",
    Scene_Cald_Caverns_PathwayExitHorizontal: "East Lava Tubes",
    Scene_Cald_Caverns_Exit: "East Lava Tubes",
    Scene_Cald_Tunnels_Entrance: "West Lava Tubes",
    Scene_Cald_Tunnels_IntersectionNorth: "West Lava Tubes",
    Scene_Cald_Tunnels_PathwayWest: "West Lava Tubes",
    Scene_Cald_Tunnels_PathwayCenter: "West Lava Tubes",
    Scene_Cald_Tunnels_PathwayEast: "West Lava Tubes",
    Scene_Cald_Tunnels_IntersectionExit: "West Lava Tubes",
    Scene_Cald_Vents_PathwayA: "Lava Vents",
    Scene_Cald_Vents_PathwayB: "Lava Vents",
    Scene_Cald_Vents_Intersection: "Lava Vents",
    Scene_Cald_Vents_PathwayIsland: "Lava Vents",
    Scene_Cald_Vents_Island: "Lava Vents",
    Scene_Cald_Vents_BrokenBridge: "Lava Vents",
    Scene_Cald_Vents_Entrance: "Lava Vents",
    Scene_Cald_Vents_BrokenBridgeEnd: "Lava Vents",
    Scene_Cald_Vents_CacheRoomA: "Lava Vents",
    Scene_Cald_Vents_CacheRoomB: "Lava Vents",
    Scene_Cald_Vents_CacheRoomC: "Lava Vents",
    Scene_Cald_Vents_PathwayIsland_RescueRoom: "Lava Vents",
    // Set: Arderial
    Scene_Arderial_Palace_Outside: "Arderial Palace",
    Scene_Arderial_Inn_Outside: "Arderial Inn",
    Scene_Arderial_Historian_Outside: "Arderial Historian",
    Scene_Arderial_Shop_Outside: "Arderial Shop",
    Scene_Arderial_Palace_EntranceRoom: "Arderial Palace",
    Scene_Arderial_Palace_DoubleRoom: "Arderial Palace",
    Scene_Arderial_Palace_SecondFloorRoom: "Arderial Palace",
    Scene_Arderial_Middle_House_BasementRoom: "Hacking! Unused Location!",
    Scene_Arderial_Historian_WestRoom: "Arderial Historian",
    Scene_Arderial_Historian_UpstairsRoom: "Arderial Historian",
    Scene_Arderial_Shop_Room: "Lasada's Ring Shop",
    Scene_Arderial_Historian_EastRoom: "Arderial Historian",
    Scene_Arderial_Geyser_Remix_Arderial_Entrance: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Arderial_KeyMaze: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Underneath_West: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Cald_West: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Underneath_East: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Cald_East: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Cache_East: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Cache_West: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Naroom_West: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Naroom_East: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Orothe_West: "Arderial Geyser",
    Scene_Arderial_Geyser_Remix_Orothe_East: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes1_Entrance: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes1_Entrance_BackroomCache: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes1_StarryCache: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes1_PipeToStarryCache: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes1_MiddlePipeSwitch: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes1_End: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes2_Entrance: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes2_PipeAnalysis: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes2_MiddlePipeSwitch: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes2_End: "Arderial Geyser",
    Scene_Arderial_Geyser_End_GlassMaze: "Arderial Geyser",
    Scene_Arderial_Geyser_End_CoreStone: "Arderial Geyser",
    Scene_Arderial_Geyser_Pipes2_GlassField: "Arderial Geyser",
    Scene_Arderial_Geyser_End_CaldCache: "Arderial Geyser",
    Scene_Arderial_Middle_Entrance: "Middle Clouds",
    Scene_Arderial_Middle_PathwayEntrance: "Middle Clouds",
    Scene_Arderial_Middle_Intersection: "Middle Clouds",
    Scene_Arderial_Middle_PathwayHouse: "Middle Clouds",
    Scene_Arderial_Middle_House: "Middle Clouds",
    Scene_Arderial_Middle_End: "Middle Clouds",
    Scene_Arderial_North_SoutheastEntrance: "North Clouds",
    Scene_Arderial_North_Southwest: "North Clouds",
    Scene_Arderial_North_East: "North Clouds",
    Scene_Arderial_North_Center: "North Clouds",
    Scene_Arderial_North_West: "North Clouds",
    Scene_Arderial_North_Northeast: "North Clouds",
    Scene_Arderial_North_NorthwestExit: "North Clouds",
    Scene_Arderial_Entrance: "Palace Clouds",
    Scene_Arderial_South_North: "South Clouds",
    Scene_Arderial_South_South: "South Clouds",
    Scene_Arderial_Palace_Throneroom: "Arderial Throne Room",
    Scene_Arderial_Inn_Room: "Arderial Inn",
    Scene_Arderial_Geyser_HorizontalPipe_Unused: "Hacking! Unused Location!",
    Scene_Arderial_Geyser_VerticalPipe_Unused: "Hacking! Unused Location!",
    // Set: Misc
    Scene_Misc_Whackamole_Debug: "Hacking! Developer's Warp Zone!",
    Scene_Misc_MagiNationSplashScreen: "Start Screen",
}
// End of autogenerated scene_to_rascript.py

rich_presence_display(
    "Scene: {0} - {1} Script1: {2} Script2: {3} Script3: {4} Script4: {5} Script5: {6}\nScript6: {7}",
    rich_presence_value("SceneID", scene_id(), "VALUE"),
    rich_presence_lookup("SceneName", scene_id(), scene_lookup, "???"),
    rich_presence_value("Script1", get_nth_script_frame(1), "VALUE"),
    rich_presence_value("Script2", get_nth_script_frame(2), "VALUE"),
    rich_presence_value("Script3", get_nth_script_frame(3), "VALUE"),
    rich_presence_value("Script4", get_nth_script_frame(4), "VALUE"),
    rich_presence_value("Script5", get_nth_script_frame(5), "VALUE"),
    rich_presence_value("Script6", get_nth_script_frame(6), "VALUE")
)
achievement(
    title = "X", description = "Debug", points = 0,
    trigger = get_nth_script_frame(4) == 0
)