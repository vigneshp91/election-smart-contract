// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Voting {
    mapping(uint8 => string) ElectionStatusMapping;

    constructor(){
        ElectionStatusMapping[0] = "NOT_STARTED";
        ElectionStatusMapping[1] = "STARTED";
        ElectionStatusMapping[2] = "ENDED";
    }
    
    enum ElectionStatus {
        NOT_STARTED,
        STARTED,
        ENDED
    }
    address admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    ElectionStatus status = ElectionStatus.NOT_STARTED;

    struct Candidate {
        string name;
        address owner;
        string proposal;
        uint8 votes;
    }
    uint8 candiateId=0;
    mapping(uint8 => Candidate) candidates;

    struct Voter{
        string name;
        address voterAddress;
        uint8 no_of_votes;
        address delegateAddress;
        uint8 votedTowards;
    }
    mapping(address => Voter) voters;
    uint8[] candidatesInElection;
    address[] votersInElection;

    function startElection() public {
        require(msg.sender == admin,"Only admin is allowed to start election");
        require ((status == ElectionStatus.NOT_STARTED || status == ElectionStatus.ENDED),"Election already started");
        status = ElectionStatus(ElectionStatus.STARTED);
    }

    function getElectionStatus() public view returns (string memory) {
        return ElectionStatusMapping[uint8(status)];
    }

    function endElection() public {
        require(msg.sender == admin,"Only admin is allowed to end election");
        require (status == ElectionStatus.STARTED,"election is not started");
        status = ElectionStatus(ElectionStatus.ENDED);
    }

    function addCandidate(
        string memory _name,
        string memory _proposal,
        address owner
    ) public {
        require(msg.sender == admin,"Only admin is allowed to add candidate");
        require((status == ElectionStatus.NOT_STARTED ||status == ElectionStatus.ENDED),"Election already started");
        candiateId++;
        candidates[candiateId].name = _name;
        candidates[candiateId].proposal = _proposal;
        candidates[candiateId].owner = owner;
        candidatesInElection.push(candiateId);
    }

    function getCandidate(uint8 _id) public view returns(uint8 id,string memory name,string memory proposal,address owner){
        return (_id,candidates[_id].name,
        candidates[_id].proposal,
        candidates[_id].owner);
    }

    function getVoter(address _voterAddress) public view returns (string memory name,address owner,address delegateaddress,uint8 weight,uint8 votedTowards){
        return (voters[_voterAddress].name,
        voters[_voterAddress].voterAddress,
        voters[_voterAddress].delegateAddress,
        voters[_voterAddress].no_of_votes,
        voters[_voterAddress].votedTowards);
    }

    function addVoter(string memory  name,address _voterAddrress) public{
        voters[_voterAddrress].name = name;
        voters[_voterAddrress].voterAddress = _voterAddrress;
        voters[_voterAddrress].no_of_votes = 1;
        votersInElection.push(_voterAddrress);
    }

    function delegateVote(address voterAddress,address receiverAddress) public{
        require(msg.sender==voterAddress,"Only voter can deligate his vote");
        require(voters[voterAddress].no_of_votes>0,"voter not exists");
        require(voters[receiverAddress].no_of_votes>0,"receiver not exists");

        uint8 noofVotes = voters[voterAddress].no_of_votes;
        voters[receiverAddress].no_of_votes+=noofVotes;
        voters[voterAddress].no_of_votes-=1;
        voters[voterAddress].delegateAddress = receiverAddress;

    }

    function vote(uint8 candidateId, address voter) public{
        require(msg.sender==voter,"Only voter can cast his vote");
        require(voters[voter].no_of_votes>0,"Voter already voted");
        candidates[candidateId].votes+=1;
        voters[voter].no_of_votes-=1;
        voters[voter].votedTowards = candidateId;
    }

    function showWinner()public view returns(uint8 id,string memory name,uint8 Votes) {
        require(msg.sender == admin,"Only admin is allowed to reveal the winner");
        require(status == ElectionStatus.ENDED,"Election not ended");
        uint8 winnerId;
        string memory winnerName;
        uint8 totalVotes = 0;
        for (uint8 i =0; i<candidatesInElection.length; i++) 
        {
            if (totalVotes<candidates[candidatesInElection[i]].votes){
                winnerId = candidatesInElection[i];
                winnerName = candidates[candidatesInElection[i]].name;
                totalVotes = candidates[candidatesInElection[i]].votes;
            }
        }
        return (winnerId,winnerName,totalVotes);
    }

    function getVoterCount()public view returns (uint){
        return votersInElection.length;
    }

    function getCandidateCount() public view returns (uint){
        return candidatesInElection.length;
    }


}
