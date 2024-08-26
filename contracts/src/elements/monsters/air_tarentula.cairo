// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element};

impl AirTarentula of MonsterTrait {
    #[inline]
    fn health() -> u8 {
        200
    }

    #[inline]
    fn spell() -> Spell {
        Spell::StunAll
    }

    #[inline]
    fn element() -> Element {
        Element::Air
    }
}
