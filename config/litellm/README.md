# LiteLLM (ADH local)

Hermes calls LiteLLM. Cursor CLI does not.

Client aliases (Bearer `LITELLM_MASTER_KEY`):

| Alias | OpenRouter model |
| --- | --- |
| `glm` | `z-ai/glm-5.3-flash` |
| `qwen` | `qwen/qwen3.8-max-0902` |
| `kimi-k3` | `moonshotai/kimi-k3` |

`OPENROUTER_API_KEY` lives in local `.env` (gitignored), passed into the container.

## Start

```bash
cp .env.example .env   # first time; paste OPENROUTER_API_KEY
make infra-up
```

UI: http://localhost:4000/ui (`adh-admin` / `adh-admin`).

## Call

```bash
export LITELLM_MASTER_KEY=sk-adh-local-master

curl -s http://localhost:4000/v1/models \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY"

curl -s http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"glm","messages":[{"role":"user","content":"hi"}],"max_tokens":32}'
```

In Docker network: `http://litellm:8000/v1`.
