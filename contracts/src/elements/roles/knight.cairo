// Internal imports

use rpg::elements::roles::interface::{RoleTrait, Spell};

impl Knight of RoleTrait {
    #[inline]
    fn spell() -> Spell {
        Spell::Shield
    }
}
