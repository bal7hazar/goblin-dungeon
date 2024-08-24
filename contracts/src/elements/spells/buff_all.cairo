// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Character, CharacterTrait};

// Constants

const MULTIPLIER: u8 = 2;

impl BuffAll of SpellTrait {
    #[inline]
    fn apply(
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        caster.buff(MULTIPLIER);
        let mut index = mates.len();
        loop {
            if index == 0 {
                break;
            }
            let mut mate = mates.pop_front().unwrap();
            mate.buff(MULTIPLIER);
            mates.append(mate);
            index -= 1;
        }
    }
}
