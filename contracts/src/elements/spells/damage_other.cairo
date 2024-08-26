// Internal imports

use rpg::elements::spells::interface::{SpellTrait, Mob, MobTrait};

// Constants

const DAMAGE: u8 = 15;

impl DamageOther of SpellTrait {
    #[inline]
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        let mut index = foes.len();
        loop {
            if index == 0 {
                break;
            }
            let mut foe = foes.pop_front().unwrap();
            foe.take(DAMAGE * caster.multiplier);
            foes.append(foe);
            index -= 1;
        };
        caster.debuff();
    }
}
