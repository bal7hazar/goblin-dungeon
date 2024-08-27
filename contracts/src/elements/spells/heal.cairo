// Internal imports

use grimscape::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const HEALTH: u8 = 25;

impl Heal of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        caster.heal(HEALTH);
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
