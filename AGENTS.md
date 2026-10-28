# Agent guide (adh-iac-local)

Shared local infra for programme **ADH**: Postgres (pgvector/pg16), Redis 7, LiteLLM, and compose wiring for Buzz + Hermes.

Do not add a second Postgres/Redis cluster. RealWorld joins the `adh_local` network and uses databases on this Postgres.

Pin: [`.harness-pin.yaml`](.harness-pin.yaml) (`profile: compose-local`). No app constitution.

Re-sync after clone: `launchpad --client adh apply-harness --repo adh-iac-local --apply`
