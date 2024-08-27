// Internal imports

use grimscape::elements::elements::interface::{Element, ElementTrait};

impl Air of ElementTrait {
    #[inline]
    fn weakness() -> Element {
        Element::Fire
    }

    #[inline]
    fn strength() -> Element {
        Element::Water
    }
}
