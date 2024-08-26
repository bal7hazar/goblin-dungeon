// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const HEALTH: u8 = 40;
const HEALTH_OTHER: u8 = 10;

impl Holywater of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        caster.heal(HEALTH);
        let mut index = mates.len();
        loop {
            if index == 0 {
                break;
            }
            let mut mate = mates.pop_front().unwrap();
            mate.heal(HEALTH_OTHER);
            mates.append(mate);
            index -= 1;
        };
        caster.debuff();
    }

    #[inline]
    fn role() -> Role {
        Role::Knight
    }

    #[inline]
    fn element() -> Element {
        Element::Water
    }
}
