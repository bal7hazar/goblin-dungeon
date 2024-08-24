// Internal imports

use rpg::models::mob::{Mob, MobTrait};

trait SpellTrait {
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>,);
}
