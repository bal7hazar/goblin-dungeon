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
    fn new(player_id: felt252, dungeon_id: u32, seed: felt252) -> Team {
        // [Return] Team
        Team { player_id, dungeon_id, x: 0, y: 0, dead: false, seed, }
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
        assert(0 != self.seed, errors::TEAM_NOT_EXIST);
    }

    #[inline]
    fn assert_not_exists(self: Team) {
        assert(0 == self.seed, errors::TEAM_ALREADY_EXIST);
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

    const PLAYER_ID: felt252 = 'PLAYER';
    const DUNGEON_ID: u32 = 1;
    const SEED: felt252 = 'SEED';

    #[test]
    fn test_player_new() {
        let player = TeamTrait::new(PLAYER_ID, DUNGEON_ID, SEED);
        assert_eq!(player.player_id, PLAYER_ID);
        assert_eq!(player.dungeon_id, DUNGEON_ID);
        assert_eq!(player.x, 0);
        assert_eq!(player.y, 0);
        assert_eq!(player.dead, false);
        assert_eq!(player.seed, SEED);
    }

    #[test]
    fn test_player_move_north() {
        let mut player = TeamTrait::new(PLAYER_ID, DUNGEON_ID, SEED);
        let seed = player.seed;
        player.move(Direction::North);
        assert_eq!(seed != player.seed, true);
        assert_eq!(player.y, 1);
        assert_eq!(player.x, 0);
    }

    #[test]
    fn test_player_move_east() {
        let mut player = TeamTrait::new(PLAYER_ID, DUNGEON_ID, SEED);
        let seed = player.seed;
        player.move(Direction::East);
        assert_eq!(seed != player.seed, true);
        assert_eq!(player.y, 0);
        assert_eq!(player.x, 1);
    }

    #[test]
    fn test_player_move_south() {
        let mut player = TeamTrait::new(PLAYER_ID, DUNGEON_ID, SEED);
        let seed = player.seed;
        player.move(Direction::South);
        assert_eq!(seed != player.seed, true);
        assert_eq!(player.y, -1);
        assert_eq!(player.x, 0);
    }

    #[test]
    fn test_player_move_west() {
        let mut player = TeamTrait::new(PLAYER_ID, DUNGEON_ID, SEED);
        let seed = player.seed;
        player.move(Direction::West);
        assert_eq!(seed != player.seed, true);
        assert_eq!(player.y, 0);
        assert_eq!(player.x, -1);
    }
}

