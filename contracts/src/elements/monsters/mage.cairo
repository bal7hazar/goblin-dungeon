// Internal imports

use grimscape::elements::monsters::interface::{MonsterTrait, Spell, Element, Threat};

impl Mage of MonsterTrait {
    #[inline]
    fn health(threat: Threat) -> u8 {
        match threat {
            Threat::Common => 80,
            Threat::Elite => 160,
            _ => 0,
        }
    }

    #[inline]
    fn spell(threat: Threat, element: Element) -> Spell {
        match element {
            Element::Fire => Spell::Fireball,
            Element::Water => Spell::Blizzard,
            Element::Air => Spell::Zephyr,
            _ => Spell::None,
        }
    }
}
