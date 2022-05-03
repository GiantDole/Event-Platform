pragma solidity >=0.7.0 <0.9.0 ;

contract Ballot{

    //Variables 

    uint public totalVoters = 0;                //  total number of voters/jurors 
    enum State {Created, Voting, Ended}         // state variable for the system
    State public state ;

    struct rating{
        address jurorAddress;  // address of the voter
        mapping(bytes32 => uint) categoryRatings ;   // ratings of the voter by each category 
    }

    /* juror profile */
    struct juror {
        uint jurorId                               
        address jurorAddress ;  
    // string jurorName ;           // need to decide how to get this thing. Code is created with the assumption that only juror addresses are passed while creating an instance              
        bool rated ;            
        // uint vote ;            // either we include number of votes the person has
        // uint weight ;          // or we include the weight of  the votes the person has
    }

    /* proposal profile */
    struct proposal {
        uint proposalId
        bytes32 proposalName ;                               // name of the proposal 
        mapping(bytes32 => uint) aggregateRatings ;  // aggregate rating of the propsal in each cateogory
    }

    mapping(uint => rating) private allRatings ;                  // juror id  mapped to the rating  
    mapping(address => juror) public jurorRegister ;             // voter adrdess to details of the voter
    mapping(uint => Proposal) public proposalRegister ;         // id of proposal to the proposal . Should it be directly from name to proposal so as casting vote becomes clear ?
    mapping(bytes32 => uint8) public categorySet ;

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

    constructor (string memory _ballotOfficialName, bytes32[] memory proposalNames, bytes32[] memory categoryNames, address[] jurors ){   
        ballotOfficialAddress = msg.sender ;                                     // voting manager will create the ballot and that will become ballot official address
        ballotOfficialName  = _ballotOfficialName ;
        state = State.Created ;

        for (uint i = 0; i < proposalNames.length; i++) {
            proposal memory newProposal ;
            newProposal.proposalId = i ;
            newProposal.proposalName = proposalNames[i] ;
            for(uint j=0;j< categoryNames;j++){
                newProposal.aggregateRatings[categoryNames[j]] = 0 ;
            }
            proposalRegister[i] = newProposal;
        }

        for(uint i=0;i<jurorAddress.length;i++){
            jurorRegister[jurors[i]] = juror({jurorId:i, jurorAddress:jurors[i],rated:false}) ;
        }

        for(uint i=0;i<categoryNames;i++){
            categorySet[categoryNames[i]] = 1; 
        }
        
    }   

    function addProposal(bytes32 memory _proposalName )                  // adding a proposal
        public 
        inState(State.Created)
        isChairperson 
    {
        proposal memory newProposal ;
        newProposal.proposalId = proposalRegister.length ;
        newProposal.proposalName = _proposalName ;
        for(uint j=0;j< categoryNames;j++){
            newProposal.aggregateRatings[categoryNames[j]] = 0 ;
        }
    }

    function addCategory(bytes32 memory _categoryName )                  // adding a proposal
        public 
        inState(State.Created)
        isChairperson 
    {
        for (uint p = 0; p < proposalRegister.length; p++) {
            proposalRegister[p].voteCount[_categoryName] = 0 ;
        }
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

    function castVote(uint _proposalId,bytes32[] categories,uint[] ratings )                                         
        public 
        inState(State.Voting)
        returns (bool voted)
    {
        bool hasVoted = false ;
        if(voterRegister[msg.sender].voterName.length !=0 && !voterRegister[msg.sender].voted){                 
            
            vote memory v;
            v.voterAddress = msg.sender ;
            v.choice    = _proposalId ;
            proposalRegister[_proposalId].voteCount ++ ; 
            voterRegister[msg.sender].voted = true ;
        }
        return hasVoted ;
    }
    
    function aggregateScores()
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
