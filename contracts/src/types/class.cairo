// Internal imports

use rpg::elements::roles;
use rpg::elements::monsters;
use rpg::types::spell::Spell;

#[derive(Copy, Drop)]
enum Class {
    None,
    Knight,
    Ranger,
    Priest,
    Goblin,
    Skeleton,
    Spider,
}

#[generate_trait]
impl ClassImpl of ClassTrait {
    #[inline]
    fn spell(self: Class) -> Spell {
        match self {
            Class::None => Spell::None,
            Class::Knight => roles::knight::Knight::spell(),
            Class::Ranger => roles::ranger::Ranger::spell(),
            Class::Priest => roles::priest::Priest::spell(),
            Class::Goblin => monsters::goblin::Goblin::spell(),
            Class::Skeleton => monsters::skeleton::Skeleton::spell(),
            Class::Spider => monsters::spider::Spider::spell(),
        }
    }
}

impl IntoClassFelt252 of core::Into<Class, felt252> {
    #[inline(always)]
    fn into(self: Class) -> felt252 {
        match self {
            Class::None => 'NONE',
            Class::Knight => 'KNIGHT',
            Class::Ranger => 'RANGER',
            Class::Priest => 'PRIEST',
            Class::Goblin => 'GOBLIN',
            Class::Skeleton => 'SKELETON',
            Class::Spider => 'SPIDER',
        }
    }
}

impl IntoClassU8 of core::Into<Class, u8> {
    #[inline(always)]
    fn into(self: Class) -> u8 {
        match self {
            Class::None => 0,
            Class::Knight => 1,
            Class::Ranger => 2,
            Class::Priest => 3,
            Class::Goblin => 4,
            Class::Skeleton => 5,
            Class::Spider => 6,
        }
    }
}

impl IntoU8Class of core::Into<u8, Class> {
    #[inline(always)]
    fn into(self: u8) -> Class {
        let card: felt252 = self.into();
        match card {
            0 => Class::None,
            1 => Class::Knight,
            2 => Class::Ranger,
            3 => Class::Priest,
            4 => Class::Goblin,
            5 => Class::Skeleton,
            6 => Class::Spider,
            _ => Class::None,
        }
    }
}

impl ClassPrint of core::debug::PrintTrait<Class> {
    #[inline(always)]
    fn print(self: Class) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
