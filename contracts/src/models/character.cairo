// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::constants::ATTRIBUTE_BIT_LENGTH;
use rpg::models::index::Character;
use rpg::types::direction::Direction;
use rpg::types::role::{Role, RoleTrait};
use rpg::types::class::{Class, ClassTrait};
use rpg::types::element::{Element, ElementTrait};
use rpg::types::spell::{Spell, SpellTrait};
use rpg::types::monster::{Monster, MonsterTrait};
use rpg::types::threat::{Threat, ThreatTrait};
use rpg::helpers::packer::Packer;
use rpg::helpers::seeder::Seeder;

mod errors {
    const CHARACTER_NOT_EXIST: felt252 = 'Character: does not exist';
    const CHARACTER_ALREADY_EXIST: felt252 = 'Character: already exist';
    const CHARACTER_INVALID_DIRECTION: felt252 = 'Character: invalid direction';
    const CHARACTER_IS_DEAD: felt252 = 'Character: is dead';
    const CHARACTER_NOT_DEAD: felt252 = 'Character: not dead';
}

#[generate_trait]
impl CharacterImpl of CharacterTrait {
    #[inline]
    fn new(dungeon_id: u32, team_id: u32, index: u8, class: Class, element: Element) -> Character {
        // [Return] Character
        Character {
            dungeon_id,
            team_id,
            index,
            class: class.into(),
            element: element.into(),
            spell: class.base().into(),
            health: class.health(),
            shield: 0,
            stun: 0,
            multiplier: 1,
        }
    }

    #[inline]
    fn from(dungeon_id: u32, team_id: u32, index: u8, packed: u32) -> Character {
        let mut unpacked: Array<u8> = Packer::unpack(packed, ATTRIBUTE_BIT_LENGTH);
        let monster: Monster = unpacked.pop_front().unwrap().into();
        let element: Element = unpacked.pop_front().unwrap().into();
        // TODO: Probably useless if we switch into a db of monsters with unique ids
        let _threat: Threat = unpacked.pop_front().unwrap().into();
        let _spell: Spell = unpacked.pop_front().unwrap().into();
        Self::new(dungeon_id, team_id, index, monster.into(), element)
    }

    #[inline]
    fn setup(ref self: Character) {
        let class: Class = self.class.into();
        let monster: Monster = class.into();
        self.spell = monster.spell().into();
    }

    #[inline]
    fn clean(ref self: Character) {
        self.class = 0;
        self.element = 0;
        self.spell = 0;
        self.health = 0;
        self.shield = 0;
        self.stun = 0;
        self.multiplier = 0;
    }

    #[inline]
    fn is_dead(self: Character) -> bool {
        self.health == 0
    }

    #[inline]
    fn is_stun(self: Character) -> bool {
        self.stun > 0
    }

    #[inline]
    fn take(ref self: Character, damage: u8) {
        if self.is_dead() {
            return;
        }
        let absorbed = core::cmp::min(damage, self.shield);
        self.shield -= absorbed;
        self.health -= core::cmp::min(damage - absorbed, self.health);
    }

    #[inline]
    fn perform(
        ref self: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        if self.is_stun() || self.is_dead() {
            return;
        }
        let spell: Spell = self.spell.into();
        spell.apply(ref self, ref target, ref mates, ref foes);
    }

    #[inline]
    fn heal(ref self: Character, heal: u8) {
        if self.is_dead() {
            return;
        }
        let class: Class = self.class.into();
        self.health += core::cmp::min(heal, class.health() - self.health);
    }

    #[inline]
    fn stun(ref self: Character, quantity: u8) {
        if self.is_dead() {
            return;
        }
        self.stun += quantity;
    }

    #[inline]
    fn shield(ref self: Character, quantity: u8) {
        if self.is_dead() {
            return;
        }
        self.shield += quantity;
    }

    #[inline]
    fn buff(ref self: Character, multiplier: u8) {
        self.multiplier = multiplier;
    }

    #[inline]
    fn debuff(ref self: Character) {
        self.multiplier = 1;
    }

    #[inline]
    fn update(ref self: Character, spell: Spell) {
        self.spell = spell.into();
    }

    #[inline]
    fn finish(ref self: Character) {
        let class: Class = self.class.into();
        self.spell = class.base().into();
        self.stun -= core::cmp::min(self.stun, 1);
    }
}

#[generate_trait]
impl CharacterAssert of AssertTrait {
    #[inline]
    fn assert_not_dead(self: Character) {
        assert(self.health != 0, errors::CHARACTER_IS_DEAD);
    }

    #[inline]
    fn assert_is_dead(self: Character) {
        assert(self.health == 0, errors::CHARACTER_NOT_DEAD);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Character, CharacterTrait, CharacterAssert, Class, ClassTrait, Element, Spell};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const TEAM_ID: u32 = 42;
    const INDEX: u8 = 0;
    const CLASS: Class = Class::Knight;
    const ELEMENT: Element = Element::Fire;

    #[test]
    fn test_character_new() {
        let character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        assert_eq!(character.dungeon_id, DUNGEON_ID);
        assert_eq!(character.team_id, TEAM_ID);
        assert_eq!(character.index, INDEX);
        assert_eq!(character.class, CLASS.into());
        assert_eq!(character.element, ELEMENT.into());
        assert_eq!(character.spell, Spell::Damage.into());
        assert_eq!(character.health, CLASS.health());
        assert_eq!(character.shield, 0);
        assert_eq!(character.stun, 0);
        assert_eq!(character.multiplier, 1);
    }

    #[test]
    fn test_character_is_stun() {
        let character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        assert_eq!(character.is_stun(), false);
    }

    #[test]
    fn test_character_take() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.take(10);
        assert_eq!(character.health, CLASS.health() - 10);
    }

    #[test]
    fn test_character_heal() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.take(10);
        character.heal(5);
        assert_eq!(character.health, CLASS.health() - 5);
    }

    #[test]
    fn test_character_stun() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.stun(1);
        assert_eq!(character.stun, 1);
    }

    #[test]
    fn test_character_shield() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.shield(5);
        assert_eq!(character.shield, 5);
    }

    #[test]
    fn test_character_update() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.update(Spell::Stun);
        assert_eq!(character.spell, Spell::Stun.into());
    }

    #[test]
    fn test_character_finish() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.stun(1);
        character.finish();
        assert_eq!(character.stun, 0);
        assert_eq!(character.spell, Spell::Damage.into());
    }

    #[test]
    #[should_panic(expected: ('Character: is dead',))]
    fn test_character_assert_not_dead() {
        let mut character = CharacterTrait::new(DUNGEON_ID, TEAM_ID, INDEX, CLASS, ELEMENT);
        character.health = 0;
        character.assert_not_dead();
    }
}

