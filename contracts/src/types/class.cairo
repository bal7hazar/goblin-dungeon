// Internal imports

use rpg::elements::roles;
use rpg::elements::monsters;
use rpg::types::spell::Spell;
use rpg::types::role::{Role, RoleTrait};
use rpg::types::monster::{Monster, MonsterTrait};

#[derive(Copy, Drop)]
enum Class {
    None,
    Knight,
    Ranger,
    Priest,
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
impl ClassImpl of ClassTrait {
    #[inline]
    fn health(self: Class) -> u8 {
        match self {
            Class::None => 0,
            _ => 100, // FIXME: Define values for each class
        }
    }

    #[inline]
    fn base(self: Class) -> Spell {
        Spell::Damage
    }

    #[inline]
    fn spell(self: Class) -> Spell {
        match self {
            Class::None => Spell::None,
            Class::Knight => RoleTrait::spell(Role::Knight),
            Class::Ranger => RoleTrait::spell(Role::Ranger),
            Class::Priest => RoleTrait::spell(Role::Priest),
            Class::AirSkeleton => MonsterTrait::spell(Monster::AirSkeleton),
            Class::AirSpider => MonsterTrait::spell(Monster::AirSpider),
            Class::AirTarentula => MonsterTrait::spell(Monster::AirTarentula),
            Class::AirUndead => MonsterTrait::spell(Monster::AirUndead),
            Class::FireGoblin => MonsterTrait::spell(Monster::FireGoblin),
            Class::FireHobgoblin => MonsterTrait::spell(Monster::FireHobgoblin),
            Class::FireSkeleton => MonsterTrait::spell(Monster::FireSkeleton),
            Class::FireUndead => MonsterTrait::spell(Monster::FireUndead),
            Class::WaterGoblin => MonsterTrait::spell(Monster::WaterGoblin),
            Class::WaterHobgoblin => MonsterTrait::spell(Monster::WaterHobgoblin),
            Class::WaterSpider => MonsterTrait::spell(Monster::WaterSpider),
            Class::WaterTarentula => MonsterTrait::spell(Monster::WaterTarentula),
        }
    }
}

impl IntoClassRole of core::Into<Class, Role> {
    #[inline]
    fn into(self: Class) -> Role {
        match self {
            Class::Knight => Role::Knight,
            Class::Ranger => Role::Ranger,
            Class::Priest => Role::Priest,
            _ => Role::None,
        }
    }
}

impl IntoClassMonster of core::Into<Class, Monster> {
    #[inline]
    fn into(self: Class) -> Monster {
        match self {
            Class::AirSkeleton => Monster::AirSkeleton,
            Class::AirSpider => Monster::AirSpider,
            Class::AirTarentula => Monster::AirTarentula,
            Class::AirUndead => Monster::AirUndead,
            Class::FireGoblin => Monster::FireGoblin,
            Class::FireHobgoblin => Monster::FireHobgoblin,
            Class::FireSkeleton => Monster::FireSkeleton,
            Class::FireUndead => Monster::FireUndead,
            Class::WaterGoblin => Monster::WaterGoblin,
            Class::WaterHobgoblin => Monster::WaterHobgoblin,
            Class::WaterSpider => Monster::WaterSpider,
            Class::WaterTarentula => Monster::WaterTarentula,
            _ => Monster::None,
        }
    }
}

impl IntoClassFelt252 of core::Into<Class, felt252> {
    #[inline]
    fn into(self: Class) -> felt252 {
        match self {
            Class::Knight => 'KNIGHT',
            Class::Ranger => 'RANGER',
            Class::Priest => 'PRIEST',
            Class::AirSkeleton => 'AIR_SKELETON',
            Class::AirSpider => 'AIR_SPIDER',
            Class::AirTarentula => 'AIR_TARENTULA',
            Class::AirUndead => 'AIR_UNDEAD',
            Class::FireGoblin => 'FIRE_GOBLIN',
            Class::FireHobgoblin => 'FIRE_HOBGOBLIN',
            Class::FireSkeleton => 'FIRE_SKELETON',
            Class::FireUndead => 'FIRE_UNDEAD',
            Class::WaterGoblin => 'WATER_GOBLIN',
            Class::WaterHobgoblin => 'WATER_HOBGOBLIN',
            Class::WaterSpider => 'WATER_SPIDER',
            Class::WaterTarentula => 'WATER_TARENTULA',
            _ => 'NONE',
        }
    }
}

impl ClassPrint of core::debug::PrintTrait<Class> {
    #[inline]
    fn print(self: Class) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
