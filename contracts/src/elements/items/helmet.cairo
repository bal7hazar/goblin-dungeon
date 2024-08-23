// Internal imports

use rpg::elements::items::interface::{ItemTrait, Slot, Spell};

impl Helmet of ItemTrait {
    #[inline]
    fn slot() -> Slot {
        Slot::Head
    }

    #[inline]
    fn spell() -> Spell {
        Spell::Stun
    }
}
