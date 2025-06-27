// SPDX-License-Identifier: MIT
// Leaderboard contract for ZK score submissions

#[starknet::contract]
mod Leaderboard {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::array::ArrayTrait;
    use core::hash::hash2;
    use core::starknet::contract_address::ContractAddress;
    use core::starknet::syscalls::get_caller_address;

    #[storage]
    struct Storage {
        // List of leaderboard entries
        entries: Array<LeaderboardEntry>,
        // Mapping from wallet to index+1 in entries (0 = not present)
        wallet_to_index: LegacyMap<ContractAddress, u32>,
    }

    struct LeaderboardEntry {
        wallet: ContractAddress,
        proof_hash: felt252,
        percentile: u8, // 0-100
    }

    #[abi(embed_v0)]
    impl LeaderboardImpl of LeaderboardTrait<ContractState> {
        /// Submit a ZK proof of score (one per wallet)
        fn submit_score(ref self: ContractState, proof_hash: felt252, percentile: u8) {
            let wallet = get_caller_address();
            let idx = self.wallet_to_index.get(wallet).unwrap_or(0);
            if idx != 0 {
                // Already submitted, revert
                panic!("Already submitted");
            }
            let entry = LeaderboardEntry { wallet, proof_hash, percentile };
            self.entries.append(entry);
            let new_idx = self.entries.len();
            self.wallet_to_index.insert(wallet, new_idx);
            emit ScoreSubmitted { wallet, proof_hash, percentile };
        }

        /// Get all leaderboard entries
        fn get_leaderboard(self: @ContractState) -> Array<LeaderboardEntry> {
            self.entries.clone()
        }
    }

    #[abi]
    trait LeaderboardTrait<T> {
        fn submit_score(ref self: T, proof_hash: felt252, percentile: u8);
        fn get_leaderboard(self: @T) -> Array<LeaderboardEntry>;
    }

    #[event]
    fn ScoreSubmitted(wallet: ContractAddress, proof_hash: felt252, percentile: u8);
    }
}
