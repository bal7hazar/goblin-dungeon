// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const DAMAGE: u8 = 20;

impl Punch of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        target.take(DAMAGE * caster.multiplier);
        caster.debuff();
    }

    #[inline]
    fn role() -> Role {
        Role::None
    }

    #[inline]
    fn element() -> Element {
        Element::None
    }
}
