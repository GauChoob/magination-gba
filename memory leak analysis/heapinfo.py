import sys

BASE_ADDRESS = 0x02000000
HEAP_START = 0x02000400


def parse(heap, address):
    address -= BASE_ADDRESS
    return sum([heap[address + i]*pow(256, i) for i in range(4)])


class Chunk:
    def __init__(self, heap, address):
        self.heap = heap
        self.address = address
        self.next = parse(heap, address)
        self.prev = parse(heap, address + 4)
        self.unk = parse(heap, address + 8)
        if self.unk != 0:
            print(f'{self.unk:08X}')
        self.size = parse(heap, address + 12)
    
    def next_chunk(self):
        if self.next < 0x03000000:
            return Chunk(self.heap, self.next)
        return None

    def __repr__(self):
        return f'Chunk @ {self.address:08X}, Size = {self.size:08X}'


def analyze(file):
    with open(file, 'rb') as f:
        heap = f.read()
    chunk = Chunk(heap, HEAP_START)
    while type(chunk) is Chunk:
        print(chunk)
        chunk = chunk.next_chunk()


if __name__ == '__main__':
    if len(sys.argv) == 2:
        analyze(sys.argv[1])
