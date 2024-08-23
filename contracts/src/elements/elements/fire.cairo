// Internal imports

use rpg::elements::elements::interface::{Element, ElementTrait};

impl Fire of ElementTrait {
    #[inline]
    fn weakness() -> Element {
        Element::Water
    }

    #[inline]
    fn strength() -> Element {
        Element::Air
    }
}
