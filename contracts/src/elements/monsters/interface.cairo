// Internal imports

use grimscape::types::element::Element;
use grimscape::types::spell::Spell;
use grimscape::types::threat::Threat;

trait MonsterTrait {
    fn health(threat: Threat) -> u8;
    fn spell(threat: Threat, element: Element) -> Spell;
}
