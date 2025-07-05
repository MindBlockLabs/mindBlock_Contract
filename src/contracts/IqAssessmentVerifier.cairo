// SPDX-License-Identifier: MIT
// IqAssessmentVerifier.cairo
// Allows users to submit a hashed proof of completed IQ assessments

#[starknet::contract]
mod IqAssessmentVerifier {
    use core::starknet::contract_address::ContractAddress;
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::array::ArrayTrait;

    #[storage]
    struct Storage {
        // Store all submitted proofs
        proofs: Array<ProofEntry>,
    }

    struct ProofEntry {
        user: ContractAddress,
        hashed_score: felt252,
        timestamp: felt252,
    }

    #[abi(embed_v0)]
    impl IqAssessmentVerifierImpl of IqAssessmentVerifierTrait<ContractState> {
        /// Submit a hashed proof of completed IQ assessment
        fn submit_proof(ref self: ContractState, user: ContractAddress, hashed_score: felt252, timestamp: felt252) {
            let entry = ProofEntry { user, hashed_score, timestamp };
            self.proofs.append(entry);
            emit ProofSubmitted { user, hashed_score, timestamp };
        }

        /// Get all submitted proofs
        fn get_proofs(self: @ContractState) -> Array<ProofEntry> {
            self.proofs.clone()
        }
    }

    #[abi]
    trait IqAssessmentVerifierTrait<T> {
        fn submit_proof(ref self: T, user: ContractAddress, hashed_score: felt252, timestamp: felt252);
        fn get_proofs(self: @T) -> Array<ProofEntry>;
    }

    #[event]
    fn ProofSubmitted(user: ContractAddress, hashed_score: felt252, timestamp: felt252);
}
