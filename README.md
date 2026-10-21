# hashward-io/.github

Organisation defaults for [Hashward](https://github.com/hashward-io).

GitHub renders [`profile/README.md`](profile/README.md) on the organisation overview.

## Organisation defaults

These files apply to every repository in the organisation that does not ship its
own copy:

| Path | Purpose |
| --- | --- |
| `SECURITY.md` | Vulnerability reporting, response targets, scope |
| `CONTRIBUTING.md` | Branch, check, secret, and review rules |
| `.github/ISSUE_TEMPLATE/` | Bug and feature forms; blank issues disabled |
| `.github/pull_request_template.md` | Summary, verification, risk, checklist |
| `.github/workflows/secret-scan.yml` | Reusable gitleaks scan |

## Using the secret scan

Every repository carries its own copy of
`.github/workflows/secret-scan.yml`, so no runtime dependency crosses
repositories. The copy in this repository is the canonical template: change it
here, then copy it into each repository.

The scan checks only the commits a push or pull request adds. A manual run scans
the working tree. A repository with known synthetic fixtures can add a
`.gitleaks.toml`; the workflow passes it automatically.

## Repository checklist

Every repository that ships code should have:

- a `LICENSE` that matches its release posture;
- a `SECURITY.md` or the organisation default;
- a `.github/dependabot.yml` covering every ecosystem in the repository;
- CI on `[self-hosted, linux, x64]` runners, with actions pinned to a commit SHA;
- a branch protection rule or ruleset requiring the CI check and one human
  review before merge.
