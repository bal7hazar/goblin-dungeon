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
        match element {
            Element::Fire => Spell::Fireblade,
            Element::Water => Spell::Holywater,
            Element::Air => Spell::Tornado,
            _ => Spell::None,
        }
    }
}
