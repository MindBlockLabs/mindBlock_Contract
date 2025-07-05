#[starknet::contract]
mod IqBadgeNFT {
    use openzeppelin::contracts::erc721::erc721::ERC721Component;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, get_block_timestamp};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC721Impl = ERC721Component::ERC721Impl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    #[derive(Copy, Drop, starknet::Store, Serde)]
    struct BadgeMetadata {
        score: u8,
        mint_date: u64,
    }

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,

        minter_address: ContractAddress,
        score_threshold: u8,
        token_counter: u256,
        badge_metadata: LegacyMap<u256, BadgeMetadata>,
        user_to_token_id: LegacyMap<ContractAddress, u256>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,

        MinterChanged: MinterChanged,
    }

    #[derive(Drop, starknet::Event)]
    struct MinterChanged {
        new_minter: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        owner: ContractAddress,
        name: felt252,
        symbol: felt252,
        minter: ContractAddress,
        threshold: u8
    ) {
        self.ownable.initializer(owner);
        self.erc721.initializer(name, symbol);
        self.minter_address.write(minter);
        self.score_threshold.write(threshold);
        self.token_counter.write(1)
    }

    #[external(v0)]
    impl IqBadgeNFTImpl of IIqBadgeNFT<ContractState> {

        fn mint_to(ref self: ContractState, user_address: ContractAddress, score: u8) {
    
            let caller = starknet::get_caller_address();
            assert(caller == self.minter_address.read(), 'Caller is not the minter');

    
            let threshold = self.score_threshold.read();
            assert(score >= threshold, 'Score below threshold');

    
            assert(self.user_to_token_id.read(user_address) == 0, 'User already has a badge');
            
    
            let new_token_id = self.token_counter.read();
            self.erc721._mint(user_address, new_token_id);
            
    
            let metadata = BadgeMetadata { score, mint_date: get_block_timestamp() };
            self.badge_metadata.write(new_token_id, metadata);
            self.user_to_token_id.write(user_address, new_token_id);
            
    
            self.token_counter.write(new_token_id + 1);
        }


        fn set_minter(ref self: ContractState, new_minter: ContractAddress) {
            self.ownable.assert_only_owner();
            self.minter_address.write(new_minter);
            self.emit(MinterChanged { new_minter });
        }
        

        fn get_badge_by_user(self: @ContractState, user_address: ContractAddress) -> (u256, BadgeMetadata) {
            let token_id = self.user_to_token_id.read(user_address);
            assert(token_id != 0, 'User has no badge');
            let metadata = self.badge_metadata.read(token_id);
            (token_id, metadata)
        }
    }

    #[generate_trait]
    impl ERC721InternalImpl of ERC721Component::InternalImpl<ContractState> {
        fn _is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            false
        }

        fn _approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            panic(array!['Token is not transferable']);
        }
        
        fn _transfer(ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256) {
        
            if from != 0.try_into().unwrap() {
                panic(array!['Token is not transferable']);
            }
    
            self.erc721._transfer(from, to, token_id);
        }
    }
}