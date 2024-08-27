// Internal imports

use grimscape::types::element::Element;
use grimscape::types::spell::Spell;

trait RoleTrait {
    fn spell(element: Element) -> Spell;
}
