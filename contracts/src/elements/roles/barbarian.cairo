// Internal imports

use rpg::elements::roles::interface::{RoleTrait, Element, Spell};

impl Barbarian of RoleTrait {
    #[inline]
    fn spell(element: Element) -> Spell {
        match element {
            Element::Fire => Spell::Stomp,
            Element::Water => Spell::Smash,
            Element::Air => Spell::Burst,
            _ => Spell::None,
        }
    }
}
