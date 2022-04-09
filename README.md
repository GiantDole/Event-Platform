# Incentive System
**Description**: Job platform to post jobs, review applications, accept jobs, and acknowledge job progress. It helps organizers of an event to keep track of tasks and find the most experienced person to fulfill it. Implementing such a system on the blockchain allows for dynamic assignment and organization of resources while efficiently keeping track of them.

**Components**: 
    - *JobFactory*: manages and creates jobs
    - *JobApplication*: provides functionality to apply for jobs
    - *JobReview*: offers functionality to review applicants and accept/deny

## JobFactory
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