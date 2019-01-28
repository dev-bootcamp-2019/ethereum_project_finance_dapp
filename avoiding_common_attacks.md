Safety Checklist:
1. Logic Bugs: Care has been taken to eliminate loops and contain the logical flow of the state machine to sensible parameters.
2. Recursive Calls: There are no opportunities for recursive calls to my knowledge.
3. Integer Arithmetic Overflow: Other than the projectCount, integer math is not present in the contract. SafeMath can be implemented to avoid even the count rolling over in the future.
4. Poison Data: Other than a placeholder "name" field which will be transitioned to an IPFS data hash later on in development, no data is open to unrestricted user input.
5. Exposure (Functions & Secrets): functions are limited by role modifiers as described in the readme
6. Timestamp Vulnerabilities: timestamps are not relied on for functionality in this architecture
7. Powerful Contract Administrators: the power of the contract manager is somewhat concentrated, but could easily be decentralized in future development
8. Off-Chain Safety: Drizzle & Truffle are used as an extensible framework that encourages best practices
9. Cross-Chain Replay: Circuit breaker design is implemented at critical functions to ensure resiliency to hard forks
10. Tx.origin: tx.origin is not used at all, rather msg.sender is used instead
11. Gas Limits: loops are not used at all, undefined arrays are not referenced as a whole, instead opting for mappings and structs