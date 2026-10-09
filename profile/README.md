# Hashward

We try to drain it before anyone else can.

Hashward audits smart contracts for teams about to ship. Two reviewers read the code. If a bug can move funds, the report includes a transaction that does it. We rerun that transaction after you patch.

## Work

| Engagement | What you get |
| --- | --- |
| Contract review | Line-by-line review of Solidity, Vyper, Anchor, and Move. Exploitable issues ship with a runnable proof of concept. |
| Economic review | Oracles, liquidation, MEV, and incentives. The failures that sit between functions. |
| Fuzzing and proofs | Foundry and Echidna against the invariants you claim. Halmos where a property has to hold for every input. |
| Fix retest | Included in the fee. We rerun the original proofs against your diff. The report stays private unless you ask us to publish it. |

## An engagement

One to three weeks. The price is fixed before we start. A focused DeFi audit is usually $8k–$40k.

1. **Scope.** We read the docs and the threat model, name the contracts in scope, and send a flat quote. Nothing is billed before you accept it.
2. **Review.** Two people, independent notes, then a pass where we try to kill each other's findings.
3. **Report.** Severity, a runnable proof of concept, and the change we want. Written for the engineer who will fix it.
4. **Retest.** We rerun the original proofs against the diff and say whether the hole is closed.

## Request an audit

[hello@hashward.io](mailto:hello@hashward.io)

Scope, a timeline, and a flat quote. One business day. NDA if you want one.
