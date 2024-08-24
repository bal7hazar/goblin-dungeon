// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::models::index::Challenge;

// Errors

mod errors {
    const CHALLENGE_NOT_COMPLETED: felt252 = 'Challenge: not completed';
    const CHALLENGE_ALREADY_COMPLETED: felt252 = 'Challenge: already completed';
}

#[generate_trait]
impl ChallengeImpl of ChallengeTrait {
    #[inline]
    fn new(dungeon_id: u32, team_id: u32, x: i32, y: i32) -> Challenge {
        Challenge { dungeon_id, team_id, x, y, completed: false, nonce: 0 }
    }

    #[inline]
    fn complete(ref self: Challenge, status: bool) {
        // [Check] Not already completed
        self.assert_not_completed();
        // [Effect] Set completed
        self.completed = status;
    }

    #[inline]
    fn iter(ref self: Challenge) {
        self.nonce += 1;
    }
}

#[generate_trait]
impl ChallengeAssert of AssertTrait {
    #[inline]
    fn assert_is_completed(self: Challenge) {
        assert(self.completed || (self.x == 0 && self.y == 0), errors::CHALLENGE_NOT_COMPLETED);
    }

    #[inline]
    fn assert_not_completed(self: Challenge) {
        assert(!self.completed, errors::CHALLENGE_ALREADY_COMPLETED);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Challenge, ChallengeTrait, AssertTrait};

    // Constants

    const DUNGEON_ID: u32 = 1;
    const TEAM_ID: u32 = 42;
    const X: i32 = -5;
    const Y: i32 = 42;

    #[test]
    fn test_challenge_new() {
        let challenge: Challenge = ChallengeTrait::new(DUNGEON_ID, TEAM_ID, X, Y);
        assert_eq!(challenge.dungeon_id, DUNGEON_ID);
        assert_eq!(challenge.team_id, TEAM_ID);
        assert_eq!(challenge.x, X);
        assert_eq!(challenge.y, Y);
        assert_eq!(challenge.completed, false);
        assert_eq!(challenge.nonce, 0);
    }

    #[test]
    fn test_dungeon_complete() {
        let mut challenge: Challenge = ChallengeTrait::new(DUNGEON_ID, TEAM_ID, X, Y);
        challenge.complete(true);
        challenge.assert_is_completed();
    }

    #[test]
    #[should_panic(expected: ('Challenge: already completed',))]
    fn test_dungeon_explore_twice() {
        let mut challenge: Challenge = ChallengeTrait::new(DUNGEON_ID, TEAM_ID, X, Y);
        challenge.complete(true);
        challenge.assert_is_completed();
        challenge.complete(true);
    }
}

