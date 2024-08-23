// Internal imports

use rpg::elements::monsters::interface::{MonsterTrait, Spell};

impl Goblin of MonsterTrait {
    #[inline]
    fn spell() -> Spell {
        Spell::Damage
    }
}
