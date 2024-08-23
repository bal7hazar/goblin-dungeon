#[derive(Copy, Drop)]
enum Category {
    None,
    Monster,
    Fountain,
    Item,
    Adventurer,
    Burn,
    Craft,
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
            Category::Fountain
        } else if random < 81 {
            Category::Item
        } else if random < 121 {
            Category::Adventurer
        } else if random < 161 {
            Category::Burn
        } else if random < 201 {
            Category::Craft
        } else {
            Category::Monster
        }
    }
}

impl IntoCategoryFelt252 of core::Into<Category, felt252> {
    #[inline(always)]
    fn into(self: Category) -> felt252 {
        match self {
            Category::None => 'NONE',
            Category::Monster => 'MONSTER',
            Category::Fountain => 'FOUNTAIN',
            Category::Item => 'ITEM',
            Category::Adventurer => 'ADVENTURER',
            Category::Burn => 'BURN',
            Category::Craft => 'CRAFT',
            Category::Boss => 'BOSS',
        }
    }
}

impl IntoCategoryU8 of core::Into<Category, u8> {
    #[inline(always)]
    fn into(self: Category) -> u8 {
        match self {
            Category::None => 0,
            Category::Monster => 1,
            Category::Fountain => 2,
            Category::Item => 3,
            Category::Adventurer => 4,
            Category::Burn => 5,
            Category::Craft => 6,
            Category::Boss => 7,
        }
    }
}

impl IntoU8Category of core::Into<u8, Category> {
    #[inline(always)]
    fn into(self: u8) -> Category {
        let card: felt252 = self.into();
        match card {
            0 => Category::None,
            1 => Category::Monster,
            2 => Category::Fountain,
            3 => Category::Item,
            4 => Category::Adventurer,
            5 => Category::Burn,
            6 => Category::Craft,
            7 => Category::Boss,
            _ => Category::None,
        }
    }
}

impl CategoryPrint of core::debug::PrintTrait<Category> {
    #[inline(always)]
    fn print(self: Category) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
