// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Character, CharacterTrait};

// Constants

const DAMAGE: u8 = 10;

impl DamageAll of SpellTrait {
    #[inline]
    fn apply(
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        target.take(DAMAGE);
        let mut index = foes.len();
        loop {
            if index == 0 {
                break;
            }
            let mut foe = foes.pop_front().unwrap();
            foe.take(DAMAGE);
            foes.append(foe);
            index -= 1;
        }
    }
}
