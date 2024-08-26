#[derive(Copy, Drop)]
enum Threat {
    None,
    Common,
    Elite,
}

#[generate_trait]
impl ThreatImpl of ThreatTrait {
    #[inline]
    fn count() -> u8 {
        2
    }

    #[inline]
    fn from(seed: felt252) -> Threat {
        let random: u256 = seed.into() % 100;
        if random < 20 {
            Threat::Elite
        } else {
            Threat::Common
        }
    }
}

impl IntoThreatFelt252 of core::Into<Threat, felt252> {
    #[inline]
    fn into(self: Threat) -> felt252 {
        match self {
            Threat::None => 'NONE',
            Threat::Common => 'COMMON',
            Threat::Elite => 'ELITE',
        }
    }
}

impl IntoThreatU8 of core::Into<Threat, u8> {
    #[inline]
    fn into(self: Threat) -> u8 {
        match self {
            Threat::None => 0,
            Threat::Common => 1,
            Threat::Elite => 2,
        }
    }
}

impl IntoU8Threat of core::Into<u8, Threat> {
    #[inline]
    fn into(self: u8) -> Threat {
        let card: felt252 = self.into();
        match card {
            0 => Threat::None,
            1 => Threat::Common,
            2 => Threat::Elite,
            _ => Threat::None,
        }
    }
}

impl ThreatPrint of core::debug::PrintTrait<Threat> {
    #[inline]
    fn print(self: Threat) {
        let felt: felt252 = self.into();
        felt.print();
    }
}
