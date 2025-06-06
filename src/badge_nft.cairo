#[contract]
mod badge_nft {
    // Import ERC721 from OpenZeppelin
    use openzeppelin::token::erc721::ERC721;
    use starknet::contract::ContractAddress;

    #[storage]
    struct Storage {
        erc721: ERC721::Storage,
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(name: felt252, symbol: felt252) {
        let caller = get_caller_address();
        ERC721::constructor(name, symbol);
        owner::write(caller);
    }
}
