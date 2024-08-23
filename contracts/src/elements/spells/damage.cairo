// Internal imports

use rpg::elements::spells::interface::SpellTrait;

impl Damage of SpellTrait {
    #[inline]
    fn damage(power: u8) -> u8 {
        10 * power
    }

    #[inline]
    fn heal(power: u8) -> u8 {
        0
    }

    #[inline]
    fn stun(power: u8) -> u8 {
        0
    }
}
