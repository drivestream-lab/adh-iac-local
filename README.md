# adh-iac-local

Shared local infra for [ADH](https://github.com/drivestream-lab/adh-meta).

One cluster. Separate databases, not separate servers.

| Service | Image / source | Notes |
| --- | --- | --- |
| postgres | `pgvector/pgvector:pg16` | DBs: `litellm`, `buzz`, `hermes`, `ledger`, `realworld` |
| redis | `redis:7-alpine` | LiteLLM cache + Buzz + Hermes |
| litellm | `ghcr.io/berriai/litellm-database:main-stable` | `:4000→8000`, UI, OpenRouter via LiteLLM |
| buzz | built from `adh` | Full chat product |
| hermes | built from `adh` | PM + after-PR brain |

Compose files land in Phase C (`make infra-up`). Until then this repo holds harness, gates, and the pin.

Org: [drivestream-lab](https://github.com/drivestream-lab). Board: [ADH](https://github.com/orgs/drivestream-lab/projects/4).
