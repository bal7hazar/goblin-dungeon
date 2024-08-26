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
        match element {
            Element::Fire => Spell::Sacrifice,
            Element::Water => Spell::Waterfall,
            Element::Air => Spell::Volley,
            _ => Spell::None,
        }
    }
}
