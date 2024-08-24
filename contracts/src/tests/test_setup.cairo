// Core imports

use core::debug::PrintTrait;

// Starknet imports

use starknet::testing::{set_contract_address, set_transaction_hash};

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use rpg::constants;
use rpg::store::{Store, StoreTrait};
use rpg::models::player::{Player, PlayerTrait};
use rpg::models::factory::{Factory, FactoryTrait};
use rpg::models::dungeon::{Dungeon, DungeonTrait};
use rpg::systems::actions::IActionsDispatcherTrait;

// Test imports

use rpg::tests::setup::{setup, setup::{Systems, PLAYER}};

#[test]
fn test_actions_setup() {
    // [Setup]
    let (world, _, context) = setup::spawn_game();
    let store = StoreTrait::new(world);

    // [Assert] Player
    let player = store.get_player(context.player_id);
    assert_eq!(player.id, context.player_id);

    // [Assert] Factory
    let factory = store.get_factory(constants::FACTORY_ID);
    assert_eq!(factory.id, constants::FACTORY_ID);

    // [Assert] Dungeon
    let dungeon = store.get_dungeon(factory.dungeon_id());
    assert_eq!(dungeon.seed != 0, true);
}
