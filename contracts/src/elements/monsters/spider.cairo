// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell};

impl Spider of MonsterTrait {
    #[inline]
    fn spell() -> Spell {
        Spell::Stun
    }
}
