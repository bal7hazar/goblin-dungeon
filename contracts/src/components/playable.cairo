#[starknet::component]
mod PlayableComponent {
    // Core imports

    use core::debug::PrintTrait;

    // Starknet imports

    use starknet::ContractAddress;
    use starknet::info::{get_caller_address, get_block_timestamp};

    // Dojo imports

    use dojo::world::IWorldDispatcher;
    use dojo::world::IWorldDispatcherTrait;

    // Internal imports

    use rpg::constants;
    use rpg::store::{Store, StoreTrait};
    use rpg::models::factory::{Factory, FactoryTrait};
    use rpg::models::player::{Player, PlayerTrait, PlayerAssert};
    use rpg::models::dungeon::{Dungeon, DungeonTrait, DungeonAssert};
    use rpg::models::team::{Team, TeamTrait, TeamAssert};
    use rpg::models::character::{Character, CharacterTrait, CharacterAssert};
    use rpg::types::class::Class;
    use rpg::types::element::Element;
    use rpg::types::direction::Direction;

    // Constants

    const FACTORY_ID: u32 = 1;

    // Errors

    mod errors {}

    // Storage

    #[storage]
    struct Storage {}

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {}

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        fn initialize(self: @ComponentState<TContractState>, world: IWorldDispatcher,) {
            // [Setup] Datastore
            let store: Store = StoreTrait::new(world);

            // [Effect] Create factory
            let mut factory = FactoryTrait::new(FACTORY_ID);

            // [Effect] Create dungeon
            let dungeon_id = factory.generate();
            let seed: felt252 = get_block_timestamp().into();
            let dungeon = DungeonTrait::new(dungeon_id, seed);

            // [Effect] Set dungeon
            store.set_dungeon(dungeon);

            // [Effect] Set factory
            store.set_factory(factory);
        }

        fn spawn(self: @ComponentState<TContractState>, world: IWorldDispatcher,) {
            // [Setup] Datastore
            let store: Store = StoreTrait::new(world);

            // [Check] Player exists
            let player_id: felt252 = get_caller_address().into();
            let mut player = store.get_player(player_id);
            player.assert_is_created();

            // [Check] Player not manager
            player.assert_not_manager();

            // [Check] Dungeon is not done
            let factory = store.get_factory(FACTORY_ID);
            let dungeon_id = factory.dungeon_id();
            let mut dungeon = store.get_dungeon(dungeon_id);
            dungeon.assert_not_done();

            // [Check] Team does not exist
            let team_id = dungeon.spawn_team();
            let team = store.get_team(dungeon.id, team_id);
            team.assert_not_exists();

            // [Effect] Assemble team
            player.assemble(team_id);

            // [Effect] Create characters
            // TODO: Hardcoded characters, could be configurable
            let knight = CharacterTrait::new(dungeon_id, team_id, 0, Class::Knight, Element::Fire);
            let ranger = CharacterTrait::new(dungeon_id, team_id, 1, Class::Ranger, Element::Air);
            let priest = CharacterTrait::new(dungeon_id, team_id, 2, Class::Priest, Element::Water);
            store.set_character(knight);
            store.set_character(ranger);
            store.set_character(priest);

            // [Effect] Set team
            store.set_team(team);

            // [Effect] Update dungeon
            store.set_dungeon(dungeon);

            // [Effect] Update player
            store.set_player(player);
        }

        fn move(self: @ComponentState<TContractState>, world: IWorldDispatcher, direction: u8) {
            // [Setup] Datastore
            let store: Store = StoreTrait::new(world);

            // [Check] Player exists
            let player_id: felt252 = get_caller_address().into();
            let player = store.get_player(player_id);
            player.assert_is_created();

            // [Check] Dungeon is not done
            let factory = store.get_factory(FACTORY_ID);
            let dungeon_id = factory.dungeon_id();
            let dungeon = store.get_dungeon(dungeon_id);
            dungeon.assert_not_done();

            // [Check] Team is not dead
            let mut team = store.get_team(dungeon.id, player.team_id);
            team.assert_not_dead();

            // [Effect] Move team
            team.move(direction.into());

            // [Effect] Update team
            store.set_team(team);
        }
    }
}
