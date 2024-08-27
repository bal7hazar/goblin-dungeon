// Internal imports

use grimscape::elements::roles::interface::{RoleTrait, Element, Spell};

impl Rogue of RoleTrait {
    #[inline]
    fn spell(element: Element) -> Spell {
        match element {
            Element::Fire => Spell::Sacrifice,
            Element::Water => Spell::Waterfall,
            Element::Air => Spell::Volley,
            _ => Spell::None,
        }
    }
}
