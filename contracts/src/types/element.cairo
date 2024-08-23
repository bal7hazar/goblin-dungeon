// Internal imports

use rpg::elements::elements;

#[derive(Copy, Drop)]
enum Element {
    None,
    Fire,
    Water,
    Air,
}

#[generate_trait]
impl ElementImpl of ElementTrait {
    #[inline]
    fn count() -> u8 {
        3
    }

    #[inline]
    fn weakness(self: Element) -> Element {
        match self {
            Element::None => Element::None,
            Element::Fire => elements::fire::Fire::weakness(),
            Element::Water => elements::water::Water::weakness(),
            Element::Air => elements::air::Air::weakness(),
        }
    }

    #[inline]
    fn strength(self: Element) -> Element {
        match self {
            Element::None => Element::None,
            Element::Fire => elements::fire::Fire::strength(),
            Element::Water => elements::water::Water::strength(),
            Element::Air => elements::air::Air::strength(),
        }
    }

    #[inline]
    fn received_damage(self: Element, role: Element, damage: u8) -> u8 {
        let role_id: u8 = self.into();
        if role_id == self.weakness().into() {
            damage * 2
        } else if role_id == self.strength().into() {
            damage / 2
        } else {
            damage
        }
    }
}

impl IntoElementFelt252 of core::Into<Element, felt252> {
    #[inline(always)]
    fn into(self: Element) -> felt252 {
        match self {
            Element::None => 'NONE',
            Element::Fire => 'FIRE',
            Element::Water => 'WATER',
            Element::Air => 'AIR',
        }
    }
}

impl IntoElementU8 of core::Into<Element, u8> {
    #[inline(always)]
    fn into(self: Element) -> u8 {
        match self {
            Element::None => 0,
            Element::Fire => 1,
            Element::Water => 2,
            Element::Air => 3,
        }
    }
}

impl IntoU8Element of core::Into<u8, Element> {
    #[inline(always)]
    fn into(self: u8) -> Element {
        let card: felt252 = self.into();
        match card {
            0 => Element::None,
            1 => Element::Fire,
            2 => Element::Water,
            3 => Element::Air,
            _ => Element::None,
        }
    }
}

impl ElementPrint of core::debug::PrintTrait<Element> {
    #[inline(always)]
    fn print(self: Element) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
