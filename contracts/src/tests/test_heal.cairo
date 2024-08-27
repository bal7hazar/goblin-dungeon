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
use grimscape::models::room::{Room, RoomTrait};
use grimscape::types::direction::Direction;
use grimscape::types::category::Category;
use grimscape::types::spell::Spell;
use grimscape::types::element::Element;
use grimscape::types::monster::Monster;
use grimscape::types::role::Role;
use grimscape::systems::actions::IActionsDispatcherTrait;
use grimscape::tests::setup::{setup, setup::{Systems, PLAYER, next}};

#[test]
fn test_actions_fountain() {
    // [Setup]
    let (world, systems, _context) = setup::spawn_game();
    let store = StoreTrait::new(world);

    // [Setup] Change seed to define a spell
    let player = store.get_player(PLAYER().into());
    let factory = store.get_factory(constants::FACTORY_ID);
    let mut team = store.get_team(factory.dungeon_id(), player.team_id);
    let (seed, direction) = (0, Direction::West); // next(Category::Fountain);
    team.seed = seed;
    store.set_team(team);

    // [Move]
    systems.actions.move(direction.into());

    // [Setup] Mob health
    let mut mate = store.get_mob(factory.dungeon_id(), player.team_id, 0);
    mate.health = 50;
    store.set_mob(mate);

    // [Restore]
    systems.actions.heal();

    // [Assert]
    let mate = store.get_mob(factory.dungeon_id(), player.team_id, 0);
    assert_eq!(mate.health, 200);
}
