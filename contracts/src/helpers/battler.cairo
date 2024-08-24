// Core imports

use core::debug::PrintTrait;

// Internal imports

use rpg::models::character::{Character, CharacterTrait};
use rpg::types::element::{Element, ElementTrait};

// Errors

mod errors {
    const BATTLER_INVALID_INPUTS: felt252 = 'Battler: invalid inputs';
}

#[generate_trait]
impl Battler of BattlerTrait {
    #[inline]
    fn start(ref characters: Array<Character>, ref monsters: Array<Character>) {
        // [Check] Characters and monsters lengths are equal
        assert(characters.len() == monsters.len(), errors::BATTLER_INVALID_INPUTS);
        // [Compute] Prior fight
        let mut count = characters.len();
        loop {
            if count == 0 {
                break;
            }
            // [Compute] Extract characters and monsters
            let mut lhs = characters.pop_front().unwrap();
            let mut rhs = monsters.pop_front().unwrap();
            Self::fight(ref lhs, ref rhs, true, ref characters, ref monsters);
            // [Effect] Push updated characters and monsters
            characters.append(lhs);
            monsters.append(rhs);
            // [Compute] Decrease counter
            count -= 1;
        };
        // [Compute] Later fight
        let mut count = characters.len();
        loop {
            if count == 0 {
                break;
            }
            // [Compute] Extract characters and monsters
            let mut lhs = characters.pop_front().unwrap();
            let mut rhs = monsters.pop_front().unwrap();
            Self::fight(ref lhs, ref rhs, false, ref characters, ref monsters);
            // [Effect] Push updated characters and monsters
            characters.append(lhs);
            monsters.append(rhs);
            // [Compute] Decrease counter
            count -= 1;
        };
    }

    #[inline]
    fn fight(
        ref lhs: Character,
        ref rhs: Character,
        prior: bool,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        // [Compute] Priority
        let lhs_element: Element = lhs.element.into();
        let rhs_element: Element = rhs.element.into();
        if (prior && lhs_element.has_priority_over(rhs_element))
            || (!prior && !lhs_element.has_priority_over(rhs_element)) {
            // [Effect] Left hand side character attacks first
            lhs.perform(ref rhs, ref mates, ref foes);
            lhs.finish();
        } else {
            // [Effect] Right hand side character attacks first
            rhs.perform(ref lhs, ref foes, ref mates);
            rhs.finish();
        };
    }

    #[inline]
    fn status(mut characters: Array<Character>) -> bool {
        // [Compute] Check if any character is alive
        loop {
            match characters.pop_front() {
                Option::Some(character) => {
                    if !character.is_dead() {
                        // [Return] At least one character is alive
                        break true;
                    }
                },
                Option::None => { break false; },
            };
        }
    }
}

#[cfg(test)]
mod tests {
    // Core imports

    use core::debug::PrintTrait;

    // Internal imports

    use rpg::types::class::{Class, ClassTrait};
    use rpg::types::spell::{Spell, SpellTrait};

    // Local imports

    use super::{Battler, BattlerTrait, Character, CharacterTrait, Element, ElementTrait};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const TEAM_ID: u32 = 42;

    #[test]
    fn test_battler_fight_priority_low() {
        // [Setup]
        let mut mates: Array<Character> = array![
            CharacterTrait::new(
                DUNGEON_ID, TEAM_ID, 0, class: Class::Knight, element: Element::Fire
            ),
        ];
        let mut foes: Array<Character> = array![
            CharacterTrait::new(
                DUNGEON_ID, TEAM_ID, 0, class: Class::Goblin, element: Element::Water
            ),
        ];
        let mut mate = mates.pop_front().unwrap();
        mate.update(Spell::Stun);
        let mut foe = foes.pop_front().unwrap();
        // [Fight]
        let mate_healh = mate.health;
        Battler::fight(ref mate, ref foe, true, ref mates, ref foes);
        // [Assert]
        assert_eq!(mate.health < mate_healh, true);
        // [Fight]
        Battler::fight(ref mate, ref foe, false, ref mates, ref foes);
        // [Assert]
        assert_eq!(foe.stun, 1);
    }
}
