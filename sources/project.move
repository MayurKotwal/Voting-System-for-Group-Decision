module Votingsystemforgroupdecisions::VotingSystem {
    use std::vector;
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Error codes
    const E_PROPOSAL_NOT_ACTIVE: u64 = 1;
    const E_ALREADY_VOTED: u64 = 2;
    const E_INVALID_PROPOSAL: u64 = 3;

    /// Struct for storing voting proposal details
    struct Proposal has store, key {
        description: vector<u8>,
        yes_votes: u64,
        no_votes: u64,
        end_time: u64,
        voters: vector<address>
    }

    /// Create a new proposal for voting
    public fun create_proposal(
        creator: &signer,
        description: vector<u8>,
        duration: u64
    ) {
        let proposal = Proposal {
            description,
            yes_votes: 0,
            no_votes: 0,
            end_time: timestamp::now_seconds() + duration,
            voters: vector::empty<address>()
        };
        move_to(creator, proposal);
    }

    /// Cast a vote on a proposal
    public fun vote(
        voter: &signer,
        proposal_address: address,
        vote_yes: bool
    ) acquires Proposal {
        let proposal = borrow_global_mut<Proposal>(proposal_address);
        
        // Check if proposal is still active
        assert!(timestamp::now_seconds() <= proposal.end_time, E_PROPOSAL_NOT_ACTIVE);
        
        // Check if voter hasn't voted before
        let voter_addr = signer::address_of(voter);
        assert!(!vector::contains(&proposal.voters, &voter_addr), E_ALREADY_VOTED);
        
        // Record vote
        if (vote_yes) {
            proposal.yes_votes = proposal.yes_votes + 1;
        } else {
            proposal.no_votes = proposal.no_votes + 1;
        };
        vector::push_back(&mut proposal.voters, voter_addr);
    }
}