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
use rpg::types::direction::Direction;
use rpg::systems::actions::IActionsDispatcherTrait;
use rpg::tests::setup::{setup, setup::{Systems, PLAYER}};

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
