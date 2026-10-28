#!/usr/bin/env bash
# Verify LiteLLM config and that OPENROUTER_API_KEY is present in .env.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/config/litellm/config.yaml"
ENV_FILE="$ROOT/.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: missing $CONFIG" >&2
  exit 1
fi

for name in glm qwen kimi-k3; do
  if ! grep -q "model_name: ${name}" "$CONFIG"; then
    echo "ERROR: $CONFIG missing alias ${name}" >&2
    exit 1
  fi
done

if [[ -f "$ENV_FILE" ]] && grep -Eq '^OPENROUTER_API_KEY=.+' "$ENV_FILE"; then
  echo "LiteLLM config ready (glm, qwen, kimi-k3 via OpenRouter)."
else
  echo "WARN: OPENROUTER_API_KEY is empty. Set it in .env to call models." >&2
fi
