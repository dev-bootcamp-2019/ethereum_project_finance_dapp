This dapp implements a project finance workflow of the following user roles via the ProjectDelivery smart contract:

1. Manager: the contract admin approves addresses to be each role (except recipients)
2. Monitor: an oracle-like role which determines eligible recipients of projects and verifies whether projects have been successfully completed
3. Recipient: the beneficiary of the project itself is qualified by the Monitor and has authority to accept or reject the project proposal
4. Provider: the service provider who bids on the project and sees it through to successful completion (when they are paid)
5. Sponsor: the financial sponsor of the project places funds into the project once a monitor, recipient, and provider have been identified and agreed on the project's cost

Projects may travel through the following stages:

1. Proposed: the provider submits a bid to do a project for a qualified recipient
2. Qualified: the recipient's monitor qualifies the project proposal as acceptable for review
3. Accepted: the recipient may accept the qualified propoal if they so choose
4. Denied: alternately, the recipient may deny the project proposal
5. Sponsored: if the project is accepted, a sponsor may fund the project
6. UnderReview: once the provider has completed the project, they submit their work for review
7. Completed: the monitor verifies that the work has been done according to spec and funds are released
8. Failed: in the case that the work is not suitable, it is either sent back to Sponsored state for completion or becomes permanently failed (funds are returned to sponsor)

Tests written for the ProjectDelivery smart contract are:
1. Ensure that the inital projectCount is 1 (rather than 0) to avoid issues with the fact that default values in Solidity are 0
2. Test that the circuit breaker is not tripped upon initialization (i.e. contract is not paused)

The other smart contracts are Roles, PauserRole, and Pausable from OpenZeppelin, used to meet the following requirements:
1. Use of a library
2. Use of the circuit breaker design pattern

The application itself is bootstrapped from the truffle drizzle box. To run it, follow the setup directions here: `https://github.com/truffle-box/drizzle-box`

As most of the project time was spent developing the backend smart contract `ProjectDelivery`, there is little frontend functionality currently integrated with the `ProjectDelivery` contract. However, feel free to play around with the `SimpleStorage`, `ComplexStorage`, and `TutorialToken` integrations to see how `ProjectDelivery` could be intergrated in the future.