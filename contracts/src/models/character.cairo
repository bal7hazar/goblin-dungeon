// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::models::index::Character;
use rpg::types::direction::Direction;
use rpg::types::role::{Role, RoleTrait};
use rpg::types::class::{Class, ClassTrait};
use rpg::types::element::{Element, ElementTrait};
use rpg::types::spell::{Spell, SpellTrait};
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
    fn new(
        player_id: felt252, dungeon_id: u32, index: u8, class: Class, element: Element
    ) -> Character {
        // [Return] Character
        Character {
            player_id,
            dungeon_id,
            index,
            class: class.into(),
            element: element.into(),
            spell: class.base().into(),
            health: class.health(),
            shield: 0,
            stun: 0,
            buff: 0
        }
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

    const PLAYER_ID: felt252 = 'PLAYER';
    const DUNGEON_ID: u32 = 1;
    const INDEX: u8 = 0;
    const CLASS: Class = Class::Knight;
    const ELEMENT: Element = Element::Fire;

    #[test]
    fn test_player_new() {
        let player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        assert_eq!(player.player_id, PLAYER_ID);
        assert_eq!(player.dungeon_id, DUNGEON_ID);
        assert_eq!(player.index, INDEX);
        assert_eq!(player.class, CLASS.into());
        assert_eq!(player.element, ELEMENT.into());
        assert_eq!(player.spell, Spell::Damage.into());
        assert_eq!(player.health, CLASS.health());
        assert_eq!(player.shield, 0);
        assert_eq!(player.stun, 0);
        assert_eq!(player.buff, 0);
    }

    #[test]
    fn test_player_is_stun() {
        let player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        assert_eq!(player.is_stun(), false);
    }

    #[test]
    fn test_player_take() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.take(10);
        assert_eq!(player.health, CLASS.health() - 10);
    }

    #[test]
    fn test_player_heal() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.take(10);
        player.heal(5);
        assert_eq!(player.health, CLASS.health() - 5);
    }

    #[test]
    fn test_player_stun() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.stun(1);
        assert_eq!(player.stun, 1);
    }

    #[test]
    fn test_player_shield() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.shield(5);
        assert_eq!(player.shield, 5);
    }

    #[test]
    fn test_player_update() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.update(Spell::Stun);
        assert_eq!(player.spell, Spell::Stun.into());
    }

    #[test]
    fn test_player_finish() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.stun(1);
        player.finish();
        assert_eq!(player.stun, 0);
        assert_eq!(player.spell, Spell::Damage.into());
    }

    #[test]
    #[should_panic(expected: ('Character: is dead',))]
    fn test_player_assert_not_dead() {
        let mut player = CharacterTrait::new(PLAYER_ID, DUNGEON_ID, INDEX, CLASS, ELEMENT);
        player.health = 0;
        player.assert_not_dead();
    }
}

