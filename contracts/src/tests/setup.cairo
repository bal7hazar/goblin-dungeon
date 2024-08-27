mod setup {
    // Core imports

    use core::debug::PrintTrait;

    // Starknet imports

    use starknet::ContractAddress;
    use starknet::testing::{set_contract_address, set_block_timestamp};

    // Dojo imports

    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::utils::test::{spawn_test_world};

    // Internal imports

    use rpg::models::index;
    use rpg::types::direction::Direction;
    use rpg::types::category::Category;
    use rpg::helpers::seeder::Seeder;
    use rpg::systems::actions::{actions, IActions, IActionsDispatcher, IActionsDispatcherTrait};

    // Constants

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    const PLAYER_NAME: felt252 = 'PLAYER';

    #[derive(Drop)]
    struct Systems {
        actions: IActionsDispatcher,
    }

    #[derive(Drop)]
    struct Context {
        player_id: felt252,
        player_name: felt252,
    }

    #[inline]
    fn next(category: Category) -> (felt252, Direction) {
        let (low, high) = match category {
            Category::Exit => (0, 1),
            Category::Burn => (1, 41),
            Category::Spell => (41, 81),
            Category::Fountain => (81, 121),
            Category::Adventurer => (121, 161),
            Category::Monster => (161, 1000),
            _ => (0, 0),
        };
        let mut base: felt252 = 0;
        loop {
            let seed: u256 = Seeder::reseed(base, 1).into();
            if seed % 1000 >= low && seed % 1000 < high {
                break (base, Direction::North);
            }
            let seed: u256 = Seeder::reseed(base, 2).into();
            if seed % 1000 >= low && seed % 1000 < high {
                break (base, Direction::East);
            }
            let seed: u256 = Seeder::reseed(base, 3).into();
            if seed % 1000 >= low && seed % 1000 < high {
                break (base, Direction::South);
            }
            let seed: u256 = Seeder::reseed(base, 4).into();
            if seed % 1000 >= low && seed % 1000 < high {
                break (base, Direction::West);
            }
            base += 1;
        }
    }

    #[inline]
    fn spawn_game() -> (IWorldDispatcher, Systems, Context) {
        // [Setup] World
        let models = array![
            index::player::TEST_CLASS_HASH,
            index::factory::TEST_CLASS_HASH,
            index::dungeon::TEST_CLASS_HASH,
            index::room::TEST_CLASS_HASH,
            index::team::TEST_CLASS_HASH,
            index::mob::TEST_CLASS_HASH,
            index::challenge::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(array!["goblin_dungeon"].span(), models.span());

        // [Setup] Systems
        let actions_address = world
            .deploy_contract('actions', actions::TEST_CLASS_HASH.try_into().unwrap());
        let systems = Systems {
            actions: IActionsDispatcher { contract_address: actions_address },
        };
        world.grant_writer(dojo::utils::bytearray_hash(@"goblin_dungeon"), actions_address);
        world.grant_writer(dojo::utils::bytearray_hash(@"goblin_dungeon"), PLAYER());

        // [Setup] Initialize
        set_block_timestamp(1);
        world
            .init_contract(
                dojo::utils::selector_from_names(@"goblin_dungeon", @"actions"), array![].span()
            );

        // [Setup] Context
        set_contract_address(PLAYER());
        systems.actions.signup(PLAYER_NAME);
        systems.actions.spawn();
        let context = Context { player_id: PLAYER().into(), player_name: PLAYER_NAME, };

        // [Return]
        (world, systems, context)
    }
}
