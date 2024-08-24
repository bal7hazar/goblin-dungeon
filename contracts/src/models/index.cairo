#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Player {
    #[key]
    pub id: felt252,
    pub team_id: u32,
    pub name: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Factory {
    #[key]
    pub id: u32,
    pub dungeon_id: u32,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Dungeon {
    #[key]
    pub id: u32,
    pub nonce: u32,
    pub seed: felt252,
    pub name: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Room {
    #[key]
    pub dungeon_id: u32,
    #[key]
    pub x: i32,
    #[key]
    pub y: i32,
    pub category: u8,
    pub item: u8,
    pub monsters: u128,
    pub adventurers: u128,
    pub seed: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Team {
    #[key]
    pub dungeon_id: u32,
    #[key]
    pub team_id: u32,
    pub x: i32,
    pub y: i32,
    pub dead: bool,
    pub seed: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Character {
    #[key]
    pub dungeon_id: u32,
    #[key]
    pub team_id: u32,
    #[key]
    pub index: u8,
    pub class: u8,
    pub element: u8,
    pub spell: u8,
    pub health: u8,
    pub shield: u8,
    pub stun: u8,
    pub multiplier: u8,
}
