# Freelancing Platform
**Description**: Freelancing platform to post tasks, review applications, accept jobs, and acknowledge job progress. It helps organizers of an event to keep track of tasks and find the most experienced person to fulfill it. Implementing such a system on the blockchain allows for dynamic assignment and organization of resources while efficiently keeping track of them.


**Components**: 
- *JobFactory*: manages and creates jobs
- *JobApplication*: provides functionality to apply for jobs
- *JobReview*: offers functionality to review applicants and accept/deny

**Ideas**:
- function to auto create a bill for freelancers (law?)
- multisig for job completion
- request job progress acknowledgment to lock reward

**Users**: 
- Applicant: can apply for job offers and accept if successful 
- Organizers: can post job offers and review applications
- Owner: can add and remove people from organizing team

**Function**:
- called by event organizers to create/post a new task
- view open tasks
- view all tasks
- manage assigned tasks
- provide all details a task requires
- keep track of all tasks
