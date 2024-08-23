#[derive(Copy, Drop)]
enum Item {
    None,
    Sword,
    Staff,
    Helmet,
}

#[generate_trait]
impl ItemImpl of ItemTrait {
    #[inline]
    fn count() -> u8 {
        3
    }
}

impl IntoItemFelt252 of core::Into<Item, felt252> {
    #[inline(always)]
    fn into(self: Item) -> felt252 {
        match self {
            Item::None => 'NONE',
            Item::Sword => 'SWORD',
            Item::Staff => 'STAFF',
            Item::Helmet => 'HELMET',
        }
    }
}

impl IntoItemU8 of core::Into<Item, u8> {
    #[inline(always)]
    fn into(self: Item) -> u8 {
        match self {
            Item::None => 0,
            Item::Sword => 1,
            Item::Staff => 2,
            Item::Helmet => 3,
        }
    }
}

impl IntoU8Item of core::Into<u8, Item> {
    #[inline(always)]
    fn into(self: u8) -> Item {
        let card: felt252 = self.into();
        match card {
            0 => Item::None,
            1 => Item::Sword,
            2 => Item::Staff,
            3 => Item::Helmet,
            _ => Item::None,
        }
    }
}

impl ItemPrint of core::debug::PrintTrait<Item> {
    #[inline(always)]
    fn print(self: Item) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
