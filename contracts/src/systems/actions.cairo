// Starknet imports

use starknet::ContractAddress;

// Dojo imports

use dojo::world::IWorldDispatcher;

// Interfaces

#[starknet::interface]
trait IActions<TContractState> {
    fn signup(self: @TContractState, name: felt252);
    fn rename(self: @TContractState, name: felt252);
    fn spawn(self: @TContractState);
    fn move(self: @TContractState, direction: u8);
    fn attack(self: @TContractState, caster_index: u8, spell_index: u8);
}

// Contracts

#[dojo::contract]
mod actions {
    // Component imports

    use rpg::components::signable::SignableComponent;
    use rpg::components::playable::PlayableComponent;

    // Local imports

    use super::IActions;

    // Components

    component!(path: SignableComponent, storage: signable, event: SignableEvent);
    impl SignableInternalImpl = SignableComponent::InternalImpl<ContractState>;
    component!(path: PlayableComponent, storage: playable, event: PlayableEvent);
    impl PlayableInternalImpl = PlayableComponent::InternalImpl<ContractState>;

    // Storage

    #[storage]
    struct Storage {
        #[substorage(v0)]
        signable: SignableComponent::Storage,
        #[substorage(v0)]
        playable: PlayableComponent::Storage,
    }

    // Events

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        SignableEvent: SignableComponent::Event,
        #[flat]
        PlayableEvent: PlayableComponent::Event,
    }

    // Constructor

    fn dojo_init(world: @IWorldDispatcher,) {
        self.playable.initialize(world);
    }

    // Implementations

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn signup(self: @ContractState, name: felt252) {
            self.signable.signup(self.world(), name)
        }

        fn rename(self: @ContractState, name: felt252) {
            self.signable.rename(self.world(), name)
        }

        fn spawn(self: @ContractState) {
            self.playable.spawn(self.world())
        }

        fn move(self: @ContractState, direction: u8) {
            self.playable.move(self.world(), direction)
        }

        fn attack(self: @ContractState, caster_index: u8, spell_index: u8) {
            self.playable.attack(self.world(), caster_index, spell_index)
        }
    }
}
