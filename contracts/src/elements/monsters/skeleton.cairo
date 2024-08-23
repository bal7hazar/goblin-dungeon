// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell};

impl Skeleton of MonsterTrait {
    #[inline]
    fn spell() -> Spell {
        Spell::Damage
    }
}
