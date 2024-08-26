//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Models imports

use rpg::constants::ORDER_BIT_LENGTH;
use rpg::models::factory::Factory;
use rpg::models::player::Player;
use rpg::models::dungeon::Dungeon;
use rpg::models::room::Room;
use rpg::models::team::Team;
use rpg::models::mob::Mob;
use rpg::models::challenge::Challenge;
use rpg::helpers::packer::Packer;

// Errprs

mod errors {
    const STORE_INVALID_ORDER: felt252 = 'Store: invalid order';
}

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
    fn get_mob(self: Store, dungeon_id: u32, team_id: u32, index: u8) -> Mob {
        get!(self.world, (dungeon_id, team_id, index), (Mob))
    }

    #[inline]
    fn get_challenge(self: Store, dungeon_id: u32, team_id: u32, x: i32, y: i32) -> Challenge {
        get!(self.world, (dungeon_id, team_id, x, y), (Challenge))
    }

    #[inline]
    fn get_ordered_mates(self: Store, dungeon_id: u32, team_id: u32, orders: u16) -> Array<Mob> {
        let mut orders: Array<u8> = Packer::unpack(orders, ORDER_BIT_LENGTH);
        let mut mates: Array<Mob> = array![];
        // [Check] Indexes
        let first = match orders.pop_front() {
            Option::Some(index) => index,
            Option::None => 0,
        };
        let second = match orders.pop_front() {
            Option::Some(index) => index,
            Option::None => 0,
        };
        let third = match orders.pop_front() {
            Option::Some(index) => index,
            Option::None => 0,
        };
        assert(first < 3 && first != second, errors::STORE_INVALID_ORDER);
        assert(second < 3 && second != third, errors::STORE_INVALID_ORDER);
        assert(third < 3 && third != first, errors::STORE_INVALID_ORDER);
        // [Read] First mob
        let mut mob = self.get_mob(dungeon_id, team_id, first);
        mob.index = 0;
        mates.append(mob);
        // [Read] Second mob
        let mut mob = self.get_mob(dungeon_id, team_id, second);
        mob.index = 1;
        mates.append(mob);
        // [Read] Third mob
        let mut mob = self.get_mob(dungeon_id, team_id, third);
        mob.index = 2;
        mates.append(mob);
        // [Return] Ordered mates
        mates
    }

    #[inline]
    fn get_monsters(self: Store, dungeon_id: u32, team_id: u32) -> Array<Mob> {
        array![
            self.get_mob(dungeon_id, team_id, 4),
            self.get_mob(dungeon_id, team_id, 5),
            self.get_mob(dungeon_id, team_id, 6),
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
    fn set_mob(self: Store, mob: Mob) {
        set!(self.world, (mob))
    }

    #[inline]
    fn set_mobs(self: Store, ref mobs: Array<Mob>) {
        loop {
            match mobs.pop_front() {
                Option::Some(mob) => { self.set_mob(mob); },
                Option::None => { break; },
            }
        }
    }

    #[inline]
    fn set_challenge(self: Store, challenge: Challenge) {
        set!(self.world, (challenge))
    }
}
