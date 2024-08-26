// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element};

impl FireUndead of MonsterTrait {
    #[inline]
    fn health() -> u8 {
        200
    }

    #[inline]
    fn spell() -> Spell {
        Spell::ShieldAll
    }

    #[inline]
    fn element() -> Element {
        Element::Fire
    }
}
