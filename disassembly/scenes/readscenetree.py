with open('Magi Nation (Japan).gba', 'rb') as f:
    rom = f.read()

treetop = 0x0806F6B0

def get_word(position):
    position -= 0x08000000
    val = 0
    for i in range(3, -1, -1):
        val *= 256
        val += rom[position + i]
    return val

def read_tree(pointer, recursion):
    dir = get_word(pointer)
    sceneid = get_word(pointer + 4)
    sceneobject = get_word(pointer + 8)
    nodecount = get_word(pointer + 12)
    nodepointer = get_word(pointer + 16)
    print('    '*recursion + f'{sceneid:04X} {dir} {sceneobject:04X}')
    if nodecount > 0:
        for i in range(nodecount):
            read_tree(nodepointer + 20*i, recursion + 1)


read_tree(treetop, 0)