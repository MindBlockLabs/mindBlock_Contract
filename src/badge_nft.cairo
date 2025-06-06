#[contract]
mod badge_nft {
    use openzeppelin::token::erc721::ERC721;
    use starknet::contract::ContractAddress;
    use starknet::collections::Map;

    #[event]
    struct AchievementUnlocked {
        to: ContractAddress,
        badge_id: u256,
    }

    #[storage]
    struct Storage {
        erc721: ERC721::Storage,
        owner: ContractAddress,
        metadata: Map<u256, felt252>,
    }

    #[constructor]
    fn constructor(name: felt252, symbol: felt252) {
        let caller = get_caller_address();
        ERC721::constructor(name, symbol);
        owner::write(caller);
    }

    #[external]
    fn mint_badge(recipient: ContractAddress, badge_id: u256, metadata_uri: felt252) {
        let caller = get_caller_address();
        let contract_owner = owner::read();
        assert(caller == contract_owner, 'Only the owner can mint');

        ERC721::mint(recipient, badge_id);

        Storage::write().metadata.write(badge_id, metadata_uri);

        AchievementUnlocked { to: recipient, badge_id }.emit();
    }

    #[view]
    fn token_uri(badge_id: u256) -> felt252 {
        Storage::read().metadata.read(badge_id)
    }
}
