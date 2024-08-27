// Core imports

use core::debug::PrintTrait;

// Starknet imports

use starknet::testing::{set_contract_address, set_transaction_hash};

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use grimscape::constants;
use grimscape::store::{Store, StoreTrait};
use grimscape::models::player::{Player, PlayerTrait};
use grimscape::models::factory::{Factory, FactoryTrait};
use grimscape::models::dungeon::{Dungeon, DungeonTrait};
use grimscape::types::direction::Direction;
use grimscape::systems::actions::IActionsDispatcherTrait;
use grimscape::tests::setup::{setup, setup::{Systems, PLAYER}};

#[test]
fn test_actions_move() {
    // [Setup]
    let (world, systems, _context) = setup::spawn_game();
    let store = StoreTrait::new(world);

    // [Move]
    systems.actions.move(Direction::North.into());

    // [Assert]
    let player = store.get_player(PLAYER().into());
    let factory = store.get_factory(constants::FACTORY_ID);
    let team = store.get_team(factory.dungeon_id(), player.team_id);
    assert_eq!(team.y, 1);
}
