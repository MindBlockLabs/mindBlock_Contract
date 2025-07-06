#[cfg(test)]
mod test_question_registry {
    use starknet::{ContractAddress, get_caller_address};
    use core::serde::Serde;
    use core::result::ResultTrait;
    use snforge_std::{declare, ContractClassTrait, deploy, start_prank, stop_prank};

    
    use src::contracts::question_registry::QuestionRegistry;
    use src::contracts::question_registry::{Question, QuestionStatus};

    
    fn setup() -> (ContractAddress, ContractAddress, ContractAddress, ContractAddress) {
        
        let contract = declare("QuestionRegistry");

        
        let owner_address: ContractAddress = 1.try_into().unwrap();
        let moderator_address: ContractAddress = 2.try_into().unwrap();
        let user_address: ContractAddress = 3.try_into().unwrap();

        
        let constructor_calldata = array![owner_address.into()];
        let contract_address = contract.deploy(@constructor_calldata).unwrap();

        (contract_address, owner_address, moderator_address, user_address)
    }

    #[test]
    fn test_submit_question() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        let category: felt252 = 'Math';
        let difficulty: felt252 = 'Hard';
        let hash: felt252 = 'ipfs_hash_123';

        
        start_prank(contract_address, user);
        dispatcher.submit_question(category, difficulty, hash);
        stop_prank(contract_address);

        
        let question = dispatcher.get_question(1);
        assert(question.id == 1, 'ID mismatch');
        assert(question.submitter == user, 'Submitter mismatch');
        assert(question.category == category, 'Category mismatch');
        assert(question.status == QuestionStatus::Pending, 'Status not Pending');
    }

    #[test]
    fn test_moderator_management() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        
        start_prank(contract_address, owner);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);

        assert(dispatcher.is_moderator(moderator), 'Moderator not added');

        
        start_prank(contract_address, owner);
        dispatcher.remove_moderator(moderator);
        stop_prank(contract_address);

        assert(!dispatcher.is_moderator(moderator), 'Moderator not removed');
    }

    #[test]
    #[should_panic(expected: ('Not the owner',))]
    fn test_add_moderator_by_non_owner() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        
        start_prank(contract_address, user);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);
    }


    #[test]
    fn test_approve_and_reject_question() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        
        start_prank(contract_address, owner);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);

        
        start_prank(contract_address, user);
        dispatcher.submit_question('Science', 'Easy', 'hash456');
        stop_prank(contract_address);

        
        start_prank(contract_address, moderator);
        dispatcher.approve_question(1);
        stop_prank(contract_address);

        let question_1 = dispatcher.get_question(1);
        assert(question_1.status == QuestionStatus::Approved, 'Question not approved');

        
        start_prank(contract_address, user);
        dispatcher.submit_question('History', 'Medium', 'hash789');
        stop_prank(contract_address);

        
        start_prank(contract_address, moderator);
        dispatcher.reject_question(2);
        stop_prank(contract_address);

        let question_2 = dispatcher.get_question(2);
        assert(question_2.status == QuestionStatus::Rejected, 'Question not rejected');
    }

    #[test]
    #[should_panic(expected: ('Not a moderator',))]
    fn test_approve_by_non_moderator() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        
        start_prank(contract_address, user);
        dispatcher.submit_question('Art', 'Easy', 'hash_art');
        stop_prank(contract_address);

        
        start_prank(contract_address, user);
        dispatcher.approve_question(1);
        stop_prank(contract_address);
    }

    #[test]
    #[should_panic(expected: ('Question not pending',))]
    fn test_approve_already_approved_question() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        
        start_prank(contract_address, owner);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);
        
        start_prank(contract_address, user);
        dispatcher.submit_question('Art', 'Easy', 'hash_art_2');
        stop_prank(contract_address);

        start_prank(contract_address, moderator);
        dispatcher.approve_question(1);

        
        dispatcher.approve_question(1);
        stop_prank(contract_address);
    }

    #[test]
    fn test_vote_on_question() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        // Add moderator
        start_prank(contract_address, owner);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);

        // Submit a question
        start_prank(contract_address, user);
        dispatcher.submit_question('Math', 'Hard', 'ipfs_hash_123');
        stop_prank(contract_address);

        // Approve the question
        start_prank(contract_address, moderator);
        dispatcher.approve_question(1);
        stop_prank(contract_address);

        // Vote on the question
        start_prank(contract_address, user);
        dispatcher.vote_on_question(1, true);
        stop_prank(contract_address);

        // Check if vote is recorded
        assert(dispatcher.has_voted(1, user), 'Vote not recorded');
        assert(dispatcher.get_helpfulness_score(1) == 1, 'Helpfulness score incorrect');
    }

    #[test]
    #[should_panic(expected: ('Already voted',))]
    fn test_double_voting() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        // Add moderator
        start_prank(contract_address, owner);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);

        // Submit a question
        start_prank(contract_address, user);
        dispatcher.submit_question('Science', 'Easy', 'hash456');
        stop_prank(contract_address);

        // Approve the question
        start_prank(contract_address, moderator);
        dispatcher.approve_question(1);
        stop_prank(contract_address);

        // Vote on the question twice
        start_prank(contract_address, user);
        dispatcher.vote_on_question(1, true);
        dispatcher.vote_on_question(1, false);
        stop_prank(contract_address);
    }

    #[test]
    #[should_panic(expected: ('Question not approved',))]
    fn test_vote_on_unapproved_question() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };

        // Submit a question without approving it
        start_prank(contract_address, user);
        dispatcher.submit_question('History', 'Medium', 'hash789');
        stop_prank(contract_address);

        // Try to vote on unapproved question
        start_prank(contract_address, user);
        dispatcher.vote_on_question(1, true);
        stop_prank(contract_address);
    }

    #[test]
    fn test_multiple_votes_different_users() {
        let (contract_address, owner, moderator, user) = setup();
        let dispatcher = QuestionRegistry::Dispatcher { contract_address };
        let user2: ContractAddress = 4.try_into().unwrap();

        // Add moderator
        start_prank(contract_address, owner);
        dispatcher.add_moderator(moderator);
        stop_prank(contract_address);

        // Submit a question
        start_prank(contract_address, user);
        dispatcher.submit_question('Art', 'Easy', 'hash_art');
        stop_prank(contract_address);

        // Approve the question
        start_prank(contract_address, moderator);
        dispatcher.approve_question(1);
        stop_prank(contract_address);

        // First user votes helpful
        start_prank(contract_address, user);
        dispatcher.vote_on_question(1, true);
        stop_prank(contract_address);

        // Second user votes unhelpful
        start_prank(contract_address, user2);
        dispatcher.vote_on_question(1, false);
        stop_prank(contract_address);

        // Check net helpfulness score
        assert(dispatcher.get_helpfulness_score(1) == 0, 'Net score should be 0');
        assert(dispatcher.has_voted(1, user), 'First user vote not recorded');
        assert(dispatcher.has_voted(1, user2), 'Second user vote not recorded');
    }
}