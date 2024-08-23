// Internal imports

use rpg::elements::roles::interface::{RoleTrait, Spell};

impl Ranger of RoleTrait {
    #[inline]
    fn spell() -> Spell {
        Spell::Stun
    }
}
