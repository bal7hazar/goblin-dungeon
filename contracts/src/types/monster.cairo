// Internal imports

use rpg::elements::roles;
use rpg::elements::monsters;
use rpg::types::spell::Spell;
use rpg::types::element::Element;
use rpg::types::threat::Threat;


#[derive(Copy, Drop)]
enum Monster {
    None,
    AirSkeleton,
    AirSpider,
    AirTarentula,
    AirUndead,
    FireGoblin,
    FireHobgoblin,
    FireSkeleton,
    FireUndead,
    WaterGoblin,
    WaterHobgoblin,
    WaterSpider,
    WaterTarentula,
}

#[generate_trait]
impl MonsterImpl of MonsterTrait {
    #[inline]
    fn total_count() -> u8 {
        12
    }

    #[inline]
    fn count(threat: Threat) -> u8 {
        match threat {
            Threat::Common => 6,
            Threat::Elite => 6,
            _ => 0,
        }
    }

    #[inline]
    fn from(threat: Threat, seed: felt252) -> Monster {
        let random: u256 = seed.into();
        match threat {
            Threat::Common => {
                let count: u256 = Self::count(threat).into();
                let value: u8 = (random % count.into()).try_into().unwrap();
                match value {
                    0 => Monster::AirSkeleton,
                    1 => Monster::AirSpider,
                    2 => Monster::FireGoblin,
                    3 => Monster::FireSkeleton,
                    4 => Monster::WaterGoblin,
                    5 => Monster::WaterSpider,
                    _ => Monster::None,
                }
            },
            Threat::Elite => {
                let count: u256 = Self::count(threat).into();
                let value: u8 = (random % count.into()).try_into().unwrap();
                match value {
                    0 => Monster::AirTarentula,
                    1 => Monster::AirUndead,
                    2 => Monster::FireHobgoblin,
                    3 => Monster::FireUndead,
                    4 => Monster::WaterHobgoblin,
                    5 => Monster::WaterTarentula,
                    _ => Monster::None,
                }
            },
            Threat::None => Monster::None,
        }
    }

    #[inline]
    fn health(self: Monster) -> u8 {
        match self {
            Monster::None => 0,
            Monster::AirSkeleton => monsters::air_skeleton::AirSkeleton::health(),
            Monster::AirSpider => monsters::air_spider::AirSpider::health(),
            Monster::AirTarentula => monsters::air_tarentula::AirTarentula::health(),
            Monster::AirUndead => monsters::air_undead::AirUndead::health(),
            Monster::FireGoblin => monsters::fire_goblin::FireGoblin::health(),
            Monster::FireHobgoblin => monsters::fire_hobgoblin::FireHobgoblin::health(),
            Monster::FireSkeleton => monsters::fire_skeleton::FireSkeleton::health(),
            Monster::FireUndead => monsters::fire_undead::FireUndead::health(),
            Monster::WaterGoblin => monsters::water_goblin::WaterGoblin::health(),
            Monster::WaterHobgoblin => monsters::water_hobgoblin::WaterHobgoblin::health(),
            Monster::WaterSpider => monsters::water_spider::WaterSpider::health(),
            Monster::WaterTarentula => monsters::water_tarentula::WaterTarentula::health(),
        }
    }

    #[inline]
    fn spell(self: Monster) -> Spell {
        match self {
            Monster::None => Spell::None,
            Monster::AirSkeleton => monsters::air_skeleton::AirSkeleton::spell(),
            Monster::AirSpider => monsters::air_spider::AirSpider::spell(),
            Monster::AirTarentula => monsters::air_tarentula::AirTarentula::spell(),
            Monster::AirUndead => monsters::air_undead::AirUndead::spell(),
            Monster::FireGoblin => monsters::fire_goblin::FireGoblin::spell(),
            Monster::FireHobgoblin => monsters::fire_hobgoblin::FireHobgoblin::spell(),
            Monster::FireSkeleton => monsters::fire_skeleton::FireSkeleton::spell(),
            Monster::FireUndead => monsters::fire_undead::FireUndead::spell(),
            Monster::WaterGoblin => monsters::water_goblin::WaterGoblin::spell(),
            Monster::WaterHobgoblin => monsters::water_hobgoblin::WaterHobgoblin::spell(),
            Monster::WaterSpider => monsters::water_spider::WaterSpider::spell(),
            Monster::WaterTarentula => monsters::water_tarentula::WaterTarentula::spell(),
        }
    }

