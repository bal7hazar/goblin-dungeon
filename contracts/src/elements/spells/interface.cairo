// Internal imports

use rpg::models::mob::{Mob, MobTrait};
use rpg::types::role::Role;
use rpg::types::element::Element;

trait SpellTrait {
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>,);
    fn role() -> Role;
    fn element() -> Element;
}
