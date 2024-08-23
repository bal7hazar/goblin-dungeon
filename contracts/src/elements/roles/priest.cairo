// Internal imports

use rpg::elements::roles::interface::{RoleTrait, Spell};

impl Priest of RoleTrait {
    #[inline]
    fn spell() -> Spell {
        Spell::Heal
    }
}
