// Internal imports

use rpg::elements::items::interface::{ItemTrait, Slot, Spell};

impl Staff of ItemTrait {
    #[inline]
    fn slot() -> Slot {
        Slot::Weapon
    }

    #[inline]
    fn spell() -> Spell {
        Spell::Heal
    }
}
