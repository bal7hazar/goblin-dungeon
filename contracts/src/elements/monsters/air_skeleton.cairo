// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element};

impl AirSkeleton of MonsterTrait {
    #[inline]
    fn health() -> u8 {
        100
    }

    #[inline]
    fn spell() -> Spell {
        Spell::Shield
    }

    #[inline]
    fn element() -> Element {
        Element::Air
    }
}
