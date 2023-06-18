// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Voting {
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
    }
    uint8 candiateId=0;
    mapping(uint8 => Candidate) candidates;

    struct Voter{
        string name;
        address voterAddress;
    }
    mapping(address => Voter) voters;

    function startElection(address owner) public {
        require(owner == admin,"Only admin is allowed to start election");
        require ((status == ElectionStatus.NOT_STARTED || status == ElectionStatus.ENDED),"Election already started");
        status = ElectionStatus.STARTED;
    }

    function getElectionStatus() public view returns (ElectionStatus) {
        return status;
    }

    function endElection(address owner) public {
        require(owner == admin,"Only admin is allowed to end election");
        require (status == ElectionStatus.STARTED,"election is not started");
        status = ElectionStatus.ENDED;
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
    }

    function getCandidate(uint8 _id) public view returns(Candidate memory){
        return candidates[_id];
    }

    function getVoter(address _voterAddress) public view returns (Voter memory){
        return voters[_voterAddress];
    }

    function addVoter(string memory  name,address _voterAddrress) public{
        voters[_voterAddrress].name = name;
        voters[_voterAddrress].voterAddress = _voterAddrress;
    }
    
}
