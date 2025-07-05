#[cfg(test)]
mod tests {
    use starknet::testing::contract;
    use starknet::prelude::*;
    use player::player::{Contract as PlayerContract};

    #[test]
    fn test_register_succeeds_for_new_address() {
        // Deploy the player contract
        let contract = PlayerContract::deploy(@ArrayTrait::new());

        // Call register
        contract.register();

        // Check if registered
        let caller = get_caller_address();
        let is_reg = contract.is_registered(caller);
        assert(is_reg, 'Expected caller to be registered');
    }

    #[test]
    #[should_panic(expected: 'Already registered')]
    fn test_register_fails_for_duplicate_address() {
        let contract = PlayerContract::deploy(@ArrayTrait::new());

        // Register once
        contract.register();

        // Register again → should panic
        contract.register();
    }

    #[test]
    fn test_is_registered_returns_expected_boolean() {
        let contract = PlayerContract::deploy(@ArrayTrait::new());
        let caller = get_caller_address();

        // Initially false
        let is_before = contract.is_registered(caller);
        assert(!is_before, 'Expected not registered before');

        // Register
        contract.register();

        // Should now be true
        let is_after = contract.is_registered(caller);
        assert(is_after, 'Expected registered after register()');
    }
}