// Internal imports

use rpg::elements::spells;

#[derive(Copy, Drop)]
enum Spell {
    None,
    Damage,
    Heal,
    Stun,
}

#[generate_trait]
impl SpellImpl of SpellTrait {}

impl IntoSpellFelt252 of core::Into<Spell, felt252> {
    #[inline(always)]
    fn into(self: Spell) -> felt252 {
        match self {
            Spell::None => 'NONE',
            Spell::Damage => 'DAMAGE',
            Spell::Heal => 'HEAL',
            Spell::Stun => 'STUN',
        }
    }
}

impl IntoSpellU8 of core::Into<Spell, u8> {
    #[inline(always)]
    fn into(self: Spell) -> u8 {
        match self {
            Spell::None => 0,
            Spell::Damage => 1,
            Spell::Heal => 2,
            Spell::Stun => 3,
        }
    }
}

impl IntoU8Spell of core::Into<u8, Spell> {
    #[inline(always)]
    fn into(self: u8) -> Spell {
        let card: felt252 = self.into();
        match card {
            0 => Spell::None,
            1 => Spell::Damage,
            2 => Spell::Heal,
            3 => Spell::Stun,
            _ => Spell::None,
        }
    }
}

impl SpellPrint of core::debug::PrintTrait<Spell> {
    #[inline(always)]
    fn print(self: Spell) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
