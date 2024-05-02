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
GBA_IWRAM = 0x03000000
RETRO_EWRAM = 0x008000
RETRO_IWRAM = 0x000000
// Maps a GBA memory address to a RetroAchievements memory address
// map(0x03000000) -> 0x000000
// map(0x02000000) -> 0x008000
// EEPROM not implemented
function map(address) {
    if (address < GBA_IWRAM) {
        return address - GBA_EWRAM + RETRO_EWRAM
    } else {
        return address - GBA_IWRAM + RETRO_IWRAM
    }
}

// Dereference an address containing a pointer to IWRAM, where the returned value uses the RetroAchievements memory addressing scheme
function ipointer(address) =>
    tbyte(address) + RETRO_IWRAM

// Dereference an address containing a pointer to EWRAM, where the returned value uses the RetroAchievements memory addressing scheme
function epointer(address) =>
    tbyte(address) + RETRO_EWRAM


// Gets Scene ID via pointer
BaseStruct_SceneRelatedStruct_SceneObjectPointer = map(0x03000A38)
BaseStruct_SceneRelatedStruct_SceneObjectPointer_Offset_SceneID = 0x0C
function scene_id() =>
    word(epointer(BaseStruct_SceneRelatedStruct_SceneObjectPointer) + BaseStruct_SceneRelatedStruct_SceneObjectPointer_Offset_SceneID)

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
