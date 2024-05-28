import struct
import os
import png

def process_color(word: int) -> tuple[int, int, int, int]:
    r = word & 0b11111
    g = (word & 0b1111100000) >> 5
    b = (word & 0b111110000000000) >> 10
    a = (word & 0b1000000000000000) >> 15
    return r*8, g*8, b*8, 0 if a else 255


def process_palette(data: bytes) -> list[tuple[int, int, int, int]]:
    assert len(data) % 2 == 0
    return [process_color(data[i] + 256*data[i + 1]) for i in range(0, len(data), 2)]


def process_tileset(data: bytes) -> list[list[int]]:
    tileset = [[0 for pixel in range(0x40)] for tile in range(0x400)]
    for tile in range(0x400):
        for byte in range(0, 0x20):
            datum = data[tile*0x20 + byte]
            tileset[tile][byte*2] = (datum & 0b11110000) >> 4
            tileset[tile][byte*2 + 1] = datum & 0b00001111
    return tileset


class SceneFile:

    def save_palette(self):
        with open(self.get_path() + '.pal.png', 'wb') as f:
            w = png.Writer(width=16, height=16, bitdepth=8, palette=self.palette)
            w.write(f, [[16*j + i for i in range(16)] for j in range(16)])

    def save_tileset(self):
        with open(self.get_path() + '.tileset.png', 'wb') as f:
            w = png.Writer(width=256, height=256, bitdepth=8, palette=self.palette)
            w.write(f, [[self.tileset[row//8 + column//8*0x20][column % 8 + (row % 8)*8] for column in range(0x100)] for row in range(0x100)])

    def get_path(self):
        return f'temp/scene_{self.scene_id:04X}'

    def make_folder(self):
        os.makedirs('temp/', exist_ok=True)

    def __init__(self, path):
        with open(path, 'rb') as f:
            self.scene_id, self.width, self.height = struct.unpack('<iii', f.read(12))
            self.palette: list[tuple[int, int, int, int]] = process_palette(f.read(0x200))
            self.tileset: list[list[int]] = process_tileset(f.read(0x8000))
        print(self.tileset)
        self.make_folder()
        self.save_palette()
        self.save_tileset()

SceneFile('../mGBA-0.10.3-win64/scene_00F3.bin')