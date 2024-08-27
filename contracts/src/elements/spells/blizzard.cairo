// Internal imports

use grimscape::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const DAMAGE: u8 = 20;
const STUN: u8 = 1;

impl Blizzard of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        target.take(DAMAGE * caster.multiplier);
        let mut index = foes.len();
        loop {
            if index == 0 {
                break;
            }
            let mut foe = foes.pop_front().unwrap();
            foe.stun(DAMAGE * caster.multiplier);
            foes.append(foe);
            index -= 1;
        };
        target.stun(STUN);
        caster.debuff();
    }

    #[inline]
    fn role() -> Role {
        Role::Mage
    }

    #[inline]
    fn element() -> Element {
        Element::Water
    }
}
