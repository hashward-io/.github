# Contributing

These defaults apply to every repository in the organisation unless that
repository has its own `CONTRIBUTING.md`.

## Before you start

- Open an issue for anything that changes behaviour. For a security fix, follow
  [`SECURITY.md`](SECURITY.md) instead of opening a public issue.
- Branch from `main`. Keep one logical change per pull request.

## Checks

Run the checks the repository already defines; do not add a parallel set.

| Repository type | Command |
| --- | --- |
| TypeScript monorepo | `pnpm install --frozen-lockfile && pnpm lint && pnpm typecheck && pnpm test` |
| Python | `uv sync --frozen && uv run ruff check . && uv run ruff format --check . && uv run mypy . && uv run pytest` |
| Static site | `pnpm check:landing` or the repository's own check script |

A pull request is ready when every check passes on the head commit and the diff
contains no generated output.

## Secrets

- Only `.env.example` is committed. Real values live in the environment or in
  GitHub secrets.
- The organisation runs a secret scan on every push and pull request. A finding
  fails the build. If a credential reaches a commit, rotate it first, then
  rewrite history.
- Do not add large binaries or datasets. They belong in the external store and
  are referenced by hash.

## Commits and review

- Commit subject: imperative, scoped, ≤ 72 characters
  (`fix(exec_poc): pass the real exit status`).
- Every change to `main` is reviewed by a human other than the author. A commit
  authored by an agent or a bot still needs a named human reviewer.
- Security-sensitive changes (sandbox, policy engine, credential handling,
  release workflows) require a second human review before merge.
- Never force-push a branch that is under review.

## Reporting

State what you ran and what it returned. "Tests pass" without the command and
the result is not evidence.
