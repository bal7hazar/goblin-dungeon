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
    use rpg::models::room::{Room, RoomTrait, RoomAssert};
    use rpg::models::team::{Team, TeamTrait, TeamAssert};
    use rpg::models::character::{Character, CharacterTrait, CharacterAssert};
    use rpg::models::challenge::{Challenge, ChallengeTrait, ChallengeAssert};
    use rpg::types::class::Class;
    use rpg::types::element::Element;
    use rpg::types::direction::Direction;
    use rpg::helpers::battler::Battler;

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

            // [Effect] Create the spawn room
            let mut room = RoomTrait::new(dungeon_id, 0, 0);
            room.seed = dungeon.seed;

            // [Effect] Store room
            store.set_room(room);

            // [Effect] Store dungeon
            store.set_dungeon(dungeon);

            // [Effect] Store factory
            store.set_factory(factory);
        }

        fn spawn(self: @ComponentState<TContractState>, world: IWorldDispatcher,) {
            // [Setup] Datastore
            let store: Store = StoreTrait::new(world);

            // [Check] Player exists
            let player_id: felt252 = get_caller_address().into();
            let mut player = store.get_player(player_id);
            player.assert_is_created();

            // [Check] Dungeon is not done
            let factory = store.get_factory(FACTORY_ID);
            let dungeon_id = factory.dungeon_id();
            let mut dungeon = store.get_dungeon(dungeon_id);
            dungeon.assert_not_done();

            // [Check] Team does not exist
            let team = store.get_team(dungeon.id, player.team_id);
            team.assert_not_exists();

            // [Effect] Assemble team
            let team_id = dungeon.spawn_team();
            let team = TeamTrait::new(dungeon_id, team_id, dungeon.seed, player_id);
            player.assemble(team_id);

            // [Effect] Create characters
            // TODO: Hardcoded characters, could be configurable
            let knight = CharacterTrait::new(dungeon_id, team_id, 0, Class::Knight, Element::Fire);
            let ranger = CharacterTrait::new(dungeon_id, team_id, 1, Class::Ranger, Element::Air);
            let priest = CharacterTrait::new(dungeon_id, team_id, 2, Class::Priest, Element::Water);
            store.set_character(knight);
            store.set_character(ranger);
            store.set_character(priest);

            // [Effect] Store team
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

            // [Check] Challenge is completed
            let challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_is_completed();

            // [Effect] Move team
            team.move(direction.into());

            // [Check] Challenge not already completed
            let challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Effect] Create room if it does not exist
            let room = store.get_room(dungeon.id, team.x, team.y);
            if !room.is_explored() {
                // [Effect] Create room
                let mut room = RoomTrait::new(dungeon.id, team.x, team.y);
                room.explore(team.seed);

                // [Effect] Store room
                store.set_room(room);
            }

            // [Effect] Generate monsters
            let caster_index = room.pick(team.seed);
            let mut monsters = room.get_monsters();
            // FIXME: Maybe find a better way to define the starting index of monsters
            let mut index = 4;
            loop {
                match monsters.pop_front() {
                    Option::Some(packed) => {
                        // [Effect] Create monster
                        let mut monster = CharacterTrait::from(dungeon.id, team.id, index, packed);
                        if monster.class == Class::None.into() {
                            monster.clean();
                        } else if index == caster_index {
                            monster.setup();
                        }
                        // [Effect] Store monster
                        store.set_character(monster);
                        index += 1;
                    },
                    Option::None => { break; },
                }
            };

            // [Effect] Update team
            store.set_team(team);
        }

        fn attack(self: @ComponentState<TContractState>, world: IWorldDispatcher) {
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

            // [Check] Challenge is not completed
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Compute] Battle
            let mut mates = store.get_mates(dungeon.id, team.id);
            let mut monsters = store.get_monsters(dungeon.id, team.id);
            Battler::start(ref mates, ref monsters);

            // [Effect] Update challenge status
            let mates_status = Battler::status(mates.clone());
            let monsters_status = Battler::status(monsters.clone());
            challenge.completed = mates_status && !monsters_status;

            // [Effect] Update characters
            store.set_characters(ref mates);
            store.set_characters(ref monsters);

            // [Effect] Update team status
            team.dead = !mates_status;
            store.set_team(team);
        }
    }
}
