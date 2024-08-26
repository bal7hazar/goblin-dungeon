// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element, Threat};

impl Minion of MonsterTrait {
    #[inline]
    fn health(threat: Threat) -> u8 {
        match threat {
            Threat::Common => 60,
            Threat::Elite => 120,
            _ => 0,
        }
    }

    #[inline]
    fn spell(threat: Threat, element: Element) -> Spell {
        match threat {
            Threat::Common => match element {
                Element::Fire => Spell::Damage,
                Element::Water => Spell::Damage,
                Element::Air => Spell::Damage,
                _ => Spell::None,
            },
            Threat::Elite => match element {
                Element::Fire => Spell::Damage,
                Element::Water => Spell::Damage,
                Element::Air => Spell::Damage,
                _ => Spell::None,
            },
            _ => Spell::None,
        }
    }
}
