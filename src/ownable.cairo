#[starknet::contract]
mod Ownable {
    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.owner.write(self.get_caller());
    }

    #[external]
    fn admin_action(ref self: ContractState) {
        assert(self.owner.read() == self.get_caller(), 'Caller not owner');
        // Admin logic here
    }
}
