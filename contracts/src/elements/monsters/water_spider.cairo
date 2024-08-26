// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element};

impl WaterSpider of MonsterTrait {
    #[inline]
    fn health() -> u8 {
        100
    }

    #[inline]
    fn spell() -> Spell {
        Spell::Stun
    }

    #[inline]
    fn element() -> Element {
        Element::Water
    }
}
