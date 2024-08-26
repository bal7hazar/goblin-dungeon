// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element, Threat};

impl Warrior of MonsterTrait {
    #[inline]
    fn health(threat: Threat) -> u8 {
        match threat {
            Threat::Common => 120,
            Threat::Elite => 240,
            _ => 0,
        }
    }

    #[inline]
    fn spell(threat: Threat, element: Element) -> Spell {
        match element {
            Element::Fire => Spell::Stomp,
            Element::Water => Spell::Smash,
            Element::Air => Spell::Burst,
            _ => Spell::None,
        }
    }
}