    #[inline]
    fn element(self: Monster) -> Element {
        match self {
            Monster::None => Element::None,
            Monster::AirSkeleton => monsters::air_skeleton::AirSkeleton::element(),
            Monster::AirSpider => monsters::air_spider::AirSpider::element(),
            Monster::AirTarentula => monsters::air_tarentula::AirTarentula::element(),
            Monster::AirUndead => monsters::air_undead::AirUndead::element(),
            Monster::FireGoblin => monsters::fire_goblin::FireGoblin::element(),
            Monster::FireHobgoblin => monsters::fire_hobgoblin::FireHobgoblin::element(),
            Monster::FireSkeleton => monsters::fire_skeleton::FireSkeleton::element(),
            Monster::FireUndead => monsters::fire_undead::FireUndead::element(),
            Monster::WaterGoblin => monsters::water_goblin::WaterGoblin::element(),
            Monster::WaterHobgoblin => monsters::water_hobgoblin::WaterHobgoblin::element(),
            Monster::WaterSpider => monsters::water_spider::WaterSpider::element(),
            Monster::WaterTarentula => monsters::water_tarentula::WaterTarentula::element(),
        }
    }
}

impl IntoMonsterFelt252 of core::Into<Monster, felt252> {
    #[inline]
    fn into(self: Monster) -> felt252 {
        match self {
            Monster::None => 'NONE',
            Monster::AirSkeleton => 'AIR-SKELETON',
            Monster::AirSpider => 'AIR-SPIDER',
            Monster::AirTarentula => 'AIR-TARENTULA',
            Monster::AirUndead => 'AIR-UNDEAD',
            Monster::FireGoblin => 'FIRE-GOBLIN',
            Monster::FireHobgoblin => 'FIRE-HOBGOBLIN',
            Monster::FireSkeleton => 'FIRE-SKELETON',
            Monster::FireUndead => 'FIRE-UNDEAD',
            Monster::WaterGoblin => 'WATER-GOBLIN',
            Monster::WaterHobgoblin => 'WATER-HOBGOBLIN',
            Monster::WaterSpider => 'WATER-SPIDER',
            Monster::WaterTarentula => 'WATER-TARENTULA',
        }
    }
}

impl IntoMonsterU8 of core::Into<Monster, u8> {
    #[inline]
    fn into(self: Monster) -> u8 {
        match self {
            Monster::None => 0,
            Monster::AirSkeleton => 1,
            Monster::AirSpider => 2,
            Monster::AirTarentula => 3,
            Monster::AirUndead => 4,
            Monster::FireGoblin => 5,
            Monster::FireHobgoblin => 6,
            Monster::FireSkeleton => 7,
            Monster::FireUndead => 8,
            Monster::WaterGoblin => 9,
            Monster::WaterHobgoblin => 10,
            Monster::WaterSpider => 11,
            Monster::WaterTarentula => 12,
        }
    }
}

impl IntoU8Monster of core::Into<u8, Monster> {
    #[inline]
    fn into(self: u8) -> Monster {
        let card: felt252 = self.into();
        match card {
            0 => Monster::None,
            1 => Monster::AirSkeleton,
            2 => Monster::AirSpider,
            3 => Monster::AirTarentula,
            4 => Monster::AirUndead,
            5 => Monster::FireGoblin,
            6 => Monster::FireHobgoblin,
            7 => Monster::FireSkeleton,
            8 => Monster::FireUndead,
            9 => Monster::WaterGoblin,
            10 => Monster::WaterHobgoblin,
            11 => Monster::WaterSpider,
            12 => Monster::WaterTarentula,
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
