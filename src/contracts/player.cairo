#[starknet::contract]
mod player {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;
    use core::traits::Into;

    // ========== Storage ==========
    #[storage]
    struct Storage {
        registered: Map<ContractAddress, bool>,
        registration_time: Map<ContractAddress, u64>,
    }

    // ========== Events ==========
    #[event]
    fn PlayerRegistered(wallet: ContractAddress, timestamp: u64);

    // ========== Register ==========
    #[external]
    fn register(ref self: ContractState) {
        let caller = get_caller_address();

        // Read from the map using .get() and unwrap fallback to false
        let is_registered = self.registered.get(caller).unwrap_or(false);
        if is_registered {
            panic!("Already registered");
        }

        let timestamp = get_block_timestamp();

        // Insert into the new Map
        self.registered.insert(caller, true);
        self.registration_time.insert(caller, timestamp);

        PlayerRegistered(caller, timestamp);
    }

    // ========== View: Check if registered ==========
    #[view]
    fn is_registered(self: @ContractState, addr: ContractAddress) -> bool {
        self.registered.get(addr).unwrap_or(false)
    }

    // ========== Optional: View registration timestamp ==========
    #[view]
    fn get_registration_time(self: @ContractState, addr: ContractAddress) -> u64 {
        self.registration_time.get(addr).unwrap_or(0)
    }

    // ========== Optional Metadata Struct ==========
    struct PlayerMetadata {
        nickname: felt252, // Placeholder for future expansion
    }
}
