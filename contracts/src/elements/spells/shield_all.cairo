// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Character, CharacterTrait};

// Constants

const SHIELD: u8 = 10;

impl ShieldAll of SpellTrait {
    #[inline]
    fn apply(
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        caster.shield(SHIELD);
        let mut index = mates.len();
        loop {
            if index == 0 {
                break;
            }
            let mut mate = mates.pop_front().unwrap();
            mate.shield(SHIELD);
            mates.append(mate);
            index -= 1;
        }
    }
}
