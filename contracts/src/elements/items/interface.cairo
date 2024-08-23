// Internal imports

use rpg::types::slot::Slot;
use rpg::types::spell::Spell;

trait ItemTrait {
    fn slot() -> Slot;
    fn spell() -> Spell;
}
