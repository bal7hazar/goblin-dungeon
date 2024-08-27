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

#[test]
fn test_actions_attack_exit() {
    // [Setup]
    let (world, systems, context) = setup::spawn_game();
    let store = StoreTrait::new(world);

    // [Move]
    systems.actions.move(Direction::South.into());

    // [Attack]
    // 0:Heal|1:Kick|2:Heal
    // 0:MagA(100)|1:BarF(100)|2:BarA(100)
    // 0:WarW(240)|1:MinA(60)|2:----
    systems.actions.attack(0x210, 1, 0);
    // 0:Stomp|1:Kick|2:Kick
    // 0:MagA(80)|1:BarF(80)|2:BarA(100)
    // 0:WarW(210)|1:MinA(30)|2:----
    systems.actions.attack(0x210, 0, 1);
    // 0:Kick|1:Heal|2:Kick
    // 0:MagA(60)|1:BarF(80)|2:BarA(100)
    // 0:WarW(190)|1:MinA(0)|2:----
    systems.actions.attack(0x012, 0, 2);
    // 0:Zephyr|1:Stomp|2:Heal
    // 0:BarA(80)|1:BarF(80)|2:MagA(60)
    // 0:WarW(160)|1:MinA(0)|2:----
    systems.actions.attack(0x210, 1, 0);
    // 0:Heal|1:Kick|2:Stomp
    // 0:BarA(80)|1:BarF(80)|2:MagA(60)
    // 0:WarW(120)|1:MinA(0)|2:----
    systems.actions.attack(0x210, 2, 0);
    // 0:Kick|1:Heal|2:Heal
    // 0:BarA(80)|1:BarF(80)|2:MagA(60)
    // 0:WarW(80)|1:MinA(0)|2:----
    systems.actions.attack(0x210, 0, 0);
    // 0:HEAL|1:STOMP|2:ZEPHYR
    // 0:BarA(80)|1:BarF(80)|2:MagA(60)
    // 0:WarW(50)|1:MinA(0)|2:----
    systems.actions.attack(0x210, 1, 0);
    // 0:HEAL|1:STOMP|2:ZEPHYR
    // 0:BarA(80)|1:BarF(80)|2:MagA(60)
    // 0:WarW(10)|1:MinA(0)|2:----
    systems.actions.attack(0x210, 0, 2);
    // 0:HEAL|1:STOMP|2:ZEPHYR
    // 0:BarA(80)|1:BarF(80)|2:MagA(60)
    // 0:WarW(0)|1:MinA(0)|2:----

    // [Setup] Change seed to define an exit
    let player = store.get_player(PLAYER().into());
    let factory = store.get_factory(constants::FACTORY_ID);
    let mut team = store.get_team(factory.dungeon_id(), player.team_id);
    let (seed, direction) = next(Category::Exit);
    team.seed = seed;
    store.set_team(team);

    // [Move]
    systems.actions.move(direction.into());

    // [Assert] Dungeon
    let dungeon = store.get_dungeon(factory.dungeon_id());
    assert_eq!(dungeon.name, context.player_name);

    // [Assert] Factory
    let factory = store.get_factory(constants::FACTORY_ID);
    assert_eq!(factory.dungeon_id(), 2);
}
