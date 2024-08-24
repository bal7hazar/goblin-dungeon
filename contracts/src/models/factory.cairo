// Core imports

use core::debug::PrintTrait;

// Inernal imports

use rpg::models::index::Factory;

mod errors {}

#[generate_trait]
impl FactoryImpl of FactoryTrait {
    #[inline]
    fn new(id: u32) -> Factory {
        // [Return] Factory
        Factory { id, dungeon_id: 0 }
    }

    #[inline]
    fn dungeon_id(self: Factory) -> u32 {
        // [Return] Dungeon id
        self.dungeon_id
    }

    #[inline]
    fn generate(ref self: Factory) -> u32 {
        // [Effect] Increase dungeon id
        self.dungeon_id += 1;
        // [Return] Dungeon id
        self.dungeon_id
    }
}

#[generate_trait]
impl FactoryAssert of AssertTrait {}

#[cfg(test)]
mod tests {
    // Local imports

    use super::{Factory, FactoryTrait};

    // Constants

    const FACTORY_ID: u32 = 1;

    #[test]
    fn test_factory_new() {
        let factory = FactoryTrait::new(FACTORY_ID);
        assert_eq!(factory.id, FACTORY_ID);
        assert_eq!(factory.dungeon_id, 0);
    }

    #[test]
    fn test_factory_gen() {
        let mut factory = FactoryTrait::new(FACTORY_ID);
        assert_eq!(factory.generate(), 1);
        assert_eq!(factory.generate(), 2);
    }
}

