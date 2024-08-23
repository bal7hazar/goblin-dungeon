// Internal imports

use rpg::elements::roles;
use rpg::elements::monsters;
use rpg::types::spell::Spell;
use rpg::types::class::Class;

#[derive(Copy, Drop)]
enum Monster {
    None,
    Goblin,
    Skeleton,
    Spider,
}

#[generate_trait]
impl MonsterImpl of MonsterTrait {
    #[inline]
    fn count() -> u8 {
        3
    }

    #[inline]
    fn power(self: Monster, seed: felt252) -> u8 {
        (seed.into() % 5_u256).try_into().unwrap() + 1
    }

    #[inline]
    fn spell(self: Monster) -> Spell {
        match self {
            Monster::None => Spell::None,
            Monster::Goblin => monsters::goblin::Goblin::spell(),
            Monster::Skeleton => monsters::skeleton::Skeleton::spell(),
            Monster::Spider => monsters::spider::Spider::spell(),
        }
    }
}

impl IntoMonsterClass of core::Into<Monster, Class> {
    #[inline]
    fn into(self: Monster) -> Class {
        match self {
            Monster::None => Class::None,
            Monster::Goblin => Class::Goblin,
            Monster::Skeleton => Class::Skeleton,
            Monster::Spider => Class::Spider,
        }
    }
}

impl IntoMonsterFelt252 of core::Into<Monster, felt252> {
    #[inline]
    fn into(self: Monster) -> felt252 {
        match self {
            Monster::None => 'NONE',
            Monster::Goblin => 'GOBLIN',
            Monster::Skeleton => 'SKELETON',
            Monster::Spider => 'SPIDER',
        }
    }
}

impl IntoMonsterU8 of core::Into<Monster, u8> {
    #[inline]
    fn into(self: Monster) -> u8 {
        match self {
            Monster::None => 0,
            Monster::Goblin => 1,
            Monster::Skeleton => 2,
            Monster::Spider => 3,
        }
    }
}

impl IntoU8Monster of core::Into<u8, Monster> {
    #[inline]
    fn into(self: u8) -> Monster {
        let card: felt252 = self.into();
        match card {
            0 => Monster::None,
            1 => Monster::Goblin,
            2 => Monster::Skeleton,
            3 => Monster::Spider,
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
