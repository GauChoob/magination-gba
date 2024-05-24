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

// We use dword and subtract GBA_EWRAM or GBA_IWRAM so that
// null pointers point outside of the addressing scheme and return a value of 0
// If we use tbyte and just add an offset null pointers will resolve a value from
// the beginning of the memory map, which leaks random data

// Dereference an address containing a pointer to the heap
function pointer(address, offset) =>
    dword(address) - GBA_EWRAM + RETRO_EWRAM + offset
// Dereference an address containing a pointer to IWRAM
//function ipointer(address, offset) =>
//    dword(address) - GBA_IWRAM + RETRO_IWRAM + offset


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
    "SceneID: {0}",
    rich_presence_value("SceneID", scene_id(), "VALUE")
)
