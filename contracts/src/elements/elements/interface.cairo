// Internal imports

use rpg::types::element::Element;

trait ElementTrait {
    fn weakness() -> Element;
    fn strength() -> Element;
}
