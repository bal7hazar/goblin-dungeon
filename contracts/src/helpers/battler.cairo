// Core imports

use core::debug::PrintTrait;

// Internal imports

use rpg::models::mob::{Mob, MobTrait};
use rpg::types::element::{Element, ElementTrait};

// Errors

mod errors {
    const BATTLER_INVALID_INPUTS: felt252 = 'Battler: invalid inputs';
}

#[generate_trait]
impl Battler of BattlerTrait {
    #[inline]
    fn start(ref mobs: Array<Mob>, ref monsters: Array<Mob>) {
        // [Check] Mobs and monsters lengths are equal
        assert(mobs.len() == monsters.len(), errors::BATTLER_INVALID_INPUTS);
        // [Compute] Prior fight
        let mut count = mobs.len();
        loop {
            if count == 0 {
                break;
            }
            // [Compute] Extract mobs and monsters
            let mut lhs = mobs.pop_front().unwrap();
            let mut rhs = monsters.pop_front().unwrap();
            Self::fight(ref lhs, ref rhs, true, ref mobs, ref monsters);
            // [Effect] Push updated mobs and monsters
            mobs.append(lhs);
            monsters.append(rhs);
            // [Compute] Decrease counter
            count -= 1;
        };
        // [Compute] Later fight
        let mut count = mobs.len();
        loop {
            if count == 0 {
                break;
            }
            // [Compute] Extract mobs and monsters
            let mut lhs = mobs.pop_front().unwrap();
            let mut rhs = monsters.pop_front().unwrap();
            Self::fight(ref lhs, ref rhs, false, ref mobs, ref monsters);
            // [Effect] Push updated mobs and monsters
            mobs.append(lhs);
            monsters.append(rhs);
            // [Compute] Decrease counter
            count -= 1;
        };
    }

    #[inline]
    fn fight(ref lhs: Mob, ref rhs: Mob, prior: bool, ref mates: Array<Mob>, ref foes: Array<Mob>) {
        // [Compute] Priority
        let lhs_element: Element = lhs.element.into();
        let rhs_element: Element = rhs.element.into();
        if (prior && lhs_element.has_priority_over(rhs_element))
            || (!prior && !lhs_element.has_priority_over(rhs_element)) {
            // [Effect] Left hand side mob attacks first
            lhs.perform(ref rhs, ref mates, ref foes);
            lhs.finish();
        } else {
            // [Effect] Right hand side mob attacks first
            rhs.perform(ref lhs, ref foes, ref mates);
            rhs.finish();
        };
    }

    #[inline]
    fn status(mut mobs: Array<Mob>) -> bool {
        // [Compute] Check if any mob is alive
        loop {
            match mobs.pop_front() {
                Option::Some(mob) => {
                    if !mob.is_dead() {
                        // [Return] At least one mob is alive
                        break true;
                    }
                },
                Option::None => { break false; },
            };
        }
    }
}

#[cfg(test)]
mod tests {
    // Core imports

    use core::debug::PrintTrait;

    // Internal imports

    use rpg::types::class::{Role, RoleTrait};
    use rpg::types::class::{Monster, MonsterTrait};
    use rpg::types::spell::{Spell, SpellTrait};

    // Local imports

    use super::{Battler, BattlerTrait, Mob, MobTrait, Element, ElementTrait};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const TEAM_ID: u32 = 42;

    #[test]
    fn test_battler_fight_priority_low() {
        // [Setup]
        let mut mates: Array<Mob> = array![
            MobTrait::from_role(DUNGEON_ID, TEAM_ID, 0, role: Role::Knight, element: Element::Fire),
        ];
        let mut foes: Array<Mob> = array![
            MobTrait::from_monster(DUNGEON_ID, TEAM_ID, 0, monster: Monster::FireGoblin),
        ];
        let mut mate = mates.pop_front().unwrap();
        mate.update(Spell::Stun);
        let mut foe = foes.pop_front().unwrap();
        // [Fight]
        let mate_healh = mate.health;
        Battler::fight(ref mate, ref foe, true, ref mates, ref foes);
        // [Assert]
        assert_eq!(mate.health < mate_healh, true);
        // [Fight]
        Battler::fight(ref mate, ref foe, false, ref mates, ref foes);
        // [Assert]
        assert_eq!(foe.stun, 1);
    }
}
