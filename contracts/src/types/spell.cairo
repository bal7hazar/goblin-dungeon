// Internal imports

use rpg::elements::spells;
use rpg::models::mob::Mob;
use rpg::types::role::Role;
use rpg::types::element::Element;

#[derive(Copy, Drop)]
enum Spell {
    None,
    Punch,
    Kick,
    Heal,
    Blizzard,
    Burst,
    Fireblade,
    Fireball,
    Holywater,
    Sacrifice,
    Smash,
    Stomp,
    Tornado,
    Volley,
    Waterfall,
    Zephyr,
}

#[generate_trait]
impl SpellImpl of SpellTrait {
    #[inline]
    fn count() -> u8 {
        15
    }

    #[inline]
    fn from(seed: felt252) -> Spell {
        let random: u256 = seed.into();
        let count: u256 = Self::count().into();
        let value: u8 = 2 + (random % (count - 1).into()).try_into().unwrap();
        value.into()
    }

    #[inline]
    fn apply(
        self: Spell, ref caster: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>
    ) {
        match self {
            Spell::Punch => spells::punch::Punch::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Kick => spells::kick::Kick::apply(ref caster, ref target, ref mates, ref foes),
            Spell::Heal => spells::heal::Heal::apply(ref caster, ref target, ref mates, ref foes),
            Spell::Blizzard => spells::blizzard::Blizzard::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Burst => spells::burst::Burst::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Fireblade => spells::fireblade::Fireblade::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Fireball => spells::fireball::Fireball::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Holywater => spells::holywater::Holywater::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Sacrifice => spells::sacrifice::Sacrifice::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Smash => spells::smash::Smash::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Stomp => spells::stomp::Stomp::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Tornado => spells::tornado::Tornado::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Volley => spells::volley::Volley::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Waterfall => spells::waterfall::Waterfall::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            Spell::Zephyr => spells::zephyr::Zephyr::apply(
                ref caster, ref target, ref mates, ref foes
            ),
            _ => {}
        }
    }

    #[inline]
    fn role(self: Spell) -> Role {
        match self {
            Spell::Punch => spells::punch::Punch::role(),
            Spell::Kick => spells::kick::Kick::role(),
            Spell::Heal => spells::heal::Heal::role(),
            Spell::Blizzard => spells::blizzard::Blizzard::role(),
            Spell::Burst => spells::burst::Burst::role(),
            Spell::Fireblade => spells::fireblade::Fireblade::role(),
            Spell::Fireball => spells::fireball::Fireball::role(),
            Spell::Holywater => spells::holywater::Holywater::role(),
            Spell::Sacrifice => spells::sacrifice::Sacrifice::role(),
            Spell::Smash => spells::smash::Smash::role(),
            Spell::Stomp => spells::stomp::Stomp::role(),
            Spell::Tornado => spells::tornado::Tornado::role(),
            Spell::Volley => spells::volley::Volley::role(),
            Spell::Waterfall => spells::waterfall::Waterfall::role(),
            Spell::Zephyr => spells::zephyr::Zephyr::role(),
            _ => Role::Barbarian,
        }
    }

    #[inline]
    fn element(self: Spell) -> Element {
        match self {
            Spell::Punch => spells::punch::Punch::element(),
            Spell::Kick => spells::kick::Kick::element(),
            Spell::Heal => spells::heal::Heal::element(),
            Spell::Blizzard => spells::blizzard::Blizzard::element(),
            Spell::Burst => spells::burst::Burst::element(),
            Spell::Fireblade => spells::fireblade::Fireblade::element(),
            Spell::Fireball => spells::fireball::Fireball::element(),
            Spell::Holywater => spells::holywater::Holywater::element(),
            Spell::Sacrifice => spells::sacrifice::Sacrifice::element(),
            Spell::Smash => spells::smash::Smash::element(),
            Spell::Stomp => spells::stomp::Stomp::element(),
            Spell::Tornado => spells::tornado::Tornado::element(),
            Spell::Volley => spells::volley::Volley::element(),
            Spell::Waterfall => spells::waterfall::Waterfall::element(),
            Spell::Zephyr => spells::zephyr::Zephyr::element(),
            _ => Element::None,
        }
    }
}

impl IntoSpellFelt252 of core::Into<Spell, felt252> {
    #[inline]
    fn into(self: Spell) -> felt252 {
        match self {
            Spell::None => 'NONE',
            Spell::Punch => 'PUNCH',
            Spell::Kick => 'KICK',
            Spell::Heal => 'HEAL',
            Spell::Blizzard => 'BLIZZARD',
            Spell::Burst => 'BURST',
            Spell::Fireblade => 'FIREBLADE',
            Spell::Fireball => 'FIREBALL',
            Spell::Holywater => 'HOLYWATER',
            Spell::Sacrifice => 'SACRIFICE',
            Spell::Smash => 'SMASH',
            Spell::Stomp => 'STOMP',
            Spell::Tornado => 'TORNADO',
            Spell::Volley => 'VOLLEY',
            Spell::Waterfall => 'WATERFALL',
            Spell::Zephyr => 'ZEPHYR',
        }
    }
}

impl IntoSpellU8 of core::Into<Spell, u8> {
    #[inline]
    fn into(self: Spell) -> u8 {
        match self {
            Spell::None => 0,
            Spell::Punch => 1,
            Spell::Kick => 2,
            Spell::Heal => 3,
            Spell::Blizzard => 4,
            Spell::Burst => 5,
            Spell::Fireblade => 6,
            Spell::Fireball => 7,
            Spell::Holywater => 8,
            Spell::Sacrifice => 9,
            Spell::Smash => 10,
            Spell::Stomp => 11,
            Spell::Tornado => 12,
            Spell::Volley => 13,
            Spell::Waterfall => 14,
            Spell::Zephyr => 15,
        }
    }
}

impl IntoU8Spell of core::Into<u8, Spell> {
    #[inline]
    fn into(self: u8) -> Spell {
        let card: felt252 = self.into();
        match card {
            0 => Spell::None,
            1 => Spell::Punch,
            2 => Spell::Kick,
            3 => Spell::Heal,
            4 => Spell::Blizzard,
            5 => Spell::Burst,
            6 => Spell::Fireblade,
            7 => Spell::Fireball,
            8 => Spell::Holywater,
            9 => Spell::Sacrifice,
            10 => Spell::Smash,
            11 => Spell::Stomp,
            12 => Spell::Tornado,
            13 => Spell::Volley,
            14 => Spell::Waterfall,
            15 => Spell::Zephyr,
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
