// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    
    struct Candidate {
        string name;
        bool registered;
        uint voteCount;
    }

    struct Voter {
        bool voted;
        bool registered;
        address vote;
    }

    address[] public candidateAddresses;
    address public owner;
    string public electionName;

    mapping(address => Voter) public voters;
    mapping(address => Candidate) public candidates;
    uint public totalVotes;
    
    enum State { Created, Voting, Ended }
    State public state;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    
    modifier inState(State _state) {
        require(state == _state, "Wrong state");
        _;
    }

    constructor(string memory _name) {
        owner = msg.sender;
        electionName = _name; 
        state = State.Created;
    }
    
    /**
    * @dev this function registers a candidate, msg.sender will be candidate and msg.value should be 1 eth.
    * @notice this function registers a new candidate.
     */
    function payFee() public payable {
        require(msg.value == 100 wei, "Pay 100 wei to register");
        candidates[msg.sender].registered = true;        
    }
    
    /**
    * @dev this function registers a voter, _voterAddress will be voter's address and voters[registered] is the flag.
    * @notice this function registers a new voter.
     */
    function registerVoter(address _voterAddress) onlyOwner inState(State.Created) public {
        require(!voters[_voterAddress].registered, "Voter is already registered");
        require(_voterAddress != owner, "Owner cannot be registered");
        voters[_voterAddress].registered = true;
    }

    /**
    * @dev this function adds a candidate, _canAddress will be the candidate address and _name will be the candidate's name.
    * @notice this function adds a new candidate.
    * @param _canAddress candidate address.
    * @param _name name of candidate.
     */
    function addCandidate(address _canAddress, string memory _name) inState(State.Created) onlyOwner public {
        require(candidates[_canAddress].registered, "Candidate is not registered");
        candidates[_canAddress].name = _name;
        candidates[_canAddress].voteCount = 0;
        candidateAddresses.push(_canAddress);
    }

    /** 
    * @dev this function sets the state to Created.
    * @notice this function indicates the start of the election.
    */
    function startVote() public inState(State.Created) onlyOwner {
        state = State.Voting;
    }

    /**
    * @dev this function casts vote, requires the voter to not have already voted,
        requires that the candidate's status is set to registered and requires that 
        the owner cannot vote. Specifies the address the voter voted for, and sets 
        the flag to indicate that the voter has now voted. It increments the 
        candidate's vote count and the total vote count.
    * @notice this function casts vote.
    * @param _canAddress candidate address.
     */
    function vote(address _canAddress) inState(State.Voting) public {
        require(voters[msg.sender].registered, "Voter is not registered");
        require(!voters[msg.sender].voted, "Voter has already voted");
        require(candidates[_canAddress].registered, "Not a registered candidate");
        require(msg.sender!=owner, "Owner cannot vote"); 

        voters[msg.sender].vote = _canAddress;
        voters[msg.sender].voted = true;
        candidates[_canAddress].voteCount++;
        totalVotes++;
    }

    /** 
    * @dev this function sets the state to Voting.
    * @notice this function indicates the start of the voting process.
    */
    function endVote() public inState(State.Voting) onlyOwner {
        state = State.Ended;
    }
    
    /** 
    * @dev this function announces the winner's address, compares the vote count for all the candidates.
    * @notice this function announces the winner.
    */
    function announceWinner() inState(State.Ended) onlyOwner public view returns (address) {
        uint max = 0;
        uint i;
        address winnerAddress;
        for(i=0; i<candidateAddresses.length; i++) {
            if(candidates[candidateAddresses[i]].voteCount > max) {
                max = candidates[candidateAddresses[i]].voteCount;
                winnerAddress = candidateAddresses[i];
            }
        }
        return winnerAddress;
    }
    
    /** 
    * @dev this function returns the length of the candidateAddress array.
    * @notice this function returns the total number of candidates.
    */
    function getTotalCandidates() public view returns(uint) {
        return candidateAddresses.length;
    }
    
    /** 
    * @dev this function returns the balance of the contract.
    * @notice this function returns the balance of the contract.
    */
    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }
    
    /** 
    * @dev this function transfers the funds from the contract to the owner.
    * @notice this function withdraws the funds.
    */
    function withdrawRegistrationFunds() onlyOwner inState(State.Ended) payable public {
        require(address(this).balance > 0, "No funds to transfer");
        payable(owner).transfer(address(this).balance);
    }
    
    /** 
    * @dev this function returns the balance of the owner
    * @notice this function returns the balance of the owner
    */
    function getOwnerBalance() public view returns(uint) {
        return owner.balance;
    }
    
}