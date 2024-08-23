// Internal imports

use rpg::elements::elements::interface::{Element, ElementTrait};

impl Water of ElementTrait {
    #[inline]
    fn weakness() -> Element {
        Element::Air
    }

    #[inline]
    fn strength() -> Element {
        Element::Fire
    }
}
