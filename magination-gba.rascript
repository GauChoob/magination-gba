// Magi Nation
// #ID = 13941

// Gameboy Advance Memory map: https://github.com/RetroAchievements/rcheevos/blob/develop/src/rcheevos/consoleinfo.c#L449


// Converts a pointer from GBA memory addressing space to the RetroAchievements addressing scheme
EWRAM = 0x02000000 - 0x00008000
IWRAM = 0x03000000
function map(pointer, wram) =>
    pointer - wram

// Gets Scene ID via pointer
BaseStruct_SceneRelatedStruct_SceneObjectPointer = 0x000A38
BaseStruct_SceneRelatedStruct_SceneObjectPointer_Offset_SceneID = 0x0C
function scene_id() =>
    word(map(dword(BaseStruct_SceneRelatedStruct_SceneObjectPointer), EWRAM) + BaseStruct_SceneRelatedStruct_SceneObjectPointer_Offset_SceneID)

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
