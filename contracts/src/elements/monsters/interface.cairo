// Internal imports

use rpg::types::element::Element;
use rpg::types::spell::Spell;

trait MonsterTrait {
    fn health() -> u8;
    fn spell() -> Spell;
    fn element() -> Element;
}
