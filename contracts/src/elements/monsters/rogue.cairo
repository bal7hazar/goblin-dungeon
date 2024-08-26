// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell, Element, Threat};

impl Rogue of MonsterTrait {
    #[inline]
    fn health(threat: Threat) -> u8 {
        match threat {
            Threat::Common => 100,
            Threat::Elite => 200,
            _ => 0,
        }
    }

    #[inline]
    fn spell(threat: Threat, element: Element) -> Spell {
        match threat {
            Threat::Common => match element {
                Element::Fire => Spell::Damage,
                Element::Water => Spell::Damage,
                Element::Air => Spell::DamageOther,
                _ => Spell::None,
            },
            Threat::Elite => match element {
                Element::Fire => Spell::DamageOther,
                Element::Water => Spell::DamageOther,
                Element::Air => Spell::DamageAll,
                _ => Spell::None,
            },
            _ => Spell::None,
        }
    }
}
