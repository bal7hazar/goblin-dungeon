// Internal imports

use rpg::elements::roles;
use rpg::elements::monsters;
use rpg::types::spell::Spell;
use rpg::types::element::Element;
use rpg::types::threat::Threat;


#[derive(Copy, Drop)]
enum Monster {
    None,
    Mage,
    Minion,
    Rogue,
    Warrior,
}

#[generate_trait]
impl MonsterImpl of MonsterTrait {
    #[inline]
    fn count() -> u8 {
        4
    }

    #[inline]
    fn from(seed: felt252) -> Monster {
        let random: u256 = seed.into();
        let count: u256 = Self::count().into();
        let value: u8 = 1 + (random % count.into()).try_into().unwrap();
        value.into()
    }

    #[inline]
    fn health(self: Monster, threat: Threat) -> u8 {
        match self {
            Monster::Mage => monsters::mage::Mage::health(threat),
            Monster::Minion => monsters::minion::Minion::health(threat),
            Monster::Rogue => monsters::rogue::Rogue::health(threat),
            Monster::Warrior => monsters::warrior::Warrior::health(threat),
            _ => 0,
        }
    }

    #[inline]
    fn spell(self: Monster, threat: Threat, element: Element) -> Spell {
        match self {
            Monster::Mage => monsters::mage::Mage::spell(threat, element),
            Monster::Minion => monsters::minion::Minion::spell(threat, element),
            Monster::Rogue => monsters::rogue::Rogue::spell(threat, element),
            Monster::Warrior => monsters::warrior::Warrior::spell(threat, element),
            _ => Spell::None,
        }
    }
}

impl IntoMonsterFelt252 of core::Into<Monster, felt252> {
    #[inline]
    fn into(self: Monster) -> felt252 {
        match self {
            Monster::None => 'NONE',
            Monster::Mage => 'MAGE',
            Monster::Minion => 'MINION',
            Monster::Rogue => 'ROGUE',
            Monster::Warrior => 'WARRIOR',
        }
    }
}

impl IntoMonsterU8 of core::Into<Monster, u8> {
    #[inline]
    fn into(self: Monster) -> u8 {
        match self {
            Monster::None => 0,
            Monster::Mage => 1,
            Monster::Minion => 2,
            Monster::Rogue => 3,
            Monster::Warrior => 4,
        }
    }
}

impl IntoU8Monster of core::Into<u8, Monster> {
    #[inline]
    fn into(self: u8) -> Monster {
        let card: felt252 = self.into();
        match card {
            0 => Monster::None,
            1 => Monster::Mage,
            2 => Monster::Minion,
            3 => Monster::Rogue,
            4 => Monster::Warrior,
            _ => Monster::None,
        }
    }
}

impl MonsterPrint of core::debug::PrintTrait<Monster> {
    #[inline]
    fn print(self: Monster) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
