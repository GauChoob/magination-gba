import struct
import os
import png
from collections import defaultdict


def coll_reference(file):
    width, height, pixels, metadata = png.Reader(file).read()
    assert width == 128
    assert height == 128
    pixels = list(pixels)
    if metadata['planes'] == 4:
        pixels = [[color for i, color in enumerate(row) if i % 4 != 3] for row in pixels]  # Remove alpha channel
    collset = []
    for i in range(0x10):
        for j in range(0x10):
            colltile = [pixels[i*8 + y][j*8*3:j*8*3 + 8*3] for y in range(8)]
            collset.append(colltile)
    return collset


collset = coll_reference('scene_render/Collision.png')
interactset = coll_reference('scene_render/Hotspot.png')


def process_color(word: int) -> tuple[int, int, int, int]:
    r = word & 0b11111
    g = (word & 0b1111100000) >> 5
    b = (word & 0b111110000000000) >> 10
    a = (word & 0b1000000000000000) >> 15
    return r*8, g*8, b*8#, 0 if a else 255


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


def process_tilemap(width: int, height: int, data: bytes) -> list[list[Tile]]:
    return [[Tile(data[2*(row*width + column)] + 256*data[2*(row*width + column) + 1]) for column in range(width)] for row in range(height)]


# Represent the tileset by incrementing from 0x000 to 0x3FF
tileset_tilemap = [[Tile(row*0x20 + column) for column in range(0x20)] for row in range(0x20)]


def render_tilemap(tileset, tilemap, palette) -> list[list[int]]:
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


class CollTile:
    def __init__(self, collid, interactid):
        self.collid = collid
        self.interactid = interactid

    def __repr__(self):
        return f'{self.collid:02X}:{self.interactid:02X}'


def process_collmap(width: int, height: int, data: bytes) -> list[list[CollTile]]:
    return [[CollTile(data[2*(row*width + column)], data[2*(row*width + column) + 1]) for column in range(width)] for row in range(height)]


def render_collmap(collmap) -> list[list[int]]:
    height = len(collmap)
    width = len(collmap[0])

    def map_collset(row, column):
        tile = collmap[row//8][column//8]
        return collset[tile.collid][row % 8]

    collids = [[map_collset(row, column) for column in range(0, width*8, 8)] for row in range(height*8)]
    collids = [[num for pixel in row for num in pixel] for row in collids]  # Flatten

    return collids


def render_interactmap(collmap) -> list[list[int]]:
    height = len(collmap)
    width = len(collmap[0])
    
    def map_interactset(row, column):
        tile = collmap[row//8][column//8]
        return interactset[tile.interactid][row % 8]

    interactids = [[map_interactset(row, column) for column in range(0, width*8, 8)] for row in range(height*8)]
    interactids = [[num for pixel in row for num in pixel] for row in interactids]  # Flatten

    return interactids


def combine_collinteract(collids, interactids):
    for i in range(len(collids)):
        for j in range(len(collids[0])//3):
            if interactids[i][j*3] + interactids[i][j*3 + 1] + interactids[i][j*3 + 2] == 255*3:
                continue
            collids[i][j*3] = collids[i][j*3]//2 + interactids[i][j*3]//2
            collids[i][j*3 + 1] = collids[i][j*3 + 1]//2 + interactids[i][j*3 + 1]//2
            collids[i][j*3 + 2] = collids[i][j*3 + 2]//2 + interactids[i][j*3 + 2]//2
    return collids

class SceneFile:

    def save_palette(self):
        with open(self.get_path('pal'), 'wb') as f:
            w = png.Writer(width=16, height=16, bitdepth=8, palette=self.palette)
            w.write(f, [[16*j + i for i in range(16)] for j in range(16)])

    def save_tileset(self):
        with open(self.get_path('tileset'), 'wb') as f:
            w = png.Writer(width=256, height=256, alpha=False)
            w.write(f, render_tilemap(self.tileset, tileset_tilemap, self.palette))

    def save_tilemap(self):
        with open(self.get_path('map'), 'wb') as f:
            w = png.Writer(width=self.width*8, height=self.height*8, alpha=False)
            self.rendered_tilemap = render_tilemap(self.tileset, self.tilemap, self.palette)
            w.write(f, self.rendered_tilemap)

    def save_collmap(self):
        with open(self.get_path('coll'), 'wb') as f:
            w = png.Writer(width=self.width*8, height=self.height*8, alpha=False)
            self.rendered_collmap = render_collmap(self.collmap)
            combined = [[sum(pixels)//2 for pixels in zip(*pairs)] for pairs in zip(self.rendered_tilemap, self.rendered_collmap)]
            w.write(f, combined)

    def save_interactmap(self):
        with open(self.get_path('hot'), 'wb') as f:
            w = png.Writer(width=self.width*8, height=self.height*8, alpha=False)
            self.rendered_interactmap = render_interactmap(self.collmap)
            combined = [[sum(pixels)//2 for pixels in zip(*pairs)] for pairs in zip(self.rendered_tilemap, self.rendered_interactmap)]
            w.write(f, combined)
    
    def save_overlaymap(self):
        with open(self.get_path('cmap'), 'wb') as f:
            w = png.Writer(width=self.width*8, height=self.height*8, alpha=False)
            combined = combine_collinteract(self.rendered_collmap, self.rendered_interactmap)
            combined = [[sum(pixels)//2 for pixels in zip(*pairs)] for pairs in zip(self.rendered_tilemap, combined)]
            w.write(f, combined)

    def analyze_collmap(self):
        collids = defaultdict(lambda: 0)
        interactids = defaultdict(lambda: 0)
        for row in self.collmap:
            for tile in row:
                collids[tile.collid] += 1
                interactids[tile.interactid] += 1
        def print_sorted(ids):
            def sort_func(item):
                return item[1]
            sorted_list = sorted(ids.items(), key=sort_func, reverse=True)
            for item in sorted_list:
                print(f'0x{item[0]:02X}: {item[1]}')
        print('Coll IDs')
        print_sorted(collids)
        print('Interact IDs')
        print_sorted(interactids)


    def get_path(self, extension):
        os.makedirs(f'temp/{extension}/', exist_ok=True)
        return f'temp/{extension}/scene_{self.scene_id:03}.{extension}.png'

    def make_folder(self):
        os.makedirs('temp/', exist_ok=True)

    def __init__(self, path):
        with open(path, 'rb') as f:
            self.scene_id, self.width, self.height = struct.unpack('<iii', f.read(12))
            self.palette: list[tuple[int, int, int, int]] = process_palette(f.read(0x200))
            self.tileset: list[list[int]] = process_tileset(f.read(0x8000))
            self.tilemap: list[list[Tile]] = process_tilemap(self.width, self.height, f.read(2*self.width*self.height))
            self.collmap: list[list[CollTile]] = process_collmap(self.width, self.height, f.read(2*self.width*self.height))
        self.make_folder()
        #self.save_palette()
        #self.save_tileset()
        self.save_tilemap()
        #self.analyze_collmap()
        self.save_collmap()
        self.save_interactmap()
        self.save_overlaymap()

for i in range(0x398):
    file = f'scene_render/raw/scene_{i:04X}.bin'
    if os.path.exists(file):
        print(i)
        SceneFile(file)