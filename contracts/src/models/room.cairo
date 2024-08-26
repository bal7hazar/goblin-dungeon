// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::constants::{ROOM_MONSTER_COUNT, ROOM_ADVENTURER_COUNT, ADVENTURER_BIT_LENGTH};
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
        Room { dungeon_id, x, y, category: 0, seed: 0 }
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
    }

    #[inline]
    fn pick(self: Room, seed: felt252) -> u8 {
        let mut dice: Dice = DiceTrait::new(ROOM_MONSTER_COUNT, seed);
        // [Compute] Random number between 4 and 6 to pick one of the 3 potential monsters
        dice.roll().into() + 3
    }

    #[inline]
    fn compute_monsters(self: Room) -> Array<Monster> {
        // [Compute] Monster count to place
        let mut dice: Dice = DiceTrait::new(ROOM_MONSTER_COUNT, self.seed);
        let mut count = dice.roll();
        // [Compute] Monster types and distribution
        let mut monsters: Array<Monster> = array![];
        let mut index: u8 = 0;
        loop {
            if count == 0 {
                break;
            };
            // [Compute] Uniform random number between 0 and MULTIPLIER
            let random = Seeder::reseed(self.seed, index.into()).into() % MULTIPLIER;
            let probability: u256 = count.into() * MULTIPLIER / (ROOM_MONSTER_COUNT - index).into();
            // [Check] Probability of being a monster
            if random <= probability {
                // [Compute] Monster attributes
                let random: u256 = dice.seed.into();
                let threat: Threat = ThreatTrait::from(random.low.into());
                let monster: Monster = MonsterTrait::from(threat, random.high.into());
                monsters.append(monster);
                count -= 1;
            } else {
                monsters.append(Monster::None);
            };
            index += 1;
        };
        // [Return] Monsters
        monsters
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
    // Core imports

    use debug::PrintTrait;

    // Local imports

    use super::{Room, RoomTrait, AssertTrait, Monster};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const X: i32 = -5;
    const Y: i32 = 42;
    const SEED: felt252 = 'SEED';
    const RESEED: felt252 = 'RESEED';

    #[test]
    fn test_room_new() {
        let room: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        assert_eq!(room.dungeon_id, DUNGEON_ID);
        assert_eq!(room.x, X);
        assert_eq!(room.y, Y);
    }

    #[test]
    fn test_room_explore() {
        let mut room: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        room.explore(SEED);
        room.assert_is_explored();
    }

    #[test]
    #[should_panic(expected: ('Room: already explored',))]
    fn test_room_explore_twice() {
        let mut room: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        room.explore(SEED);
        room.assert_is_explored();
        room.explore(RESEED);
    }

    #[test]
    fn test_room_compute_monsters() {
        let mut room: Room = RoomTrait::new(DUNGEON_ID, X, Y);
        room.explore(SEED);
        let mut monsters: Array<Monster> = room.compute_monsters();
        let mut sum: u8 = 0;
        while let Option::Some(monster) = monsters.pop_front() {
            sum += monster.into();
        };
        assert_eq!(sum != 0, true);
    }
}

