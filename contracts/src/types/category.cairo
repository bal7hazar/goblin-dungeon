#[derive(Copy, Drop)]
enum Category {
    None,
    Monster,
    Adventurer,
    Fountain,
    Spell,
    Burn,
    Boss,
}

#[generate_trait]
impl CategoryImpl of CategoryTrait {
    #[inline]
    fn from(seed: felt252) -> Category {
        let random: u256 = seed.into() % 1000;
        if random < 1 {
            Category::Boss
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
            Category::Boss => 'BOSS',
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
            Category::Boss => 6,
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
            6 => Category::Boss,
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
