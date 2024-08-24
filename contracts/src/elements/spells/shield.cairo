// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Character, CharacterTrait};

// Constants

const SHIELD: u8 = 50;

impl Shield of SpellTrait {
    #[inline]
    fn apply(
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        caster.shield(SHIELD);
    }
}
