// Internal imports

use rpg::elements::spells::interface::SpellTrait;

impl Heal of SpellTrait {
    #[inline]
    fn damage(power: u8) -> u8 {
        0
    }

    #[inline]
    fn heal(power: u8) -> u8 {
        10 * power
    }

    #[inline]
    fn stun(power: u8) -> u8 {
        0
    }
}
