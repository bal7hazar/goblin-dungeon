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
use rpg::models::room::{Room, RoomTrait};
use rpg::types::direction::Direction;
use rpg::types::category::Category;
use rpg::types::spell::Spell;
use rpg::types::element::Element;
use rpg::types::monster::Monster;
use rpg::types::role::Role;
use rpg::systems::actions::IActionsDispatcherTrait;
use rpg::tests::setup::{setup, setup::{Systems, PLAYER, next}};


#[test]
fn test_actions_burn() {
    // [Setup]
    let (world, systems, _context) = setup::spawn_game();
    let store = StoreTrait::new(world);

    // [Setup] Change seed to define a spell
    let player = store.get_player(PLAYER().into());
    let factory = store.get_factory(constants::FACTORY_ID);
    let mut team = store.get_team(factory.dungeon_id(), player.team_id);
    let (seed, direction) = (0xb, Direction::South); // next(Category::Burn);
    team.seed = seed;
    store.set_team(team);

    // [Move]
    systems.actions.move(direction.into());

    // [Burn]
    systems.actions.burn(1);

    // [Assert]
    let team = store.get_team(team.dungeon_id, player.team_id);
    assert_eq!(team.deck, 0x5bf33322);
}
