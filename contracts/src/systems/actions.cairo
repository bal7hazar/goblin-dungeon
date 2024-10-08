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
    fn attack(self: @TContractState, orders: u16, spell_index: u8, caster_index: u8);
    fn hire(self: @TContractState, adventurer_index: u8, team_index: u8);
    fn pickup(self: @TContractState);
    fn burn(self: @TContractState, spell_index: u8);
    fn heal(self: @TContractState);
}

// Contracts

#[dojo::contract]
mod actions {
    // Component imports

    use grimscape::components::signable::SignableComponent;
    use grimscape::components::playable::PlayableComponent;

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

        fn attack(self: @ContractState, orders: u16, spell_index: u8, caster_index: u8) {
            self.playable.attack(self.world(), orders, spell_index, caster_index)
        }

        fn hire(self: @ContractState, adventurer_index: u8, team_index: u8) {
            self.playable.hire(self.world(), adventurer_index, team_index)
        }

        fn pickup(self: @ContractState) {
            self.playable.pickup(self.world())
        }

        fn burn(self: @ContractState, spell_index: u8) {
            self.playable.burn(self.world(), spell_index)
        }

        fn heal(self: @ContractState) {
            self.playable.heal(self.world())
        }
    }
}
