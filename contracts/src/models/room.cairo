// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::constants::{
    MAX_MONSTER_COUNT, MONSTER_BIT_LENGTH, ATTRIBUTE_BIT_LENGTH, MONSTER_MAX_POWER,
    ROOM_ADVENTURER_COUNT, ADVENTURER_BIT_LENGTH
};
use rpg::models::index::Room;
use rpg::helpers::seeder::Seeder;
use rpg::helpers::packer::Packer;
use rpg::helpers::dice::{Dice, DiceTrait};
use rpg::types::category::{Category, CategoryTrait};
use rpg::types::monster::{Monster, MonsterTrait};
use rpg::types::element::{Element, ElementTrait};
use rpg::types::spell::{Spell, SpellTrait};
use rpg::types::threat::{Threat, ThreatTrait};
use rpg::types::item::{Item, ItemTrait};
use rpg::types::role::{Role, RoleTrait};

// Constants

const MULTIPLIER: u256 = 100;

// Errors

mod errors {
    const ROOM_INVALID_SEED: felt252 = 'Room: invalid seed';
    const ROOM_NOT_EXPLORED: felt252 = 'Room: not explored';
    const ROOM_ALREADY_EXPLORED: felt252 = 'Room: already explored';
}

#[generate_trait]
impl RoomImpl of RoomTrait {
    #[inline]
    fn new(dungeon_id: u32, x: i32, y: i32) -> Room {
        Room { dungeon_id, x, y, category: 0, item: 0, monsters: 0, adventurers: 0, seed: 0 }
    }

    #[inline]
    fn is_explored(self: Room) -> bool {
        self.seed != 0
    }

    #[inline]
    fn explore(ref self: Room, seed: felt252) {
        // [Check] Not already explored
        self.assert_not_explored();
        // [Check] Seed is valid
        assert(seed != 0, errors::ROOM_INVALID_SEED);
        // [Effect] Update the seed
        self.seed = seed;
        // [Effect] Define category
        let category: Category = CategoryTrait::from(seed);
        self.category = category.into();
        match category {
            Category::Monster => { self.monsters = self.compute_monsters(seed); },
            Category::Item => { self.item = self.compute_item(seed); },
            _ => {},
        }
    }

    #[inline]
    fn compute_item(self: Room, seed: felt252) -> u8 {
        let mut dice: Dice = DiceTrait::new(ItemTrait::count(), seed);
        dice.roll().into()
    }

    #[inline]
    fn compute_monsters(self: Room, seed: felt252) -> u128 {
        // [Compute] Monster count to place
        let mut dice: Dice = DiceTrait::new(MAX_MONSTER_COUNT, seed);
        let mut count = dice.roll();
        // [Compute] Monster types and distribution
        let mut monsters: Array<u32> = array![];
        let mut index: u8 = 0;
        loop {
            if count == 0 {
                break;
            };
            // [Compute] Uniform random number between 0 and MULTIPLIER
            let random = Seeder::reseed(seed, index.into()).into() % MULTIPLIER;
            let probability: u256 = count.into() * MULTIPLIER / (MAX_MONSTER_COUNT - index).into();
            // [Check] Probability of being a monster
            if random <= probability {
                // [Compute] Monster attributes
                dice.face_count = MonsterTrait::count();
                let monster: Monster = dice.roll().into();
                dice.face_count = ElementTrait::count();
                let element: Element = dice.roll().into();
                let threat: Threat = ThreatTrait::from(dice.seed);
                let spell: Spell = monster.spell();
                // [Compute] Pack monster attributes
                let attributes: Array<u8> = array![
                    monster.into(), element.into(), threat.into(), spell.into()
                ];
                monsters.append(Packer::pack(attributes, ATTRIBUTE_BIT_LENGTH));
                count -= 1;
            } else {
                monsters.append(0);
            };
            index += 1;
        };
        // [Compute] Return a packed array of monsters
        Packer::pack(monsters, MONSTER_BIT_LENGTH)
    }

    #[inline]
    fn compute_adventurers(self: Room, seed: felt252) -> u128 {
        // [Compute] Adventurer atributes and distribution
        let mut dice: Dice = DiceTrait::new(RoleTrait::count(), seed);
        let mut adventurers: Array<u8> = array![];
        let mut count = ROOM_ADVENTURER_COUNT;
        loop {
            if count == 0 {
                break;
            };
            dice.face_count = RoleTrait::count();
            adventurers.append(dice.roll().into());
            dice.face_count = ElementTrait::count();
            adventurers.append(dice.roll().into());
            count -= 1;
        };
        // [Compute] Return a packed array of adventurers
        Packer::pack(adventurers, ADVENTURER_BIT_LENGTH)
    }
}

#[generate_trait]
impl RoomAssert of AssertTrait {
    #[inline]
    fn assert_is_explored(self: Room) {
        assert(self.is_explored(), errors::ROOM_NOT_EXPLORED);
    }

    #[inline]
    fn assert_not_explored(self: Room) {
        assert(!self.is_explored(), errors::ROOM_ALREADY_EXPLORED);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Room, RoomTrait, AssertTrait};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const X: i32 = -5;
    const Y: i32 = 42;
    const SEED: felt252 = 'SEED';
    const RESEED: felt252 = 'RESEED';

    #[test]
    fn test_room_new() {
        let dungeon: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        assert_eq!(dungeon.dungeon_id, DUNGEON_ID);
        assert_eq!(dungeon.x, X);
        assert_eq!(dungeon.y, Y);
    }

    #[test]
    fn test_dungeon_explore() {
        let mut dungeon: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        dungeon.explore(SEED);
        dungeon.assert_is_explored();
    }

    #[test]
    #[should_panic(expected: ('Room: already explored',))]
    fn test_dungeon_explore_twice() {
        let mut dungeon: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        dungeon.explore(SEED);
        dungeon.assert_is_explored();
        dungeon.explore(RESEED);
    }
}

