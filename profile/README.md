<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/hashward-io/.github/main/profile/logo-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/hashward-io/.github/main/profile/logo-light.png">
    <img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/logo-dark.png" width="360" alt="Hashward — smart contract security audits">
  </picture>
</p>
<img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/banner.png" width="100%" alt="Hashward. We try to drain it before anyone else can. Sample finding HW-2026-014, Vault.sol withdraw, critical reentrancy: the call happens before the balance write.">

<p align="center">
  <b>Hashward audits smart contracts for teams about to ship.</b> Two reviewers read the code.<br>
  If a bug can move funds, the report includes a transaction that does it — and we rerun that transaction after you patch.
</p>

<p align="center">
  <a href="https://hashward.io">hashward.io</a> &nbsp;·&nbsp; <a href="mailto:hello@hashward.io">hello@hashward.io</a> &nbsp;·&nbsp; <a href="https://cal.com/hashward">Book a call</a>
</p>

<p align="center">
  <a href="#four-kinds-of-work-same-standard-on-each">Services</a> &nbsp;·&nbsp;
  <a href="#a-finding-start-to-finish">A finding</a> &nbsp;·&nbsp;
  <a href="#three-passes-then-we-argue">Method</a> &nbsp;·&nbsp;
  <a href="#one-to-three-weeks-price-fixed-before-we-start">Engagement</a> &nbsp;·&nbsp;
  <a href="#what-you-receive">Deliverables</a> &nbsp;·&nbsp;
  <a href="#the-people-doing-the-reading">Team</a> &nbsp;·&nbsp;
  <a href="#the-practical-questions">FAQ</a> &nbsp;·&nbsp;
  <a href="#send-the-repo">Contact</a>
</p>

<p align="center">
  <img alt="Solidity" src="https://img.shields.io/badge/Solidity-161614?style=flat-square">
  <img alt="Vyper" src="https://img.shields.io/badge/Vyper-161614?style=flat-square">
  <img alt="Anchor" src="https://img.shields.io/badge/Anchor-161614?style=flat-square">
  <img alt="Move" src="https://img.shields.io/badge/Move-161614?style=flat-square">
  <img alt="Foundry" src="https://img.shields.io/badge/Foundry-161614?style=flat-square">
  <img alt="Echidna" src="https://img.shields.io/badge/Echidna-161614?style=flat-square">
  <img alt="Halmos" src="https://img.shields.io/badge/Halmos-161614?style=flat-square">
  <img alt="Slither" src="https://img.shields.io/badge/Slither-161614?style=flat-square">
</p>

<p align="center">
  <img alt="Two reviewers" src="https://img.shields.io/badge/two%20reviewers-e24a2a?style=flat-square">
  <img alt="Runnable proof of concept on every exploitable finding" src="https://img.shields.io/badge/runnable%20PoC-e24a2a?style=flat-square">
  <img alt="Retest included in the fee" src="https://img.shields.io/badge/retest%20included-e24a2a?style=flat-square">
  <img alt="Flat quote before we start" src="https://img.shields.io/badge/flat%20quote-e24a2a?style=flat-square">
  <img alt="Private by default" src="https://img.shields.io/badge/private%20by%20default-e24a2a?style=flat-square">
  <img alt="NDA on request" src="https://img.shields.io/badge/NDA%20on%20request-e24a2a?style=flat-square">
</p>

<img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/facts.png" width="100%" alt="Solidity, Vyper, Anchor, and Move. Two reviewers, separate notes. Retest included in the fee.">

<sub>01 — WHAT YOU HIRE US FOR</sub>

## Four kinds of work. Same standard on each.

<img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/work.png" width="100%" alt="Contract review, economic review, fuzzing and proofs, and a fix retest. Exploitable issues ship with a runnable proof of concept. The report stays private unless you ask us to publish it.">

**Contract review.** Every function in scope, read by hand. Reentrancy, access control, accounting, proxies, upgrade paths. If it can move funds the wrong way, you get a runnable proof of concept, not a suggestion.

