# Incentive System
**Description**: Job platform to post jobs, review applications, accept jobs, and acknowledge job progress. It helps organizers of an event to keep track of tasks and find the most experienced person to fulfill it. Implementing such a system on the blockchain allows for dynamic assignment and organization of resources while efficiently keeping track of them.

**Components**: 
- *JobFactory*: manages and creates jobs
- *JobApplication*: provides functionality to apply for jobs
- *JobReview*: offers functionality to review applicants and accept/deny

**Ideas**:
- function to auto create a bill for freelancers (law?)
- multisig for job completion
- request job progress acknowledgment to lock reward
### JobFactory
**Users**: 
- Applicant: can apply for job offers and accept if successful 
- Organizers: can post job offers and review applications
- Owner: can add and remove people from organizing team

**Function**:
- called by event organizers to create/post a new job
- provide all details a job requires
- emit an event that a job was published
- keep track of all events
- what is the most efficient way to map a job and contractor? array vs mapping depending on usage


# Voting System
**Description**: platform for stakeholders of the event to vote on certain decisions. The voting managers can publish votings and all registered stakeholders can take a vote with different weights. The results of all votings are transparently retrievable.

**Ideas**: 
- another type of organizer: e.g. voting manager
- can post votings related to a decision to make
- stakeholders can vote only once
- stakeholders can change their vote
- stakeholders can request additional options (on what communication medium? through smart contract?)
- voting managers can add new options
- owner can change an option (shouldn't usually happen)
- review result statistics
- publish result
- explanations shouldn't be stored on the blockchain: maybe only the hash of a message to verify integrity?
- different voting weights depending on sponsor type
- implement deadline
- organize and extract all votings in an event

# Application System
**Description** platform for projects to apply to the event. Manages the state of an application throughout the review process. Makes sure that the review is not publicly visible. Jurors will be assigned for each phase of the review process and submit their voting.

**Ideas**:
- profile per applicant?
- Project application:
    - has a deadline (can be changed by owner)
    - has one responsible team lead address
    - ?(team lead can add team member addresses)
    - different categorys to choose from
    - organizers can set these categories
    - categories are publicly viewable
    - every team requires github url, team size, categories
    - review commitee can rank each project in different rankings (anonym)
    - different reviewers can have different voting weights
    - owner can add ranking categories until review phase started
    - total ranking is released after some time (not viewable )
    - deadline for reviewing can be set by owner 
    - ranking will be released 1 day after the deadline was set; owner can change deadline during this time
    - deadline has to be at least 1 day after the current day
- Project Review:
    - project goes through review phases
    - in each phase: different set of jurors assigned to review a project
    - each juror will submit voting in ceratin categories
    - projects move forward according to a hardcap set by owner (either absolute or relative number of projects)
    - the voting should be anonymized and only visible to certain parties: to jurors, organizers, investors, and the project itself
    - only organizers should be able to review a ranking; ranking per category is anonymous to everyone else
    - which phase a project is in should be visible to everyone


