// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element};

impl FireGoblin of MonsterTrait {
    #[inline]
    fn health() -> u8 {
        100
    }

    #[inline]
    fn spell() -> Spell {
        Spell::Damage
    }

    #[inline]
    fn element() -> Element {
        Element::Fire
    }
}
