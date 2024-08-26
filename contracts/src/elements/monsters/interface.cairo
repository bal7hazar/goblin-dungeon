// Internal imports

use rpg::types::element::Element;
use rpg::types::spell::Spell;
use rpg::types::threat::Threat;

trait MonsterTrait {
    fn health(threat: Threat) -> u8;
    fn spell(threat: Threat, element: Element) -> Spell;
}
