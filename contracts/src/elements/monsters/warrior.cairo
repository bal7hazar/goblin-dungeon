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
        match threat {
            Threat::Common => match element {
                Element::Fire => Spell::StunOther,
                Element::Water => Spell::Stun,
                Element::Air => Spell::Stun,
                _ => Spell::None,
            },
            Threat::Elite => match element {
                Element::Fire => Spell::StunAll,
                Element::Water => Spell::StunOther,
                Element::Air => Spell::StunOther,
                _ => Spell::None,
            },
            _ => Spell::None,
        }
    }
}
