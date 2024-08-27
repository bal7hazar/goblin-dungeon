// Internal imports

use grimscape::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const DAMAGE: u8 = 40;
const STUN: u8 = 2;

impl Stomp of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        target.take(DAMAGE * caster.multiplier);
        target.stun(STUN);
        caster.debuff();
    }

    #[inline]
    fn role() -> Role {
        Role::Barbarian
    }

    #[inline]
    fn element() -> Element {
        Element::Water
    }
}
