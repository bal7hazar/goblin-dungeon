// Internal imports

use rpg::constants::MOB_BASE_HEALTH;
use rpg::elements::roles;
use rpg::elements::monsters;
use rpg::types::spell::Spell;

#[derive(Copy, Drop)]
enum Role {
    None,
    Knight,
    Ranger,
    Priest,
}

#[generate_trait]
impl RoleImpl of RoleTrait {
    #[inline]
    fn count() -> u8 {
        3
    }
    #[inline]
    fn health(self: Role) -> u8 {
        match self {
            Role::None => 0,
            _ => MOB_BASE_HEALTH,
        }
    }

    #[inline]
    fn spell(self: Role) -> Spell {
        match self {
            Role::None => Spell::None,
            Role::Knight => roles::knight::Knight::spell(),
            Role::Ranger => roles::ranger::Ranger::spell(),
            Role::Priest => roles::priest::Priest::spell(),
        }
    }
}

impl IntoRoleFelt252 of core::Into<Role, felt252> {
    #[inline]
    fn into(self: Role) -> felt252 {
        match self {
            Role::None => 'NONE',
            Role::Knight => 'KNIGHT',
            Role::Ranger => 'RANGER',
            Role::Priest => 'PRIEST',
        }
    }
}

impl IntoRoleU8 of core::Into<Role, u8> {
    #[inline]
    fn into(self: Role) -> u8 {
        match self {
            Role::None => 0,
            Role::Knight => 1,
            Role::Ranger => 2,
            Role::Priest => 3,
        }
    }
}

impl IntoU8Role of core::Into<u8, Role> {
    #[inline]
    fn into(self: u8) -> Role {
        let card: felt252 = self.into();
        match card {
            0 => Role::None,
            1 => Role::Knight,
            2 => Role::Ranger,
            3 => Role::Priest,
            _ => Role::None,
        }
    }
}

impl RolePrint of core::debug::PrintTrait<Role> {
    #[inline]
    fn print(self: Role) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
