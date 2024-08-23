// Internal imports

use rpg::elements::spells;
use rpg::models::character::Character;

#[derive(Copy, Drop)]
enum Spell {
    None,
    Damage,
    Heal,
    Stun,
    DamageAll,
    HealAll,
    StunAll,
}

#[generate_trait]
impl SpellImpl of SpellTrait {
    #[inline]
    fn count() -> u8 {
        3
    }

    #[inline]
    fn apply(
        self: Spell,
        ref caster: Character,
        ref target: Character,
        ref mates: Array<Character>,
        ref foes: Array<Character>
    ) {
        match self {
            Spell::Damage => spells::damage::Damage::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Heal => spells::heal::Heal::apply(ref caster, ref target, ref mates, ref foes),
            Spell::Stun => spells::stun::Stun::apply(ref caster, ref target, ref mates, ref foes),
            Spell::DamageAll => spells::damage_all::DamageAll::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::HealAll => spells::heal_all::HealAll::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::StunAll => spells::stun_all::StunAll::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            _ => {}
        }
    }
}

impl IntoSpellFelt252 of core::Into<Spell, felt252> {
    #[inline]
    fn into(self: Spell) -> felt252 {
        match self {
            Spell::None => 'NONE',
            Spell::Damage => 'DAMAGE',
            Spell::Heal => 'HEAL',
            Spell::Stun => 'STUN',
            Spell::DamageAll => 'DAMAGE_ALL',
            Spell::HealAll => 'HEAL_ALL',
            Spell::StunAll => 'STUN_ALL',
        }
    }
}

impl IntoSpellU8 of core::Into<Spell, u8> {
    #[inline]
    fn into(self: Spell) -> u8 {
        match self {
            Spell::None => 0,
            Spell::Damage => 1,
            Spell::Heal => 2,
            Spell::Stun => 3,
            Spell::DamageAll => 4,
            Spell::HealAll => 5,
            Spell::StunAll => 6,
        }
    }
}

impl IntoU8Spell of core::Into<u8, Spell> {
    #[inline]
    fn into(self: u8) -> Spell {
        let card: felt252 = self.into();
        match card {
            0 => Spell::None,
            1 => Spell::Damage,
            2 => Spell::Heal,
            3 => Spell::Stun,
            4 => Spell::DamageAll,
            5 => Spell::HealAll,
            6 => Spell::StunAll,
            _ => Spell::None,
        }
    }
}

impl SpellPrint of core::debug::PrintTrait<Spell> {
    #[inline]
    fn print(self: Spell) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
