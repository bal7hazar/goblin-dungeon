// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element, Threat};

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
        match threat {
            Threat::Common => match element {
                Element::Fire => Spell::Heal,
                Element::Water => Spell::HealOther,
                Element::Air => Spell::Heal,
                _ => Spell::None,
            },
            Threat::Elite => match element {
                Element::Fire => Spell::HealOther,
                Element::Water => Spell::HealAll,
                Element::Air => Spell::HealOther,
                _ => Spell::None,
            },
            _ => Spell::None,
        }
    }
}
