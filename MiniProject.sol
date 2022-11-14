// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.0 <0.8.0;

contract MiniProject {
    // VARIBLES
    struct vote {
        address voterAddresss;
        bool choice;
    }

    struct voter {
        string voterName;
        bool voted;
    }
    
    uint private countResult = 0;
    uint public finalResult = 0;
    uint public totalVoter = 0;
    uint public totalVote = 0;

    address public ballotOfficialAddress;
    string public ballotOfficalName;
    string public proposal;

    mapping(uint => vote) private votes; // mapping(dicitionary) of votes for each 
    mapping(address => voter) public voterRegister; // mapping(dicitionary) of addresses of voters

    enum State { Created, Voting, Ended }
    State public state;

    // MODIFIER
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyOfficial() {
        require(msg.sender == ballotOfficialAddress);
        _;
    }

    modifier inState(State _state) {
        require(state == _state);
        _;
    }


    // FUNCTION
    constructor(
        string memory _ballotofficalName,
        string memory _proposal
    )  {
        ballotOfficialAddress = msg.sender;
        ballotOfficalName = _ballotofficalName;
        proposal = _proposal;
        state = State.Created;
    }
    
    function addVoter(
        address _voterAdress,
        string memory _voterName
    ) public
        inState(State.Created) // Function should be called only after the constructor is invoked   
        onlyOfficial  // Only officials can add voters and not voters themselves
    {
        voter memory v;
        v.voterName = _voterName; // Passed name
        v.voted = false; // Initially hasn't voted
        voterRegister[_voterAdress] = v; // Store Voter's address in the voterRegister array
        totalVoter++; // Increase total voters
    }

    function startVote() 
        public 
        inState(State.Created) 
        onlyOfficial 
    {
        state = State.Voting;
    }

    function doVote(bool _choice)
        public
        inState(State.Voting)
        returns (bool voted) 
    {
        bool isFound = false;
        if(bytes(voterRegister[msg.sender].voterName).length != 0  // voterRegister has struct voter stored which has a property voterName. In order to check length , we convert length into Bytes and compare 
            && voterRegister[msg.sender].voted == false ) // Check if voter is registered and not already voted
        {
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddresss = msg.sender;
            v.choice = _choice;
            if(_choice) {
                countResult++;
            }
            votes[totalVote] = v;
            totalVote++;
            isFound = true;
        }
        return isFound;
    }

    function endVote() 
        public
        inState(State.Voting)
        onlyOfficial
    {
        state = State.Ended;
        finalResult = countResult;
    }

}
