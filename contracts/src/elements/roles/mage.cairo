// Internal imports

use rpg::elements::roles::interface::{RoleTrait, Element, Spell};

impl Mage of RoleTrait {
    #[inline]
    fn spell(element: Element) -> Spell {
        match element {
            Element::Fire => Spell::Fireball,
            Element::Water => Spell::Blizzard,
            Element::Air => Spell::Zephyr,
            _ => Spell::None,
        }
    }
}
