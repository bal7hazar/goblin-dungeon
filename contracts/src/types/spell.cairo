// Internal imports

use rpg::elements::spells;
use rpg::models::mob::Mob;

#[derive(Copy, Drop)]
enum Spell {
    None,
    Buff,
    Damage,
    Heal,
    Shield,
    Stun,
    BuffOther,
    DamageOther,
    HealOther,
    ShieldOther,
    StunOther,
    BuffAll,
    DamageAll,
    HealAll,
    ShieldAll,
    StunAll,
}

#[generate_trait]
impl SpellImpl of SpellTrait {
    #[inline]
    fn count() -> u8 {
        15
    }

    #[inline]
    fn apply(
        self: Spell, ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>
    ) {
        match self {
            Spell::Buff => spells::buff::Buff::apply(ref caster, ref target, ref mates, ref foes),
            Spell::Damage => spells::damage::Damage::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Heal => spells::heal::Heal::apply(ref caster, ref target, ref mates, ref foes),
            Spell::Shield => spells::shield::Shield::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Stun => spells::stun::Stun::apply(ref caster, ref target, ref mates, ref foes),
            Spell::BuffAll => spells::buff_all::BuffAll::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::DamageAll => spells::damage_all::DamageAll::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::HealAll => spells::heal_all::HealAll::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::ShieldAll => spells::shield_all::ShieldAll::apply(
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
            Spell::Buff => 'BUFF',
            Spell::Damage => 'DAMAGE',
            Spell::Heal => 'HEAL',
            Spell::Shield => 'SHIELD',
            Spell::Stun => 'STUN',
            Spell::BuffOther => 'BUFF_OTHER',
            Spell::DamageOther => 'DAMAGE_OTHER',
            Spell::HealOther => 'HEAL_OTHER',
            Spell::ShieldOther => 'SHIELD_OTHER',
            Spell::StunOther => 'STUN_OTHER',
            Spell::BuffAll => 'BUFF_ALL',
            Spell::DamageAll => 'DAMAGE_ALL',
            Spell::HealAll => 'HEAL_ALL',
            Spell::ShieldAll => 'SHIELD_ALL',
            Spell::StunAll => 'STUN_ALL',
        }
    }
}

impl IntoSpellU8 of core::Into<Spell, u8> {
    #[inline]
    fn into(self: Spell) -> u8 {
        match self {
            Spell::None => 0,
            Spell::Buff => 1,
            Spell::Damage => 2,
            Spell::Heal => 3,
            Spell::Shield => 4,
            Spell::Stun => 5,
            Spell::BuffOther => 6,
            Spell::DamageOther => 7,
            Spell::HealOther => 8,
            Spell::ShieldOther => 9,
            Spell::StunOther => 10,
            Spell::BuffAll => 11,
            Spell::DamageAll => 12,
            Spell::HealAll => 13,
            Spell::ShieldAll => 14,
            Spell::StunAll => 15,
        }
    }
}

impl IntoU8Spell of core::Into<u8, Spell> {
    #[inline]
    fn into(self: u8) -> Spell {
        let card: felt252 = self.into();
        match card {
            0 => Spell::None,
            1 => Spell::Buff,
            2 => Spell::Damage,
            3 => Spell::Heal,
            4 => Spell::Shield,
            5 => Spell::Stun,
            6 => Spell::BuffOther,
            7 => Spell::DamageOther,
            8 => Spell::HealOther,
            9 => Spell::ShieldOther,
            10 => Spell::StunOther,
            11 => Spell::BuffAll,
            12 => Spell::DamageAll,
            13 => Spell::HealAll,
            14 => Spell::ShieldAll,
            15 => Spell::StunAll,
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
