# adh-iac-local

Shared local infra for [ADH](https://github.com/drivestream-lab/adh-meta).

One cluster. Separate databases, not separate servers. ADH owns host ports **5432**, **6379**, and **4000**.

| Service | Image / source | Notes |
| --- | --- | --- |
| postgres | `pgvector/pgvector:pg16` | DBs: `litellm`, `buzz`, `hermes`, `ledger`, `realworld` |
| redis | `redis:7-alpine` | LiteLLM cache + Buzz + Hermes |
| litellm | `ghcr.io/berriai/litellm-database:main-stable` | `:4000→8000`, UI, OpenRouter via LiteLLM UI |
| buzz | built from `adh` (Phase D) | Full chat product |
| hermes | built from `adh` (Phase E) | PM + after-PR brain |

Network: `adh_local`. `realworld-local` joins this network later; it does not start a second Postgres.

## Start

```bash
cp .env.example .env   # first time only
make infra-up
```

Health: Postgres `:5432`, Redis `:6379`, LiteLLM UI http://localhost:4000/ui (login `adh-admin` / `adh-admin` unless you changed `.env`).

Add OpenRouter credentials and models in the LiteLLM UI. Do not put provider keys in git.

Stop (keep data): `make infra-down`. Destroy volumes: `make down-clean`.

Org: [drivestream-lab](https://github.com/drivestream-lab). Board: [ADH](https://github.com/orgs/drivestream-lab/projects/4).
