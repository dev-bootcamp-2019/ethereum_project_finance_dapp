Design Patterns Used & Why:
1. Fail early and fail loud: Require is used throughout to indicate parameters of each function, including as modifiers and function-by-function
2. Restricting Access: Roles are implemented throughout the contract as described in the readme
3. Pull over Push Payments: The withdrawal pattern is used to avoid reentrancy and extended transfer loops
4. Circuit Breaker: Pausable is imported from OpenZeppelin to allow deposits, withdrawals, and project approval to be paused in the event of an emergency
5. State Machine: The entire contract is a state machine architecture to reflect typical project finance workflow