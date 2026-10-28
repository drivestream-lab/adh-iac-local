# LiteLLM Admin UI (ADH local) — UI-first

Models and provider API keys are managed in the **Admin UI** (Postgres).
`config.yaml` only configures the proxy: Redis cache, `drop_params`, timeouts, master key.

API requests must send `Authorization: Bearer <LITELLM_MASTER_KEY>` (or a virtual key from the UI).

## Start

```bash
# From adh-iac-local/
make infra-up
```

Open http://localhost:4000/ui — login with `UI_USERNAME` / `UI_PASSWORD` from `.env`
(defaults: `adh-admin` / `adh-admin`).

First boot: allow ~60s for Prisma migrations (`litellm-database` image).

## Add OpenRouter (you)

1. **Models → LLM Credentials → Add Credential** — provider OpenRouter, paste the API key.
2. **Models → Add Model** — pick Existing Credentials. Client-facing name is what Hermes will call.

No proxy restart required (`STORE_MODEL_IN_DB=True`). Do not put provider keys in git.

## API

```bash
export LITELLM_MASTER_KEY=sk-adh-local-master   # from .env

curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY"
```

In Docker network: `http://litellm:8000/v1` (same Bearer). Cursor CLI does not use LiteLLM.
