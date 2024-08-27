// Internal imports

use grimscape::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const DAMAGE_TARGET: u8 = 70;
const DAMAGE_SELF: u8 = 20;

impl Sacrifice of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        target.take(DAMAGE_TARGET * caster.multiplier);
        caster.take(DAMAGE_SELF * caster.multiplier);
        caster.debuff();
    }

    #[inline]
    fn role() -> Role {
        Role::Rogue
    }

    #[inline]
    fn element() -> Element {
        Element::Fire
    }
}
