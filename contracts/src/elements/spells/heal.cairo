// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait};

// Constants

const HEALTH: u8 = 50;

impl Heal of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        caster.heal(HEALTH);
    }
}
