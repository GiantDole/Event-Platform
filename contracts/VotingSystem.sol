pragma solidity >=0.7.0 <0.9.0 ;

contract Ballot{

    //Variables 

    uint public totalVoters = 0;                //  total number of voters/jurors 
    uint public totalVotes = 0;                 // total number of votes that have been cast
    enum State {Created, Voting, Ended}         // state variable for the system
    State public state ;
    bytes32 winner ;

    struct vote{
        address voterAddress;  // address of the voter
        uint proposalId ;   // choice of the voter
    }

    struct voter {
        // address voterAddress ;  
        string voterName ;
        bool voted ;            
        uint vote ;            // either we include number of votes the person has
        uint weight ;          // or we include the weight of  the votes the person has
    }

    struct Proposal {
        uint voteCount ;
        bytes32 name ;
                                                // description could also be added    
    }

    //MODIFIER 
    modifier condition(bool _condition){                        // only performed when the condition is satisfied 
        require(_condition);
        _;
    }

    modifier isChairperson(){                                     // permission only to ballot official address    
        require(msg.sender == ballotOfficialAddress);
        _;
    }

    modifier inState(State_state){                                // changes can only be made in the starting      
        require(state == _state);
        _;
    }

    mapping(uint => vote) private votes ;                        // vote number mapped to the vote  
    mapping(address => voter) public voterRegister ;             // voter adrdess to details of the voter
    mapping(uint => Proposal) public proposalRegister ;         // id of proposal to the proposal . Should it be directly from name to proposal so as casting vote becomes clear ?



    constructor (string memory _ballotOfficialName, bytes32[] memory proposalNames ){   // Looks like a constructor for yes or no vote for a single proposal
        ballotOfficialAddress = msg.sender ;                                     // voting manager will create the ballot and that will become ballot official address
        ballotOfficialName  = _ballotOfficialName ;
        state = State.Created ;
        for (uint i = 0; i < proposalNames.length; i++) {
            proposalRegister[i+1] = Proposal({name: proposalNames[i], voteCount: 0}));
        }
    }   

    function addProposal(bytes32 memory _proposalName )                  // adding a proposal
        public 
        inState(State.Created)
        isChairperson 
    {
        proposalRegister[proposalRegister.length] = Proposal({name: _proposalName, voteCount: 0})
    }

    function addVoter(address _voterAddress , string memory _voterName)         // adding a voter 
        public inState(State.Created)
        isChairperson 
    {
        voter memory v ; 
        v.voterName  = _voterName ;
        v.voted  = false ;
        voterRegister[ _voterAddress ] = v ;
        totalVoters ++ ;
    }

    function startVote()                                                    //  begin voting
        public 
        inState(State.Created)
        isChairperson
    {
        state = State.Voting ;
    }

    function castVote(uint _proposalId)                                         
        public 
        inState(State.Voting)
        returns (bool voted)
    {
        bool hasVoted = false ;
        if(voterRegister[msg.sender].voterName.length !=0 && !voterRegister[msg.sender].voted){                 
            voterRegister[msg.sender].voted = true ;
            vote memory v;
            v.voterAddress = msg.sender ;
            v.choice    = _proposalId ;
            proposalRegister[_proposalId].voteCount ++ ; 
            totalVotes++ ;
        }
        return hasVoted ;
    }
    
    function endVote()
        public 
        inState(State.Voting)
        isChairperson
    {
        state   = state.Ended ;
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposalRegister.length; p++) {
            if (proposalRegister[p].voteCount > winningVoteCount) {
                winningVoteCount = proposalRegister[p].voteCount;
                winner = proposalRegister[p].name ;
            }
        }
    }

    function winningProposal() 
        public 
        inState(State.Ended)
        returns (bytes32 winnerName_)
    {
        return winner ;
    }

}