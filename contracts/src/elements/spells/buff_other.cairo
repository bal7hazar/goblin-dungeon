// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait};

// Constants

const MULTIPLIER: u8 = 2;

impl BuffOther of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        caster.buff(MULTIPLIER);
        let mut index = mates.len();
        loop {
            if index == 0 {
                break;
            }
            let mut mate = mates.pop_front().unwrap();
            mate.buff(MULTIPLIER);
            mates.append(mate);
            index -= 1;
        }
    }
}
