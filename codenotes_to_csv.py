# Build vars.csv

import math
import re
import logging.config
import os

log_var = logging.getLogger('CodeNoteOut')
log_err = logging.getLogger('CodeNoteErr')


def setup_logging():
    var_file = 'temp/vars.csv'
    var_skip = 'temp/var_skip.txt'
    os.remove(var_file)
    os.remove(var_skip)
    config = {
        'version': 1,
        'disable_exiting_loggers': False,
        'formatters': {
            'simple': {
                'format': '%(message)s'
            },
        },
        'handlers': {
            'var': {
                'class': 'logging.FileHandler',
                'formatter': 'simple',
                'filename': var_file,
            },
            'err': {
                'class': 'logging.FileHandler',
                'formatter': 'simple',
                'filename': var_skip,
            },
        },
        'loggers': {
            'CodeNoteOut': {
                'level': 'INFO',
                'handlers': ['var']
            },
            'CodeNoteErr': {
                'level': 'INFO',
                'handlers': ['err']
            },
        },
    }
    logging.config.dictConfig(config)


Script_Treasure = 0x2AB4
Script_SaveBits = 0x2ADC
Script_SaveVars = 0x2B05
GameCount = 0x2B3A

is_bit = re.compile(r'\(?(0x\d\d)\)?')


class CurPos:
    def __init__(self, curpos):
        self.address = curpos - 1
        self.bit = 7


def bitmap(bit):
    return 7 - int(math.log(int(bit, 16), 2))


def bitcheck(curpos, line: str):
    # Check to see if this line defines a bit
    line = line.strip()
    line_with_space = line + ' '  # Dirty workaround to not need to handle the split
    bit, name = line_with_space.split(' ', 1)
    bit_match = is_bit.match(bit)
    if not bit_match:
        return
    # Make sure we don't skip any bits
    bit_string = bit_match.group(1)
    var_bit = bitmap(bit_string)
    # print(f'{var_address:04X}:{var_bit} = {line}')
    assert (var_bit - curpos.bit) % 8 == 1
    # Update the current position
    curpos.bit = var_bit
    if var_bit == 0:
        curpos.address += 1
    var_address = curpos.address
    # Define unused bits
    if bit[0] == '(':
        if curpos.address in [Script_SaveBits - 1, Script_SaveVars - 1]:
            # Skip alignment bytes
            return
        log_var.info(f'UnusedBit_{var_address:04X}_{var_bit},0x{var_address:04X},{var_bit}')
        return

    if not name or '=' not in name:
        log_err.info(f'{var_address:04X}:{var_bit} = Unknown line {line}')
        return
    var_name = name.split('=', 1)[0].strip('?[] ')
    log_var.info(f'{var_name},0x{var_address:04X},{var_bit}')


def varcheck(curpos, line):
    pass


def handle(curpos, line):
    if curpos.address == Script_SaveVars - 1 and curpos.bit == 7:
        curpos.address += 1
        curpos.bit = 0
    if curpos.address < Script_SaveVars:
        bitcheck(curpos, line)
    else:
        varcheck(curpos, line)


def main():
    setup_logging()

    curpos = CurPos(Script_Treasure)

    with open('codenotes_dump.txt', 'r') as f:
        try:
            while True:
                handle(curpos, next(f))
        except StopIteration:
            pass


if __name__ == '__main__':
    main()
