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
rich_presence_display(
    "SceneID: {0}\nScript: {1}",
    rich_presence_value("SceneID", scene_id(), "VALUE"),
    rich_presence_value("Script1", get_nth_script_frame(1), "VALUE"),
    rich_presence_value("Script1", get_nth_script_frame(2), "VALUE"),
    rich_presence_value("Script1", get_nth_script_frame(3), "VALUE"),
    rich_presence_value("Script1", get_nth_script_frame(4), "VALUE"),
    rich_presence_value("Script1", get_nth_script_frame(5), "VALUE"),
    rich_presence_value("Script1", get_nth_script_frame(6), "VALUE")
)
achievement(
    title = "X", description = "Debug", points = 0,
    trigger = get_nth_script_frame(4) == 0
)