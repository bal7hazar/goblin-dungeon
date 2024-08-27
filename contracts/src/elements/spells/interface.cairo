// Internal imports

use grimscape::models::mob::{Mob, MobTrait};
use grimscape::types::role::Role;
use grimscape::types::element::Element;

trait SpellTrait {
    fn apply(ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>,);
    fn role() -> Role;
    fn element() -> Element;
}
