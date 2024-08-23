#[derive(Copy, Drop)]
enum Slot {
    None,
    Weapon,
    Head,
    Chest,
    Hand,
    Feet,
}

#[generate_trait]
impl SlotImpl of SlotTrait {}

impl IntoSlotFelt252 of core::Into<Slot, felt252> {
    #[inline]
    fn into(self: Slot) -> felt252 {
        match self {
            Slot::None => 'NONE',
            Slot::Weapon => 'WEAPON',
            Slot::Head => 'HEAD',
            Slot::Chest => 'CHEST',
            Slot::Hand => 'HAND',
            Slot::Feet => 'FEET',
        }
    }
}

impl IntoSlotU8 of core::Into<Slot, u8> {
    #[inline]
    fn into(self: Slot) -> u8 {
        match self {
            Slot::None => 0,
            Slot::Weapon => 1,
            Slot::Head => 2,
            Slot::Chest => 3,
            Slot::Hand => 4,
            Slot::Feet => 5,
        }
    }
}

impl IntoU8Slot of core::Into<u8, Slot> {
    #[inline]
    fn into(self: u8) -> Slot {
        let card: felt252 = self.into();
        match card {
            0 => Slot::None,
            1 => Slot::Weapon,
            2 => Slot::Head,
            3 => Slot::Chest,
            4 => Slot::Hand,
            5 => Slot::Feet,
            _ => Slot::None,
        }
    }
}

impl SlotPrint of core::debug::PrintTrait<Slot> {
    #[inline]
    fn print(self: Slot) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
