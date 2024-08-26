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
fn test_actions_attack() {
    // [Setup]
    let (world, systems, _context) = setup::spawn_game();
    let store = StoreTrait::new(world);

    // [Move]
    systems.actions.move(Direction::North.into());

    // [Assert]
    let player = store.get_player(PLAYER().into());
    let factory = store.get_factory(constants::FACTORY_ID);
    let team = store.get_team(factory.dungeon_id(), player.team_id);
    let mate_1 = store.get_mob(team.dungeon_id, team.id, 0);
    let mate_2 = store.get_mob(team.dungeon_id, team.id, 1);
    let mate_3 = store.get_mob(team.dungeon_id, team.id, 2);
    let foe_1 = store.get_mob(team.dungeon_id, team.id, 3);
    let foe_2 = store.get_mob(team.dungeon_id, team.id, 4);
    let foe_3 = store.get_mob(team.dungeon_id, team.id, 5);
    let mate_health: u16 = mate_1.health.into() + mate_2.health.into() + mate_3.health.into();
    let foe_health: u16 = foe_1.health.into() + foe_2.health.into() + foe_3.health.into();

    // [Attack]
    systems.actions.attack(0x012, 0, 0);

    // [Assert] Teams health
    let player = store.get_player(PLAYER().into());
    let factory = store.get_factory(constants::FACTORY_ID);
    let team = store.get_team(factory.dungeon_id(), player.team_id);
    let mate_1 = store.get_mob(team.dungeon_id, team.id, 0);
    let mate_2 = store.get_mob(team.dungeon_id, team.id, 1);
    let mate_3 = store.get_mob(team.dungeon_id, team.id, 2);
    let foe_1 = store.get_mob(team.dungeon_id, team.id, 3);
    let foe_2 = store.get_mob(team.dungeon_id, team.id, 4);
    let foe_3 = store.get_mob(team.dungeon_id, team.id, 5);
    let new_mate_health: u16 = mate_1.health.into() + mate_2.health.into() + mate_3.health.into();
    let new_foe_health: u16 = foe_1.health.into() + foe_2.health.into() + foe_3.health.into();
    assert_eq!(mate_health != new_mate_health, true);
    assert_eq!(foe_health != new_foe_health, true);
}