**Economic review.** Oracles, liquidation, MEV, and the incentive that breaks once real volume shows up. These sit between functions. A linter will not find them.

**Fuzzing and proofs.** Foundry and Echidna against the invariants you claim. Halmos where a property has to hold for every input.

**Fix retest.** You patch. We rerun the original proof of concept against the diff. The report stays private unless you ask us to publish it.

Also in scope when they exist: upgradeability and admin keys, role hierarchies, oracle and price-feed trust, cross-contract composition, MEV and slippage assumptions, and the deploy scripts that wire it all together. If a privileged key can take the funds, that is a finding — not a footnote.

---

<img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/quote.png" width="100%" alt="Most reports list smells. Ours includes the transaction that takes the funds.">

<sub>02 — A FINDING, START TO FINISH</sub>

## A finding, start to finish.

**HW-2026-014 · Vault.sol · `withdraw()`** &nbsp;·&nbsp; `Critical` &nbsp;·&nbsp; marked by reviewer B &nbsp;·&nbsp; PoC in the appendix &nbsp;·&nbsp; retested after the fix

```solidity
function withdraw(uint256 amt) external {
    require(bal[msg.sender] >= amt);
    (bool ok,) = msg.sender.call{value: amt}("");   // <- receiver re-enters here
    require(ok);
    bal[msg.sender] -= amt;                          // <- state written too late
}
```

**Impact.** A receiver contract re-enters `withdraw` before the balance write and empties the vault. One call, one malicious `receive()`, the whole balance.

**The proof.** Not a suggestion — a transaction. This contract is what we hand you, compiled and run against your deployment:

```solidity
contract Drain {
    Vault vault;

    constructor(Vault _vault) { vault = _vault; }

    function attack() external payable { vault.withdraw(1 ether); }

    receive() external {
        if (address(vault).balance >= 1 ether) vault.withdraw(1 ether);
    }
}
```

**The fix.** Checks-effects-interactions, then `nonReentrant`. Effects before the external call:

```solidity
function withdraw(uint256 amt) external nonReentrant {
    require(bal[msg.sender] >= amt);
    bal[msg.sender] -= amt;                 // effects first
    (bool ok,) = msg.sender.call{value: amt}("");
    require(ok);
}
```

**Retest.** We rerun the same transaction against your diff and say whether the hole is actually closed. Same report ID, one line: retested, still open, or closed.

---

<sub>03 — METHOD</sub>

## Three passes. Then we argue.

One reviewer misses things the other one is stubborn about. We keep the notes separate until both passes are done, then reconcile them. Tooling runs in parallel so a broken invariant shows up even if both of us read past it.

| Pass | What runs | What it catches |
|---|---|---|
| **Read** | Two reviewers, independent notes | Intent, composition, and the attack the tools cannot imagine |
| **Fuzz** | Foundry and Echidna against the invariants you wrote down | Broken invariants under generated inputs |
| **Prove** | Halmos where a property has to hold for every input | The few properties that can never be violated |
| **Sweep** | Slither, 38 detectors, in parallel with the reading | The obvious stuff, so no one burns review time on it |

A full run looks like this:

```console
$ hashward run --suite full ./src

ok   slither        38 detectors        clean
ok   foundry fuzz   2,400,000 runs      0 breaks
!!   echidna        invariant           totalSupply
ok   halmos         symbolic            3 proven

1 critical  2 high  3 medium  5 low        98.7% lines · 96.1% branches
```

---

<img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/engagement.png" width="100%" alt="One to three weeks. Price fixed before we start. Scope, review, report, retest. Nothing is billed before you accept.">

<sub>04 — AN ENGAGEMENT</sub>

## One to three weeks. Price fixed before we start.

**Scope.** We read the docs and the threat model, name the contracts in scope, and send a flat quote. Nothing is billed before you accept it.

**Review.** Two people, independent notes, then a pass where we try to kill each other's findings.

