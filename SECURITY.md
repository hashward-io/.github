# Security policy

This policy applies to every repository in the `hashward-io` organisation that
does not ship its own `SECURITY.md`.

## Reporting a vulnerability

Do not open a public issue. Use one of:

1. **GitHub private vulnerability reporting** on the affected repository
   (Security → Report a vulnerability). Preferred: it keeps the report, the fix
   and the advisory in one place.
2. **Email** — `hello@hashward.io`.

Include the affected repository and commit, a description, reproduction steps
or a minimal proof of concept, impact, and any mitigation you know of.

## Response

| Stage | Target |
| --- | --- |
| Acknowledgement | 72 hours |
| Initial assessment | 7 days |
| Fix and coordinated disclosure | agreed with the reporter, target < 90 days |

## Scope

In scope: our own code and CI. That includes sandbox escape, credential
exposure, path traversal, command injection through crafted targets, and
supply-chain compromise of our release artifacts.

Out of scope: vulnerabilities in third-party dependencies that are already
public and have an upstream fix (report those upstream), and findings that
require a compromised maintainer account.

## Handling

- Never commit a credential. If one lands, rotate it first, then rewrite
  history; deleting the file is not enough.
- Security fixes are developed in a private fork or a private advisory branch,
  reviewed by a second human, and released with an advisory and a CVE where the
  impact warrants one.
- Tool output (scanner findings, model output, target code) is untrusted input.
  It never reaches a shell, a template or a report without validation.
