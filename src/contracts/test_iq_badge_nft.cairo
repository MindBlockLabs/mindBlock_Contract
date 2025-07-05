#[cfg(test)]
mod test_iq_badge_nft {
    use starknet::ContractAddress;
    use core::result::ResultTrait;
    use snforge_std::{declare, ContractClassTrait, deploy, start_prank, stop_prank};

    use src::contracts::IqBadgeNFT::IqBadgeNFT;

    const SCORE_THRESHOLD: felt252 = 80;

    fn setup() -> (ContractAddress, ContractAddress, ContractAddress, ContractAddress) {

        let owner_address: ContractAddress = 1.try_into().unwrap();
        let minter_address: ContractAddress = 2.try_into().unwrap();
        let user_address: ContractAddress = 3.try_into().unwrap();


        let contract = declare("IqBadgeNFT");
        

        let name: felt252 = 'IQ Badge';
        let symbol: felt252 = 'IQB';
        let mut constructor_calldata = array![
            owner_address.into(), name.into(), symbol.into(), minter_address.into(), SCORE_THRESHOLD
        ];


        let contract_address = contract.deploy(@constructor_calldata).unwrap();

        (contract_address, owner_address, minter_address, user_address)
    }

    #[test]
    fn test_successful_mint() {
        let (contract_address, owner, minter, user) = setup();
        let dispatcher = IqBadgeNFT::Dispatcher { contract_address };
        let score_above_threshold = 95;


        start_prank(contract_address, minter);
        dispatcher.mint_to(user, score_above_threshold);
        stop_prank(contract_address);


        let owner_of_token = dispatcher.owner_of(1);
        assert(owner_of_token == user, 'User is not the owner');


        let (token_id, metadata) = dispatcher.get_badge_by_user(user);
        assert(token_id == 1, 'Token ID mismatch');
        assert(metadata.score == score_above_threshold, 'Score mismatch');
        assert(metadata.mint_date > 0, 'Mint date not set');
    }

    #[test]
    #[should_panic(expected: ('Score below threshold',))]
    fn test_fail_mint_below_threshold() {
        let (contract_address, owner, minter, user) = setup();
        let dispatcher = IqBadgeNFT::Dispatcher { contract_address };
        
        start_prank(contract_address, minter);
        dispatcher.mint_to(user, 79)
        stop_prank(contract_address);
    }

    #[test]
    #[should_panic(expected: ('Caller is not the minter',))]
    fn test_fail_mint_by_non_minter() {
        let (contract_address, owner, minter, user) = setup();
        let dispatcher = IqBadgeNFT::Dispatcher { contract_address };


        start_prank(contract_address, user);
        dispatcher.mint_to(user, 100);
        stop_prank(contract_address);
    }

    #[test]
    #[should_panic(expected: ('Token is not transferable',))]
    fn test_fail_transfer() {
        let (contract_address, owner, minter, user) = setup();
        let dispatcher = IqBadgeNFT::Dispatcher { contract_address };
        let recipient: ContractAddress = 4.try_into().unwrap();


        start_prank(contract_address, minter);
        dispatcher.mint_to(user, 90);
        stop_prank(contract_address);


        start_prank(contract_address, user);
        dispatcher.transfer_from(user, recipient, 1);
        stop_prank(contract_address);
    }
    
    #[test]
    #[should_panic(expected: ('User already has a badge',))]
    fn test_fail_mint_for_existing_user() {
        let (contract_address, owner, minter, user) = setup();
        let dispatcher = IqBadgeNFT::Dispatcher { contract_address };


        start_prank(contract_address, minter);
        dispatcher.mint_to(user, 90);


        dispatcher.mint_to(user, 95);
        stop_prank(contract_address);
    }
}