// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element};

impl WaterGoblin of MonsterTrait {
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
        Element::Water
    }
}
