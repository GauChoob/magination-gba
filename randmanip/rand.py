
import csv

class Rand:
    max_int = 2**32

    def __init__(self, value=0xDEADBEEF, previous_value=0x04191961, index=0):
        self.value = value
        self.previous_value = previous_value
        self.index = index

    def next(self):
        r1 = self.value
        r0 = self.previous_value
        r0 = r0 << 1
        if r0 >= self.max_int:
            r0 -= self.max_int
        r0 ^= r1
        if r1 & 0x80000000:
            r0 ^= 1
        self.value = r0
        self.previous_value = r1
        self.index += 1
        return self.value
    
    def rand(self, modulo):
        return self.next() % modulo

# Just steal the datafile from the GBC and hope that it matches the GBA data
def creature_table(filename):
    creatures = {}
    with open(filename, 'r') as f:
        f_csv = csv.reader(f, delimiter=',')
        for row in f_csv:
            if row[0] != ' Creature_Table_Row':
                continue
            creatures[row[1]] = {
                'type': row[2],
                'energy': int(row[3]),
                'strength': int(row[6]),
                'skill': int(row[7]),
                'speed': int(row[8]),
                'defense': int(row[9]),
                'resist': int(row[10]),
                'luck': int(row[11]),
                'ability1': row[20],
                'ability2': row[21],
                'ability3': row[22],
                'ability4': row[23],
                'abilitylevel1': int(row[24]),
                'abilitylevel2': int(row[25]),
                'abilitylevel3': int(row[26]),
                'abilitylevel4': int(row[27]),
            }
    return creatures



class Creature:
    level_up_tables = {
        'weak': [0, 0, 1, 1, 1, 1, 0, 0, 2, 0],
        'medium': [0, 2, 1, 1, 1, 1, 0, 0, 2, 0],
        'strong': [0, 3, 1, 1, 1, 1, 0, 1, 2, 0],
    }
    def_resist_lookup = {
        'SMALL': 'weak',
        'MEDIUM': 'medium',
        'LARGE': 'strong',
        'WEAK': 'weak',
        'STRONG': 'strong',
    }
    speed_skill_lookup = {
        'SMALL': 'strong',
        'MEDIUM': 'medium',
        'LARGE': 'weak',
        'WEAK': 'weak',
        'STRONG': 'strong',
    }

    def __init__(self, creature, level, rand):
        self.level = 1
        self.size = creature['type']
        self.energy = creature['energy']
        self.strength = creature['strength']
        self.skill = creature['skill']
        self.speed = creature['speed']
        self.defense = creature['defense']
        self.resist = creature['resist']
        self.luck = creature['luck']
        self.abilities = [creature['ability1'], creature['ability2'], creature['ability3'], creature['ability4']]
        self.ability_levels = [creature['abilitylevel1'], creature['abilitylevel2'], creature['abilitylevel3'], creature['abilitylevel4']]
        for i in range(level - 1):
            self.level_up(rand)

    def level_up(self, rand):
        self.level += 1
        rand.next()
        self.energy += 1 + rand.rand(4)
        self.strength += [1, 2, 1, 2, 0, 3, 2, 1][rand.rand(8)]
        self.skill += self.level_up_tables[self.speed_skill_lookup[self.size]][rand.rand(10)]
        self.speed += self.level_up_tables[self.speed_skill_lookup[self.size]][rand.rand(10)]
        self.defense += self.level_up_tables[self.def_resist_lookup[self.size]][rand.rand(10)]
        self.defense += rand.rand(2)
        self.resist += self.level_up_tables[self.def_resist_lookup[self.size]][rand.rand(10)]
        self.resist += rand.rand(2)
        unlock_level = self.level + self.roll_luck(10, rand)
        for i in range(4):
            target_level = self.ability_levels[i]
            if target_level == 0xFF:
                continue
            if unlock_level <= target_level:
                self.ability_levels[i] = 0xFF
                break

    # Table taken from GBA
    luck_table = [0,1,1,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,5,5,5,6,6,7,7,8,8,9,0xA,0xA,0xB,0xB,0xC,0xD,0xE,0xE,0xF,0x10,0x11,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,0x1B,0x1C,0x1D,0x1E,0x1F,0x20,0x21,0x22,0x24,0x25,0x26,0x27,0x29,0x2A,0x2B,0x2C,0x2E,0x2F,0x31,0x32,0x33,0x35,0x36,0x38,0x39,0x3B,0x3C,0x3E,0x40,0x41,0x43,0x44,0x46,0x48,0x49,0x4B,0x4D,0x4F,0x51,0x52,0x54,0x56,0x58,0x5A,0x5C,0x5E,0x60,0x62,0x63]
    def roll_luck(self, magnitude, rand):
        max = magnitude*self.luck_table[self.luck]//99
        return rand.rand(255)*(2*max + 1)//255 - max
    
    def __str__(self):
        abilities_str = ', '.join(f"{ability} (level {level})" for ability, level in zip(self.abilities, self.ability_levels))
        return (
            f"Size: {self.size}\n"
            f"Level: {self.level}\n"
            f"Energy: {self.energy}\n"
            f"Strength: {self.strength}\n"
            f"Skill: {self.skill}\n"
            f"Speed: {self.speed}\n"
            f"Defense: {self.defense}\n"
            f"Resist: {self.resist}\n"
            f"Luck: {self.luck}\n"
            f"Abilities: {abilities_str}"
        )

rand = Rand()
creatures = creature_table('randmanip/creature_table.csv')
hyren = Creature(creatures['Leaf_Hyren'], 50, rand)
print(hyren)