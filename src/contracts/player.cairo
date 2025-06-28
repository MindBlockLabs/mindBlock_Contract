
#[starknet::contract]
mod player {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use core::traits::Into;

    // ========== Storage ==========
    #[storage]
    struct Storage {
        registered: LegacyMap<ContractAddress, bool>,
        registration_time: LegacyMap<ContractAddress, u64>,
    }

    // ========== Events ==========
    #[event]
    fn PlayerRegistered(wallet: ContractAddress, timestamp: u64);

    // ========== Register ==========
    #[external]
    fn register(ref self: ContractState) {
        let caller = get_caller_address();

        if self.registered.read(caller) {
            panic!("Already registered");
        }

        let timestamp = get_block_timestamp();

        self.registered.write(caller, true);
        self.registration_time.write(caller, timestamp);

        PlayerRegistered(caller, timestamp);
    }

    // ========== View: Check if registered ==========
    #[view]
    fn is_registered(self: @ContractState, addr: ContractAddress) -> bool {
        self.registered.read(addr)
    }

    // ========== Optional: View registration timestamp ==========
    #[view]
    fn get_registration_time(self: @ContractState, addr: ContractAddress) -> u64 {
        self.registration_time.read(addr)
    }

    // ========== Optional Metadata Struct ==========
    struct PlayerMetadata {
        nickname: felt252, // Placeholder for future expansion
    }
}
