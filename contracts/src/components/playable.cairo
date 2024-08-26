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

    use rpg::constants::FACTORY_ID;
    use rpg::store::{Store, StoreTrait};
    use rpg::models::factory::{Factory, FactoryTrait};
    use rpg::models::player::{Player, PlayerTrait, PlayerAssert};
    use rpg::models::dungeon::{Dungeon, DungeonTrait, DungeonAssert};
    use rpg::models::room::{Room, RoomTrait, RoomAssert};
    use rpg::models::team::{Team, TeamTrait, TeamAssert};
    use rpg::models::mob::{Mob, MobTrait, MobAssert};
    use rpg::models::challenge::{Challenge, ChallengeTrait, ChallengeAssert};
    use rpg::types::role::{Role, RoleTrait};
    use rpg::types::monster::Monster;
    use rpg::types::element::Element;
    use rpg::types::direction::Direction;
    use rpg::types::spell::Spell;
    use rpg::helpers::seeder::Seeder;
    use rpg::helpers::battler::Battler;

    // Errors

    mod errors {
        const PLAYABLE_INVALID_CASTER_INDEX: felt252 = 'Playable: invalid caster index';
    }

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
            let time = get_block_timestamp();
            let seed: felt252 = Seeder::reseed(time.into(), time.into());
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
            let mut team = TeamTrait::new(dungeon_id, team_id, dungeon.seed, player_id);
            player.assemble(team_id);

            // [Effect] Create mobs
            // FIXME: Hardcoded mobs, could be configurable
            let knight = MobTrait::from_role(dungeon_id, team_id, 0, Role::Knight, Element::Fire);
            let ranger = MobTrait::from_role(dungeon_id, team_id, 1, Role::Ranger, Element::Air);
            let priest = MobTrait::from_role(dungeon_id, team_id, 2, Role::Priest, Element::Water);
            team.mint(RoleTrait::spell(Role::Knight));
            team.mint(RoleTrait::spell(Role::Ranger));
            team.mint(RoleTrait::spell(Role::Priest));
            store.set_mob(knight);
            store.set_mob(ranger);
            store.set_mob(priest);

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
            let mut room = store.get_room(dungeon.id, team.x, team.y);
            if !room.is_explored() {
                // [Effect] Create room
                room.explore(team.seed);

                // [Effect] Store room
                store.set_room(room);
            }

            // [Effect] Generate monsters
            let caster_index = room.pick(team.seed);
            let mut monsters = room.compute_monsters();
            // FIXME: Maybe find a better way to define the starting index of monsters
            let mut index = 3;
            loop {
                match monsters.pop_front() {
                    Option::Some(monster) => {
                        // [Effect] Create monster
                        let mut monster = MobTrait::from_monster(
                            dungeon.id, team.id, index, monster
                        );
                        if monster.class == Monster::None.into() {
                            monster.clean();
                        } else if index == caster_index {
                            monster.setup_monster();
                        }
                        // [Effect] Store monster
                        store.set_mob(monster);
                        index += 1;
                    },
                    Option::None => { break; },
                }
            };

            // [Effect] Create challenge
            let challenge = ChallengeTrait::new(dungeon.id, team.id, team.x, team.y);
            store.set_challenge(challenge);

            // [Effect] Pick spells
            team.pick(team.seed);

            // [Effect] Update team
            store.set_team(team);
        }

        fn attack(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            spell_index: u8,
            caster_index: u8
        ) {
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

            // [Check] Caster index
            assert(caster_index < 3, errors::PLAYABLE_INVALID_CASTER_INDEX);

            // [Effect] Select caster
            let mut caster = store.get_mob(dungeon.id, team.id, caster_index);
            let spell: Spell = team.spell_at(spell_index);
            caster.set_spell(spell);
            store.set_mob(caster);

            // [Compute] Battle
            let mut mates = store.get_mates(dungeon.id, team.id);
            let mut monsters = store.get_monsters(dungeon.id, team.id);
            Battler::start(ref mates, ref monsters);

            // [Effect] Update challenge status
            let mates_status = Battler::status(mates.clone());
            let monsters_status = Battler::status(monsters.clone());
            challenge.completed = mates_status && !monsters_status;
            challenge.iter();
            store.set_challenge(challenge);

            // [Effect] Update mobs
            store.set_mobs(ref mates);
            store.set_mobs(ref monsters);

            // [Effect] Update team status
            team.dead = !mates_status;
            // [Effect] Update spells if challenge is not completed
            if challenge.completed {
                team.clean();
            } else {
                let seed: felt252 = Seeder::reseed(team.seed, challenge.nonce.into());
                team.pick(seed);
                store.set_team(team);
            }
            store.set_team(team);
        }
    }
}
