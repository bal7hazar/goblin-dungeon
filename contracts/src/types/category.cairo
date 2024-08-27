#[derive(Copy, Drop)]
enum Category {
    None,
    Monster,
    Adventurer,
    Fountain,
    Spell,
    Burn,
    Exit,
}

#[generate_trait]
impl CategoryImpl of CategoryTrait {
    #[inline]
    fn from(seed: felt252) -> Category {
        let random: u256 = seed.into() % 1000;
        if random < 1 {
            Category::Exit
        } else if random < 41 {
            Category::Burn
        } else if random < 81 {
            Category::Spell
        } else if random < 121 {
            Category::Fountain
        } else if random < 161 {
            Category::Adventurer
        } else {
            Category::Monster
        }
    }

    #[inline]
    fn default_challenge_status(self: Category) -> bool {
        match self {
            Category::Monster => false,
            Category::Adventurer => true,
            Category::Fountain => true,
            Category::Spell => true,
            Category::Burn => true,
            Category::Exit => true,
            Category::None => false,
        }
    }
}

impl IntoCategoryFelt252 of core::Into<Category, felt252> {
    #[inline]
    fn into(self: Category) -> felt252 {
        match self {
            Category::None => 'NONE',
            Category::Monster => 'MONSTER',
            Category::Adventurer => 'ADVENTURER',
            Category::Fountain => 'FOUNTAIN',
            Category::Spell => 'SPELL',
            Category::Burn => 'BURN',
            Category::Exit => 'EXIT',
        }
    }
}

impl IntoCategoryU8 of core::Into<Category, u8> {
    #[inline]
    fn into(self: Category) -> u8 {
        match self {
            Category::None => 0,
            Category::Monster => 1,
            Category::Fountain => 2,
            Category::Spell => 3,
            Category::Adventurer => 4,
            Category::Burn => 5,
            Category::Exit => 6,
        }
    }
}

impl IntoU8Category of core::Into<u8, Category> {
    #[inline]
    fn into(self: u8) -> Category {
        let card: felt252 = self.into();
        match card {
            0 => Category::None,
            1 => Category::Monster,
            2 => Category::Fountain,
            3 => Category::Spell,
            4 => Category::Adventurer,
            5 => Category::Burn,
            6 => Category::Exit,
            _ => Category::None,
        }
    }
}

impl CategoryPrint of core::debug::PrintTrait<Category> {
    #[inline]
    fn print(self: Category) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
