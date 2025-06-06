#[contract]
mod badge_nft {
    // Import ERC721 from OpenZeppelin
    use openzeppelin::token::erc721::ERC721;
    use starknet::contract::ContractAddress;

    #[storage]
    struct Storage {
        // This stores all ERC721-related data (owners, balances, etc.)
        erc721: ERC721::Storage,
        // This stores the contract owner's address
        owner: ContractAddress,
    }
}
