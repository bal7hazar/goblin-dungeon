// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait};

// Constants

const MULTIPLIER: u8 = 3;

impl Buff of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        caster.buff(MULTIPLIER);
    }
}
