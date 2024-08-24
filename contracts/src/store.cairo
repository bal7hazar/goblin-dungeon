//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Models imports

use rpg::models::factory::Factory;
use rpg::models::player::Player;
use rpg::models::dungeon::Dungeon;
use rpg::models::room::Room;
use rpg::models::team::Team;
use rpg::models::character::Character;
use rpg::models::challenge::Challenge;

// Structs

#[derive(Copy, Drop)]
struct Store {
    world: IWorldDispatcher,
}

// Implementations

#[generate_trait]
impl StoreImpl of StoreTrait {
    #[inline]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    #[inline]
    fn get_factory(self: Store, factory_id: u32) -> Factory {
        get!(self.world, factory_id, (Factory))
    }

    #[inline]
    fn get_player(self: Store, player_id: felt252) -> Player {
        get!(self.world, player_id, (Player))
    }

    #[inline]
    fn get_dungeon(self: Store, dungeon_id: u32) -> Dungeon {
        get!(self.world, dungeon_id, (Dungeon))
    }

    #[inline]
    fn get_room(self: Store, dungeon_id: u32, x: i32, y: i32) -> Room {
        get!(self.world, (dungeon_id, x, y), (Room))
    }

    #[inline]
    fn get_team(self: Store, dungeon_id: u32, team_id: u32) -> Team {
        get!(self.world, (dungeon_id, team_id), (Team))
    }

    #[inline]
    fn get_character(self: Store, dungeon_id: u32, team_id: u32, index: u8) -> Character {
        get!(self.world, (dungeon_id, team_id, index), (Character))
    }

    #[inline]
    fn get_challenge(self: Store, dungeon_id: u32, team_id: u32, x: i32, y: i32) -> Challenge {
        get!(self.world, (dungeon_id, team_id, x, y), (Challenge))
    }

    #[inline]
    fn get_mates(self: Store, dungeon_id: u32, team_id: u32) -> Array<Character> {
        array![
            self.get_character(dungeon_id, team_id, 0),
            self.get_character(dungeon_id, team_id, 1),
            self.get_character(dungeon_id, team_id, 2),
        ]
    }

    #[inline]
    fn get_monsters(self: Store, dungeon_id: u32, team_id: u32) -> Array<Character> {
        array![
            self.get_character(dungeon_id, team_id, 4),
            self.get_character(dungeon_id, team_id, 5),
            self.get_character(dungeon_id, team_id, 6),
        ]
    }

    #[inline]
    fn set_factory(self: Store, factory: Factory) {
        set!(self.world, (factory))
    }

    #[inline]
    fn set_player(self: Store, player: Player) {
        set!(self.world, (player))
    }

    #[inline]
    fn set_dungeon(self: Store, dungeon: Dungeon) {
        set!(self.world, (dungeon))
    }

    #[inline]
    fn set_room(self: Store, room: Room) {
        set!(self.world, (room))
    }

    #[inline]
    fn set_team(self: Store, team: Team) {
        set!(self.world, (team))
    }

    #[inline]
    fn set_character(self: Store, character: Character) {
        set!(self.world, (character))
    }

    #[inline]
    fn set_characters(self: Store, ref characters: Array<Character>) {
        loop {
            match characters.pop_front() {
                Option::Some(character) => { self.set_character(character); },
                Option::None => { break; },
            }
        }
    }

    #[inline]
    fn set_challenge(self: Store, challenge: Challenge) {
        set!(self.world, (challenge))
    }
}
