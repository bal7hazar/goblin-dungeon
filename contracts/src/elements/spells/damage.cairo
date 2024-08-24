// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait};

// Constants

const DAMAGE: u8 = 30;

impl Damage of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        target.take(DAMAGE * caster.multiplier);
        caster.debuff();
    }
}
