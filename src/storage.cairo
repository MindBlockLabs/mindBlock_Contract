#[starknet::contract]
mod StorageExample {
    #[storage]
    struct Storage {
        balance: u256,
    }

    #[external]
    fn update_balance(ref self: ContractState, new_balance: u256) {
        self.balance.write(new_balance);
    }

    #[view]
    fn get_balance(self: @ContractState) -> u256 {
        self.balance.read()
    }
}
