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
            tileset[tile][byte*2] = datum & 0b00001111
            tileset[tile][byte*2 + 1] = (datum & 0b11110000) >> 4
    return tileset


class Tile:
    def __init__(self, datum):
        self.tileid = (datum & 0b00000011_11111111)
        self.hflip = (datum & 0b00000100_00000000) >> 10
        self.vflip = (datum & 0b00001000_00000000) >> 11
        self.paletteid = (datum & 0b11110000_00000000) >> 12

    def __repr__(self):
        return f'{self.tileid:03X}'


def process_tilemap(width: int, height: int, data: bytes):
    return [[Tile(data[2*(row*width + column)] + 256*data[2*(row*width + column) + 1]) for column in range(width)] for row in range(height)]


tileset_tilemap = [[Tile(row*0x20 + column) for column in range(0x20)] for row in range(0x20)]


def render_tilemap(tileset, tilemap, palette):
    height = len(tilemap)
    width = len(tilemap[0])

    def map_pixel(row, column):
        tile = tilemap[row//8][column//8]
        x = column % 8 if not tile.hflip else 7 - column % 8
        y = row % 8 if not tile.vflip else 7 - row % 8
        return palette[tile.paletteid*0x10 + tileset[tile.tileid][y*8 + x]]
    ret = [[map_pixel(row, column) for column in range(width*8)] for row in range(height*8)]
    ret = [[num for pixel in row for num in pixel] for row in ret]  # Flatten palette tuples
    return ret


class SceneFile:

    def save_palette(self):
        with open(self.get_path() + '.pal.png', 'wb') as f:
            w = png.Writer(width=16, height=16, bitdepth=8, palette=self.palette)
            w.write(f, [[16*j + i for i in range(16)] for j in range(16)])

    def save_tileset(self):
        with open(self.get_path() + '.tileset.png', 'wb') as f:
            w = png.Writer(width=256, height=256, alpha=True)
            w.write(f, render_tilemap(self.tileset, tileset_tilemap, self.palette))

    def save_tilemap(self):
        with open(self.get_path() + '.map.png', 'wb') as f:
            w = png.Writer(width=self.width*8, height=self.height*8, alpha=True)
            w.write(f, render_tilemap(self.tileset, self.tilemap, self.palette))

    def get_path(self):
        return f'temp/scene_{self.scene_id:04X}'

    def make_folder(self):
        os.makedirs('temp/', exist_ok=True)

    def __init__(self, path):
        with open(path, 'rb') as f:
            self.scene_id, self.width, self.height = struct.unpack('<iii', f.read(12))
            self.palette: list[tuple[int, int, int, int]] = process_palette(f.read(0x200))
            self.tileset: list[list[int]] = process_tileset(f.read(0x8000))
            self.tilemap: list[list[Tile]] = process_tilemap(self.width, self.height, f.read(2*self.width*self.height))
            self.collmap: list[list[Tile]] = process_tilemap(self.width, self.height, f.read(2*self.width*self.height))
        self.make_folder()
        self.save_palette()
        self.save_tileset()
        self.save_tilemap()
        #self.save_collmap()


SceneFile('../mGBA-0.10.3-win64/scene_00F3.bin')