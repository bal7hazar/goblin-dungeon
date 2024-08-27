// Core imports

use core::debug::PrintTrait;

// Inernal imports

use grimscape::models::index::Dungeon;

mod errors {
    const DUNGEON_NOT_CLAIMED: felt252 = 'Dungeon: not claimed';
    const DUNGEON_ALREADY_CLAIMED: felt252 = 'Dungeon: already claimed';
}

#[generate_trait]
impl DungeonImpl of DungeonTrait {
    #[inline]
    fn new(id: u32, seed: felt252) -> Dungeon {
        Dungeon { id, nonce: 0, seed, name: 0, }
    }

    #[inline]
    fn is_claimed(self: Dungeon) -> bool {
        self.name != 0
    }

    #[inline]
    fn claim(ref self: Dungeon, name: felt252) {
        self.name = name;
    }

    #[inline]
    fn spawn_team(ref self: Dungeon) -> u32 {
        self.nonce += 1;
        self.nonce
    }
}

#[generate_trait]
impl DungeonAssert of AssertTrait {
    #[inline]
    fn assert_is_claimed(self: Dungeon) {
        assert(self.is_claimed(), errors::DUNGEON_NOT_CLAIMED);
    }

    #[inline]
    fn assert_not_done(self: Dungeon) {
        assert(!self.is_claimed(), errors::DUNGEON_ALREADY_CLAIMED);
    }
}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Dungeon, DungeonTrait, AssertTrait};

    // Constants

    const ID: u32 = 1;
    const SEED: felt252 = 'SEED';
    const NAME: felt252 = 'Alice';

    #[test]
    fn test_dungeon_new() {
        let dungeon: Dungeon = DungeonTrait::new(ID, SEED);
        assert_eq!(dungeon.id, ID);
        assert_eq!(dungeon.name, 0);
        assert_eq!(dungeon.is_claimed(), false);
    }

    #[test]
    fn test_dungeon_claim() {
        let mut dungeon: Dungeon = DungeonTrait::new(ID, SEED);
        dungeon.claim(NAME);
        assert_eq!(dungeon.name, NAME);
        assert_eq!(dungeon.is_claimed(), true);
    }
}

