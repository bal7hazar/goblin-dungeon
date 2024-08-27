// Internal imports

use grimscape::constants::MOB_BASE_HEALTH;
use grimscape::elements::roles;
use grimscape::elements::monsters;
use grimscape::types::element::Element;
use grimscape::types::spell::Spell;

#[derive(Copy, Drop)]
enum Role {
    None,
    Barbarian,
    Knight,
    Mage,
    Rogue,
}

#[generate_trait]
impl RoleImpl of RoleTrait {
    #[inline]
    fn count() -> u8 {
        4
    }
    #[inline]
    fn health(self: Role) -> u8 {
        200
    }

    #[inline]
    fn spell(self: Role, element: Element) -> Spell {
        match self {
            Role::None => Spell::None,
            Role::Barbarian => roles::barbarian::Barbarian::spell(element),
            Role::Knight => roles::knight::Knight::spell(element),
            Role::Mage => roles::mage::Mage::spell(element),
            Role::Rogue => roles::rogue::Rogue::spell(element),
        }
    }
}

impl IntoRoleFelt252 of core::Into<Role, felt252> {
    #[inline]
    fn into(self: Role) -> felt252 {
        match self {
            Role::None => 'NONE',
            Role::Barbarian => 'BARBARIAN',
            Role::Knight => 'KNIGHT',
            Role::Mage => 'MAGE',
            Role::Rogue => 'ROGUE',
        }
    }
}

impl IntoRoleU8 of core::Into<Role, u8> {
    #[inline]
    fn into(self: Role) -> u8 {
        match self {
            Role::None => 0,
            Role::Barbarian => 1,
            Role::Knight => 2,
            Role::Mage => 3,
            Role::Rogue => 4,
        }
    }
}

impl IntoU8Role of core::Into<u8, Role> {
    #[inline]
    fn into(self: u8) -> Role {
        let card: felt252 = self.into();
        match card {
            0 => Role::None,
            1 => Role::Barbarian,
            2 => Role::Knight,
            3 => Role::Mage,
            4 => Role::Rogue,
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
