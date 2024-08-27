// Internal imports

use grimscape::elements::roles::interface::{RoleTrait, Element, Spell};

impl Knight of RoleTrait {
    #[inline]
    fn spell(element: Element) -> Spell {
        match element {
            Element::Fire => Spell::Fireblade,
            Element::Water => Spell::Holywater,
            Element::Air => Spell::Tornado,
            _ => Spell::None,
        }
    }
}
