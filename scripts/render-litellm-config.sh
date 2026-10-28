#!/usr/bin/env bash
# LiteLLM is UI-first: config.yaml is proxy/infra only (empty model_list).
# This script verifies the committed config before compose up.
# Provider keys and models are added in http://localhost:4000/ui — not here.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/config/litellm/config.yaml"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: missing $CONFIG" >&2
  exit 1
fi

if ! grep -q 'model_list: \[\]' "$CONFIG"; then
  echo "WARN: $CONFIG model_list is not empty; UI-first expects models in Postgres." >&2
fi

echo "LiteLLM config ready (UI-first). Add OpenRouter models at http://localhost:4000/ui"