**Report.** Severity, a runnable proof of concept, and the change we want. A document you can hand to the engineer who will fix it.

**Retest.** Included. We rerun the original proofs against your diff and say whether the hole is actually closed.

A focused DeFi audit usually lands between **$8k and $40k**. It scales with the contracts, not a per-line rate. One to three weeks from kickoff to report — tell us the date if you have one, and we will tell you whether we can meet it before you pay anything.

---

<sub>05 — WHAT YOU RECEIVE</sub>

## What you receive.

- A report ranked Critical / High / Medium / Low / Informational — no filler findings to pad the page count
- A runnable proof of concept for every exploitable finding, in the appendix, reproducible against your deployment
- The exact change we want, written so the fixing engineer can act on it without calling us
- A retest after you patch, included in the fee, with the original proofs rerun against the diff
- Economic and trust notes: admin keys, oracle assumptions, upgrade paths, and what each one means for the user's funds
- Confidentiality by default. The report stays between us unless you ask us to publish it. NDA if you want one.

---

<sub>06 — TEAM</sub>

## The people doing the reading.

<p align="center">
  <a href="https://github.com/NetVar1337"><img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/founder-mh.png" width="420" alt="M.H, founder. Security research. Bitter Security. https://github.com/NetVar1337"></a>
  <a href="https://github.com/BunsDev"><img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/founder-val.png" width="420" alt="Val Alexander, founder. OpenCoven. TypeSafeAI. https://github.com/BunsDev"></a>
</p>

**M.H** — [github.com/NetVar1337](https://github.com/NetVar1337). Founder. Security research, Bitter Security. Exploit development and EVM internals; writes the proofs.

**Val Alexander** — [github.com/BunsDev](https://github.com/BunsDev). Founder. OpenCoven, TypeSafeAI. Protocol engineering and the economic side: incentives, oracles, liquidation.

No juniors on your code, no offshore second pass, no report assembled from a scanner dump. The two people who read the code sign the report.

---

<sub>07 — FAQ</sub>

## The practical questions.

<details>
<summary><b>How much does an audit cost?</b></summary>
<br>

It scales with the contracts, not a per-line rate. A focused DeFi audit usually lands between $8k and $40k. You get a flat number before we start, and nothing is billed before you accept it.
</details>

<details>
<summary><b>How long does it take?</b></summary>
<br>

One to three weeks from kickoff to the report. Tell us the date if you have one, and we will tell you up front whether we can meet it.
</details>

<details>
<summary><b>What do we actually receive?</b></summary>
<br>

A report. Each exploitable finding has a proof of concept and a fix. After you patch, we rerun those proofs and tell you whether the hole is closed.
</details>

<details>
<summary><b>Which chains?</b></summary>
<br>

EVM — Solidity and Vyper. Solana — Rust and Anchor. Move, if that's what you shipped.
</details>

<details>
<summary><b>Do you publish the report?</b></summary>
<br>

Only if you ask. Otherwise it stays between us. NDA on request.
</details>

<details>
<summary><b>What do you need from us to start?</b></summary>
<br>

The repo, the docs, and the threat model if you have one. We name the contracts in scope and send a flat quote. Usually within one business day.
</details>

---

<sub>08 — NEXT</sub>

## Send the repo.

Scope, a timeline, and a flat quote. One business day. NDA if you want one.

<a href="mailto:hello@hashward.io"><img src="https://raw.githubusercontent.com/hashward-io/.github/main/profile/cta.png" width="100%" alt="Send the repo. hello@hashward.io. Scope, a timeline, and a flat quote. One business day."></a>

<p align="center">
  <a href="mailto:hello@hashward.io"><b>hello@hashward.io</b></a> &nbsp;·&nbsp; <a href="https://cal.com/hashward">Book a call</a> &nbsp;·&nbsp; <a href="https://hashward.io">hashward.io</a>
</p>

<p align="center"><sub>Hashward · smart contract security audits · EVM &amp; Solana · we try to drain it before anyone else can</sub></p>
