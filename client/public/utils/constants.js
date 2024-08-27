export const CLASSES = {
    1: "Barbarian",
    2: "Knight",
    3: "Mage",
    4: "Rogue",
}

export const ENEMY_CLASSES = {
    1: "Mage",
    2: "Minion",
    3: "Rogue",
    4: "Warrior",
}

export const CHARACTERS_MAX_HP = {
    Knight: 100,
    Mage: 100,
    Rogue: 100,
    Barbarian: 100,
    Skeleton_Mage: 80,
    Skeleton_Minion: 60,
    Skeleton_Warrior: 120,
    Skeleton_Rogue: 100,
}

export const ROOM_TYPES = {
    0: "None",
    1: "Monster",
    2: "Fountain",
    3: "Spell",
    4: "Adventurer",
    5: "Burn",
    6: "Boss",
}

export const ELEMENTS = {
    1: 'Fire',
    2: 'Water',
    3: 'Air',
}

export const ELEMENTS_STRENGTH = {
    1: 'Air',
    2: 'Fire',
    3: 'Water',
}

export const ELEMENTS_WEAKNESS = {
    1: 'Water',
    2: 'Air',
    3: 'Fire',
}

export const SPELLS = {
    0: "None",
    1: "Punch",
    2: "Kick",
    3: "Heal",
    4: "Blizzard",
    5: "Burst",
    6: "Fireblade",
    7: "Fireball",
    8: "Holywater",
    9: "Sacrifice",
    10: "Smash",
    11: "Stomp",
    12: "Tornado",
    13: "Volley",
    14: "Waterfall",
    15: "Zephyr",
};

export const SPELLS_EFFECTS = {
    1: [{ type: 'meleeHitSingle', dmg: 20 }], // Punch
    2: [{ type: 'meleeHitSingle', dmg: 30 }], // Kick
    3: [{ type: 'healSelf', hp: 25 }], // Heal
    4: [{ type: 'spellHitAll', dmg: 30 }], // Blizzard
    5: [{ type: 'spellHitAll', dmg: 20 }],//, { type: 'stunSingle', duration: 1 }], // Burst
    6: [{ type: 'spellHitOthers', dmg: 40 }], // Fireblade
    7: [{ type: 'spellHitSingle', dmg: 60 }], // Fireball
    8: [{ type: 'healSelf', hp: 40 }],//, { type: 'healOthers', hp: 10 }], // Holywater
    9: [{ type: 'meleeHitSingle', dmg: 70 }],//, { type: 'meleeHitSelf', dmg: 20 }], // Sacrifice
    10: [{ type: 'meleeHitAll', dmg: 40 }],//, { type: 'stunSingle', duration: 1 }], // Smash
    11: [{ type: 'meleeHitSingle', dmg: 40 }],//, { type: 'stunSingle', duration: 2 }], // Stomp
    12: [{ type: 'spellHitAll', dmg: 30 }], // Tornado
    13: [{ type: 'spellHitSingle', dmg: 40 }],//, { type: 'spellHitOthers', dmg: 20 }], // Volley
    14: [{ type: 'healAll', hp: 30 }], // Waterfall
    15: [{ type: 'healOthers', hp: 30 }], // Zephyr
}