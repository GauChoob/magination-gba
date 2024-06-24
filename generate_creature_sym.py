for i in range(0x93 + 1):
    #print(f'0x{0x0203C39C - 0x02000000 + 0x008000 + 0x28*i:06X} Creature_0x{i:02X}')
    #print(f'{0x0203C39C + 0x28*i:08X} Creature_0x{i:02X}')
    print(f'N0:0x{0x0203C39C - 0x02000000 + 0x008000 + 0x28*i:06X}:"InventoryStruct.Rings.Creature_{i:02X} [40 bytes]"') # N0:0x044414:"InventoryStruct.Rings.Creature_03 [40 bytes]"
    #print(f'0x{0x0203C39C - 0x02000000 + 0x008000 + 0x28*i:06X} InventoryStruct.Rings.Creature_{i:02X} [40 bytes]')