#[starknet::contract]
mod QuestionRegistry {
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::get_block_timestamp;

    #[derive(Copy, Drop, starknet::Store, Serde)]
    enum QuestionStatus {
        Pending,
        Approved,
        Rejected,
    }

    #[derive(Copy, Drop, starknet::Store, Serde)]
    struct Question {
        id: u64,
        submitter: ContractAddress,
        category: felt252,
        difficulty: felt252,
        hash: felt252,
        timestamp: u64,
        status: QuestionStatus,
    }

    #[storage]
    struct Storage {
        questions: LegacyMap<u64, Question>,
        moderators: LegacyMap<ContractAddress, bool>,
        next_question_id: u64,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        QuestionSubmitted: QuestionSubmitted,
        QuestionApproved: QuestionApproved,
        QuestionRejected: QuestionRejected,
        ModeratorAdded: ModeratorAdded,
        ModeratorRemoved: ModeratorRemoved,
    }

    #[derive(Drop, starknet::Event)]
    struct QuestionSubmitted {
        question_id: u64,
        submitter: ContractAddress,
        category: felt252,
        difficulty: felt252,
        hash: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct QuestionApproved {
        question_id: u64,
        moderator: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct QuestionRejected {
        question_id: u64,
        moderator: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct ModeratorAdded {
        moderator_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct ModeratorRemoved {
        moderator_address: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner_address: ContractAddress) {
        self.owner.write(owner_address);
        self.next_question_id.write(1);
    }

    #[external(v0)]
    fn submit_question(
        ref self: ContractState, category: felt252, difficulty: felt252, hash: felt252
    ) {
        let caller = get_caller_address();
        let question_id = self.next_question_id.read();

        let new_question = Question {
            id: question_id,
            submitter: caller,
            category: category,
            difficulty: difficulty,
            hash: hash,
            timestamp: get_block_timestamp(),
            status: QuestionStatus::Pending,
        };

        self.questions.write(question_id, new_question);
        self.next_question_id.write(question_id + 1);

        self.emit(
            Event::QuestionSubmitted(
                QuestionSubmitted {
                    question_id: question_id,
                    submitter: caller,
                    category: category,
                    difficulty: difficulty,
                    hash: hash,
                }
            )
        );
    }

    #[external(v0)]
    fn approve_question(ref self: ContractState, question_id: u64) {
        self.assert_moderator();
        let mut question = self.questions.read(question_id);
        assert(question.status == QuestionStatus::Pending, 'Question not pending');

        question.status = QuestionStatus::Approved;
        self.questions.write(question_id, question);

        self.emit(
            Event::QuestionApproved(
                QuestionApproved { question_id: question_id, moderator: get_caller_address() }
            )
        );
    }

    #[external(v0)]
    fn reject_question(ref self: ContractState, question_id: u64) {
        self.assert_moderator();
        let mut question = self.questions.read(question_id);
        assert(question.status == QuestionStatus::Pending, 'Question not pending');

        question.status = QuestionStatus::Rejected;
        self.questions.write(question_id, question);

        self.emit(
            Event::QuestionRejected(
                QuestionRejected { question_id: question_id, moderator: get_caller_address() }
            )
        );
    }

    #[external(v0)]
    fn add_moderator(ref self: ContractState, moderator_address: ContractAddress) {
        self.assert_owner();
        self.moderators.write(moderator_address, true);
        self.emit(Event::ModeratorAdded(ModeratorAdded { moderator_address: moderator_address }));
    }

    #[external(v0)]
    fn remove_moderator(ref self: ContractState, moderator_address: ContractAddress) {
        self.assert_owner();
        self.moderators.write(moderator_address, false);
        self.emit(Event::ModeratorRemoved(ModeratorRemoved { moderator_address: moderator_address }));
    }

    #[view]
    fn get_question(self: @ContractState, question_id: u64) -> Question {
        self.questions.read(question_id)
    }

    #[view]
    fn is_moderator(self: @ContractState, address: ContractAddress) -> bool {
        self.moderators.read(address)
    }

    fn assert_moderator(self: &ContractState) {
        let caller = get_caller_address();
        assert(self.moderators.read(caller), 'Not a moderator');
    }

    fn assert_owner(self: &ContractState) {
        let caller = get_caller_address();
        assert(caller == self.owner.read(), 'Not the owner');
    }
}