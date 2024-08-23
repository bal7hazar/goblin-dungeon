// Internal imports

use rpg::models::character::{Character, CharacterTrait};

trait SpellTrait {
    fn apply(
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    );
}
