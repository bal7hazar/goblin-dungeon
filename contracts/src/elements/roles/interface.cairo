// Internal imports

use rpg::types::element::Element;
use rpg::types::spell::Spell;

trait RoleTrait {
    fn spell(element: Element) -> Spell;
}
