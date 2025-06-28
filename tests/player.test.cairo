#[cfg(test)]
mod tests {
    use super::player;
    use starknet::testing::{start_contract, invoke_contract, call_contract};
    use starknet::ContractAddress;

    #[test]
    fn test_register_and_check() {
        let test_address: ContractAddress = 1234.try_into().unwrap();
        let mut contract = start_contract(player::contract);

        // Register the player
        invoke_contract(contract, "register", (), test_address);

        // Check registration
        let is_registered: bool = call_contract(contract, "is_registered", (test_address,));
        assert!(is_registered);
    }

    #[test]
    #[should_panic]
    fn test_prevent_duplicate_registration() {
        let test_address: ContractAddress = 5678.try_into().unwrap();
        let mut contract = start_contract(player::contract);

        invoke_contract(contract, "register", (), test_address);
        invoke_contract(contract, "register", (), test_address); // Should panic
    }
}
