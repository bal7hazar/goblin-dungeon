// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::models::index::Mob;
use rpg::types::direction::Direction;
use rpg::types::role::{Role, RoleTrait};
use rpg::types::element::{Element, ElementTrait};
use rpg::types::spell::{Spell, SpellTrait};
use rpg::types::monster::{Monster, MonsterTrait};
use rpg::types::threat::{Threat, ThreatTrait};
use rpg::helpers::packer::Packer;
use rpg::helpers::seeder::Seeder;

mod errors {
    const MOB_NOT_EXIST: felt252 = 'Mob: does not exist';
    const MOB_ALREADY_EXIST: felt252 = 'Mob: already exist';
    const MOB_INVALID_DIRECTION: felt252 = 'Mob: invalid direction';
    const MOB_IS_DEAD: felt252 = 'Mob: is dead';
    const MOB_NOT_DEAD: felt252 = 'Mob: not dead';
}

#[generate_trait]
impl MobImpl of MobTrait {
    #[inline]
    fn new(
        dungeon_id: u32,
        team_id: u32,
        index: u8,
        class: u8,
        threat: Threat,
        health: u8,
        element: Element
    ) -> Mob {
        // [Return] Mob
        Mob {
            dungeon_id,
            team_id,
            index,
            class,
            threat: threat.into(),
            element: element.into(),
            spell: Spell::Punch.into(),
            health: health,
            shield: 0,
            stun: 0,
            multiplier: 1,
        }
    }

    #[inline]
    fn from_monster(
        dungeon_id: u32, team_id: u32, index: u8, monster: Monster, threat: Threat, element: Element
    ) -> Mob {
        Self::new(
            dungeon_id, team_id, index, monster.into(), threat, monster.health(threat), element
        )
    }

    #[inline]
    fn from_role(dungeon_id: u32, team_id: u32, index: u8, role: Role, element: Element) -> Mob {
        Self::new(dungeon_id, team_id, index, role.into(), Threat::None, role.health(), element)
    }

    #[inline]
    fn setup_monster(ref self: Mob) {
        let threat: Threat = self.threat.into();
        let element: Element = self.element.into();
        let monster: Monster = self.class.into();
        self.spell = monster.spell(threat, element).into();
    }

    #[inline]
    fn clean(ref self: Mob) {
        self.class = 0;
        self.threat = 0;
        self.element = 0;
        self.spell = 0;
        self.health = 0;
        self.shield = 0;
        self.stun = 0;
        self.multiplier = 0;
    }

    #[inline]
    fn is_dead(self: Mob) -> bool {
        self.health == 0
    }

    #[inline]
    fn is_stun(self: Mob) -> bool {
        self.stun > 0
    }

    #[inline]
    fn take(ref self: Mob, damage: u8) {
        if self.is_dead() {
            return;
        }
        let absorbed = core::cmp::min(damage, self.shield);
        self.shield -= absorbed;
        self.health -= core::cmp::min(damage - absorbed, self.health);
    }

    #[inline]
    fn perform(ref self: Mob, ref target: Mob, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        if self.is_stun() || self.is_dead() {
            return;
        }
        let spell: Spell = self.spell.into();
        spell.apply(ref self, ref target, ref mates, ref foes);
    }

    #[inline]
    fn heal(ref self: Mob, heal: u8) {
        if self.is_dead() {
            return;
        }
        let base_health = if self.index > 2 {
            let monster: Monster = self.class.into();
            let threat: Threat = self.threat.into();
            monster.health(threat)
        } else {
            let role: Role = self.class.into();
            role.health()
        };
        self.health += core::cmp::min(heal, base_health - self.health);
    }

    #[inline]
    fn restore(ref self: Mob) {
        // [Info] Can resurect dead mob
        let base_health = if self.index > 2 {
            let monster: Monster = self.class.into();
            let threat: Threat = self.threat.into();
            monster.health(threat)
        } else {
            let role: Role = self.class.into();
            role.health()
        };
        self.health = base_health;
    }

    #[inline]
    fn stun(ref self: Mob, quantity: u8) {
        if self.is_dead() {
            return;
        }
        // [Info] Not stackable
        self.stun = quantity;
    }

    #[inline]
    fn shield(ref self: Mob, quantity: u8) {
        if self.is_dead() {
            return;
        }
        // [Info] Not stackable
        self.shield = quantity;
    }

    #[inline]
    fn buff(ref self: Mob, multiplier: u8) {
        self.multiplier = multiplier;
    }

    #[inline]
    fn debuff(ref self: Mob) {
        self.multiplier = 1;
    }

    #[inline]
    fn update(ref self: Mob, spell: Spell) {
        self.spell = spell.into();
    }

    #[inline]
    fn finish(ref self: Mob) {
        self.spell = Spell::Punch.into();
        self.stun -= core::cmp::min(self.stun, 1);
    }
}

#[generate_trait]
impl MobAssert of AssertTrait {
    #[inline]
    fn assert_not_dead(self: Mob) {
        assert(self.health != 0, errors::MOB_IS_DEAD);
    }

    #[inline]
    fn assert_is_dead(self: Mob) {
        assert(self.health == 0, errors::MOB_NOT_DEAD);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Mob, MobTrait, MobAssert, Monster, Role, RoleTrait, Element, Spell, Threat};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const TEAM_ID: u32 = 42;
    const INDEX: u8 = 0;
    const ROLE: Role = Role::Knight;
    const THREAT: Threat = Threat::None;
    const ELEMENT: Element = Element::Fire;

    #[test]
    fn test_mob_new() {
        let mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        assert_eq!(mob.dungeon_id, DUNGEON_ID);
        assert_eq!(mob.team_id, TEAM_ID);
        assert_eq!(mob.index, INDEX);
        assert_eq!(mob.class, ROLE.into());
        assert_eq!(mob.element, ELEMENT.into());
        assert_eq!(mob.spell, Spell::Punch.into());
        assert_eq!(mob.health, ROLE.health());
        assert_eq!(mob.shield, 0);
        assert_eq!(mob.stun, 0);
        assert_eq!(mob.multiplier, 1);
    }

    #[test]
    fn test_mob_is_stun() {
        let mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        assert_eq!(mob.is_stun(), false);
    }

    #[test]
    fn test_mob_take() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.take(10);
        assert_eq!(mob.health, ROLE.health() - 10);
    }

    #[test]
    fn test_mob_heal() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.take(10);
        mob.heal(5);
        assert_eq!(mob.health, ROLE.health() - 5);
    }

    #[test]
    fn test_mob_stun() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.stun(1);
        assert_eq!(mob.stun, 1);
    }

    #[test]
    fn test_mob_shield() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.shield(5);
        assert_eq!(mob.shield, 5);
    }

    #[test]
    fn test_mob_update() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.update(Spell::Heal);
        assert_eq!(mob.spell, Spell::Heal.into());
    }

    #[test]
    fn test_mob_finish() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.stun(1);
        mob.finish();
        assert_eq!(mob.stun, 0);
        assert_eq!(mob.spell, Spell::Punch.into());
    }

    #[test]
    #[should_panic(expected: ('Mob: is dead',))]
    fn test_mob_assert_not_dead() {
        let mut mob = MobTrait::new(
            DUNGEON_ID, TEAM_ID, INDEX, ROLE.into(), THREAT, ROLE.health(), ELEMENT
        );
        mob.health = 0;
        mob.assert_not_dead();
    }
}

