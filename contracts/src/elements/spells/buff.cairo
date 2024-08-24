// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Character, CharacterTrait};

// Constants

const MULTIPLIER: u8 = 3;

impl Buff of SpellTrait {
    #[inline]
    fn apply(
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        caster.buff(MULTIPLIER);
    }
}
