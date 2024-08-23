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
pub struct Team {
    #[key]
    pub player_id: felt252,
    #[key]
    pub id: u32,
    pub nonce: u32,
    pub seed: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Room {
    #[key]
    pub x: i32,
    #[key]
    pub y: i32,
    pub category: u8,
    pub seed: felt252,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Monster {
    #[key]
    pub team_id: u32,
    #[key]
    pub index: u8,
    pub class: u8,
    pub element: u8,
    pub health: u8,
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Character {
    #[key]
    pub team_id: u32,
    #[key]
    pub index: u8,
    pub class: u8,
    pub element: u8,
    pub health: u8,
}
