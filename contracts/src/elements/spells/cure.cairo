// Internal imports

use grimscape::elements::spells::interface::{SpellTrait, Mob, MobTrait, Role, Element};

// Constants

const HEALTH: u8 = 10;

impl Cure of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        let mut index = mates.len();
        loop {
            if index == 0 {
                break;
            }
            let mut mate = mates.pop_front().unwrap();
            mate.heal(HEALTH);
            mates.append(mate);
            index -= 1;
        };
        caster.debuff();
    }
}
