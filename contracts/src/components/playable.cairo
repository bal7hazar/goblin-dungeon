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

    use grimscape::constants::FACTORY_ID;
    use grimscape::store::{Store, StoreTrait};
    use grimscape::models::factory::{Factory, FactoryTrait};
    use grimscape::models::player::{Player, PlayerTrait, PlayerAssert};
    use grimscape::models::dungeon::{Dungeon, DungeonTrait, DungeonAssert};
    use grimscape::models::room::{Room, RoomTrait, RoomAssert};
    use grimscape::models::team::{Team, TeamTrait, TeamAssert};
    use grimscape::models::mob::{Mob, MobTrait, MobAssert};
    use grimscape::models::challenge::{Challenge, ChallengeTrait, ChallengeAssert};
    use grimscape::types::category::{Category, CategoryTrait};
    use grimscape::types::role::{Role, RoleTrait};
    use grimscape::types::monster::Monster;
    use grimscape::types::threat::Threat;
    use grimscape::types::element::Element;
    use grimscape::types::direction::Direction;
    use grimscape::types::spell::Spell;
    use grimscape::helpers::seeder::Seeder;
    use grimscape::helpers::battler::Battler;

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
            let mut mates: Array<(Role, Element)> = team.compute_mates();
            let mut index = 0;
            loop {
                match mates.pop_front() {
                    Option::Some((
                        role, element
                    )) => {
                        // [Effect] Create mob
                        let mob = MobTrait::from_role(dungeon_id, team_id, index, role, element);
                        team.mint(role.spell(element));
                        store.set_mob(mob);
                        index += 1;
                    },
                    Option::None => { break; },
                };
            };

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
            let mut factory = store.get_factory(FACTORY_ID);
            let dungeon_id = factory.dungeon_id();
            let mut dungeon = store.get_dungeon(dungeon_id);
            dungeon.assert_not_done();

            // [Check] Team is not dead
            let mut team = store.get_team(dungeon.id, player.team_id);
            team.assert_not_dead();

            // [Check] Challenge is completed or room is passable
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            if !challenge.completed {
                // [Check] Room is passable
                let room = store.get_room(dungeon.id, team.x, team.y);
                room.assert_is_passable();
                // [Effect] Update challange status
                challenge.complete();
                store.set_challenge(challenge);
            }

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
            let caster_index = room.pick_monster(team.seed);
            let mut monsters: Array<(Monster, Threat, Element)> = room.compute_monsters();
            // FIXME: Maybe find a better way to define the starting index of monsters
            let mut index = 3;
            loop {
                match monsters.pop_front() {
                    Option::Some((
                        monster, threat, element
                    )) => {
                        // [Effect] Create monster
                        let mut monster = MobTrait::from_monster(
                            dungeon.id, team.id, index, monster, threat, element
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
            let challenge = ChallengeTrait::new(dungeon.id, team.id, team.x, team.y, false);
            store.set_challenge(challenge);

            // [Effect] Assess the end of the dungeon
            if room.category == Category::Exit.into() {
                // [Effect] Update dungeon status
                dungeon.claim(player.name);
                store.set_dungeon(dungeon);
                // [Effect] Create new dungeon
                let dungeon_id = factory.generate();
                let dungeon = DungeonTrait::new(dungeon_id, team.seed);
                // [Effect] Create the spawn room
                let mut room = RoomTrait::new(dungeon_id, 0, 0);
                room.seed = dungeon.seed;
                // [Effect] Store room
                store.set_room(room);
                // [Effect] Store dungeon
                store.set_dungeon(dungeon);
                // [Effect] Store factory
                store.set_factory(factory);
            } else if !challenge.completed {
                // [Effect] Pick spells
                team.pick_spells(team.seed);
            }

            // [Effect] Update team
            store.set_team(team);
        }

        fn attack(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            orders: u16,
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

            // [Check] Room is explored and is a monster room
            let room = store.get_room(dungeon.id, team.x, team.y);
            room.assert_is_explored();
            room.assert_is_monster();

            // [Check] Challenge is not completed
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Check] Caster index
            assert(caster_index < 3, errors::PLAYABLE_INVALID_CASTER_INDEX);

            // [Effect] Select caster
            let mut caster = store.get_mob(dungeon.id, team.id, caster_index);
            let spell: Spell = team.spell_at(spell_index);
            caster.update(spell);
            store.set_mob(caster);

            // [Compute] Battle
            let mut mates = store.get_ordered_mates(dungeon.id, team.id, orders);
            let mut monsters = store.get_monsters(dungeon.id, team.id);
            Battler::start(ref mates, ref monsters);

            // [Effect] Update challenge status
            let mates_status = Battler::status(mates.clone());
            let monsters_status = Battler::status(monsters.clone());
            challenge.completed = mates_status && !monsters_status;
            challenge.iter();
            store.set_challenge(challenge);

            // [Compute] Update monsters mobs and setup next caster
            let seed: felt252 = Seeder::reseed(room.seed, challenge.nonce.into());
            let caster_index = room.pick_monster(seed);
            loop {
                match monsters.pop_front() {
                    Option::Some(mut monster) => {
                        if monster.index == caster_index && !monster.is_dead() {
                            monster.setup_monster();
                        }
                        store.set_mob(monster);
                    },
                    Option::None => { break; },
                };
            };

            // [Effect] Update mates mobs
            store.set_mobs(ref mates);

            // [Effect] Update team status
            team.dead = !mates_status;
            // [Effect] Update spells if challenge is not completed
            if challenge.completed {
                team.clean();
            } else {
                let seed: felt252 = Seeder::reseed(team.seed, challenge.nonce.into());
                team.pick_spells(seed);
                store.set_team(team);
            }
            store.set_team(team);
        }

        fn hire(
            self: @ComponentState<TContractState>,
            world: IWorldDispatcher,
            adventurer_index: u8,
            team_index: u8,
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

            // [Check] Room is explored and is an adventurer room
            let room = store.get_room(dungeon.id, team.x, team.y);
            room.assert_is_explored();
            room.assert_is_adventurer();

            // [Check] Challenge is not completed
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Effect] Create mob
            let adventurers: Array<(Role, Element)> = room.get_adventurers();
            let (role, element) = *adventurers.at(adventurer_index.into());
            let mob = MobTrait::from_role(dungeon.id, team.id, team_index, role, element);
            store.set_mob(mob);

            // [Effect] Update challenge status
            challenge.complete();
            store.set_challenge(challenge);

            // [Effect] Update team deck
            team.mint(role.spell(element));
            store.set_team(team);
        }

        fn pickup(self: @ComponentState<TContractState>, world: IWorldDispatcher) {
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

            // [Check] Room is explored
            let room = store.get_room(dungeon.id, team.x, team.y);
            room.assert_is_explored();
            room.assert_is_spell();

            // [Check] Challenge is not completed
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Check] Mint spell
            team.mint(room.spell.into());

            // [Effect] Update challenge status
            challenge.complete();
            store.set_challenge(challenge);

            // [Effect] Update team
            store.set_team(team);
        }

        fn burn(self: @ComponentState<TContractState>, world: IWorldDispatcher, spell_index: u8) {
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

            // [Check] Room is explored
            let room = store.get_room(dungeon.id, team.x, team.y);
            room.assert_is_explored();
            room.assert_is_burn();

            // [Check] Challenge is not completed
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Effect] Burn spell
            team.burn(spell_index);

            // [Effect] Update challenge status
            challenge.complete();
            store.set_challenge(challenge);

            // [Effect] Update team
            store.set_team(team);
        }

        fn heal(self: @ComponentState<TContractState>, world: IWorldDispatcher) {
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

            // [Check] Room is explored
            let room = store.get_room(dungeon.id, team.x, team.y);
            room.assert_is_explored();
            room.assert_is_fountain();

            // [Check] Challenge is not completed
            let mut challenge = store.get_challenge(dungeon.id, team.id, team.x, team.y);
            challenge.assert_not_completed();

            // [Effect] Update challenge status
            challenge.complete();
            store.set_challenge(challenge);

            // [Effect] Heal team
            let mut mates = store.get_mates(dungeon.id, team.id);
            loop {
                match mates.pop_front() {
                    Option::Some(mut mate) => {
                        mate.restore();
                        store.set_mob(mate);
                    },
                    Option::None => { break; },
                };
            };

            // [Effect] Update team
            team.clean();
            store.set_team(team);
        }
    }
}
