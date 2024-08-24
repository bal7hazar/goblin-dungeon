// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::models::index::Team;
use rpg::types::direction::Direction;
use rpg::helpers::seeder::Seeder;

mod errors {
    const TEAM_NOT_EXIST: felt252 = 'Team: does not exist';
    const TEAM_ALREADY_EXIST: felt252 = 'Team: already exist';
    const TEAM_INVALID_DIRECTION: felt252 = 'Team: invalid direction';
    const TEAM_IS_DEAD: felt252 = 'Team: is dead';
}

#[generate_trait]
impl TeamImpl of TeamTrait {
    #[inline]
    fn new(dungeon_id: u32, id: u32, seed: felt252, player_id: felt252) -> Team {
        // [Return] Team
        Team { dungeon_id, id, x: 0, y: 0, dead: false, seed, player_id, }
    }

    #[inline]
    fn move(ref self: Team, direction: Direction) {
        // [Check] Direction is valid
        let direction_id: u8 = direction.into();
        assert(direction_id != Direction::None.into(), errors::TEAM_INVALID_DIRECTION);
        // [Effect] Update position
        match direction {
            Direction::North => { self.y += 1; },
            Direction::East => { self.x += 1; },
            Direction::South => { self.y -= 1; },
            Direction::West => { self.x -= 1; },
            _ => {},
        }
        // [Effect] Reseed
        self.seed = Seeder::reseed(self.seed, direction_id.into());
    }
}

#[generate_trait]
impl TeamAssert of AssertTrait {
    #[inline]
    fn assert_exists(self: Team) {
        assert(0 != self.seed && !self.dead, errors::TEAM_NOT_EXIST);
    }

    #[inline]
    fn assert_not_exists(self: Team) {
        assert(0 == self.seed || self.dead, errors::TEAM_ALREADY_EXIST);
    }

    #[inline]
    fn assert_not_dead(self: Team) {
        assert(!self.dead, errors::TEAM_IS_DEAD);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Team, TeamTrait, Direction,};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const TEAM_ID: u32 = 42;
    const SEED: felt252 = 'SEED';
    const PLAYER_ID: felt252 = 'PLAYER';

    #[test]
    fn test_team_new() {
        let team = TeamTrait::new(DUNGEON_ID, TEAM_ID, SEED, PLAYER_ID);
        assert_eq!(team.dungeon_id, DUNGEON_ID);
        assert_eq!(team.id, TEAM_ID);
        assert_eq!(team.x, 0);
        assert_eq!(team.y, 0);
        assert_eq!(team.dead, false);
        assert_eq!(team.seed, SEED);
    }

    #[test]
    fn test_team_move_north() {
        let mut team = TeamTrait::new(DUNGEON_ID, TEAM_ID, SEED, PLAYER_ID);
        let seed = team.seed;
        team.move(Direction::North);
        assert_eq!(seed != team.seed, true);
        assert_eq!(team.y, 1);
        assert_eq!(team.x, 0);
    }

    #[test]
    fn test_team_move_east() {
        let mut team = TeamTrait::new(DUNGEON_ID, TEAM_ID, SEED, PLAYER_ID);
        let seed = team.seed;
        team.move(Direction::East);
        assert_eq!(seed != team.seed, true);
        assert_eq!(team.y, 0);
        assert_eq!(team.x, 1);
    }

    #[test]
    fn test_team_move_south() {
        let mut team = TeamTrait::new(DUNGEON_ID, TEAM_ID, SEED, PLAYER_ID);
        let seed = team.seed;
        team.move(Direction::South);
        assert_eq!(seed != team.seed, true);
        assert_eq!(team.y, -1);
        assert_eq!(team.x, 0);
    }

    #[test]
    fn test_team_move_west() {
        let mut team = TeamTrait::new(DUNGEON_ID, TEAM_ID, SEED, PLAYER_ID);
        let seed = team.seed;
        team.move(Direction::West);
        assert_eq!(seed != team.seed, true);
        assert_eq!(team.y, 0);
        assert_eq!(team.x, -1);
    }
}

