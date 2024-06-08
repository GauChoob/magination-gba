import sys
import re

pattern = re.compile(r'^[0-9A-F]{8} ')


# Map GBA addresses to retroachievement addresses

def convert(text):
    if not pattern.match(text):
        return text
    address = int(text[:8], base=16)
    if address < 0x02000000 or address > 0x03008000:
        return text
    if address < 0x03000000:
        address -= 0x02000000 - 0x8000
    else:
        address -= 0x03000000
    return f'{address:08X}{text[8:]}'


def parse_file(fin, fout):
    with open(fin, 'r') as f:
        with open(fout, 'w') as g:
            for line in f:
                g.write(convert(line))


if __name__ == '__main__':
    if len(sys.argv) == 1:
        while True:
            print(convert(input('Write text to convert\n')))
    elif len(sys.argv) == 2:
        parse_file(sys.argv[1], 'temp/tmp.txt')
    elif len(sys.argv) == 3:
        parse_file(sys.argv[1], sys.argv[2])
    else:
        print("Invalid arguments (provide none, or input + output files)")