# ADH local infra — postgres, redis, litellm on network adh_local
# Buzz + Hermes compose join later (Phases D/E). RealWorld joins as external.

.PHONY: help infra-up infra-down infra-logs infra-ps infra-health buzz-up buzz-down down down-clean

ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
LIB := $(ROOT)scripts/compose-lib.sh

help:
	@echo "ADH local infra (postgres redis litellm)"
	@echo ""
	@echo "  make infra-up       Start shared cluster; wait until healthy"
	@echo "  make infra-down     Stop containers (keep volumes)"
	@echo "  make infra-logs     Follow logs"
	@echo "  make infra-ps       Status"
	@echo "  make infra-health   Probe :5432 :6379 :4000"
	@echo "  make buzz-up        Start Buzz on the shared cluster (builds adh)"
	@echo "  make buzz-down      Stop Buzz (infra stays up)"
	@echo "  make down           Alias for infra-down (also stops Buzz)"
	@echo "  make down-clean     Destroy containers AND volumes (DESTRUCTIVE)"

infra-up:
	@bash -c 'source "$(LIB)" && ensure_env_file && ensure_shared_resources'
	@bash "$(ROOT)scripts/render-litellm-config.sh"
	@bash -c 'source "$(LIB)" && compose_infra up -d && wait_infra_core'
	@bash "$(ROOT)scripts/ensure-databases.sh"
	@$(MAKE) infra-health
	@echo "Infra up. Network: adh_local  UI: http://localhost:4000/ui"

infra-down:
	@bash -c 'source "$(LIB)" && compose_buzz down || true'
	@bash -c 'source "$(LIB)" && compose_infra down'

buzz-up: infra-up
	@bash -c 'source "$(LIB)" && compose_buzz up -d --build buzz'
	@bash -c 'source "$(LIB)" && wait_container_healthy adh-buzz 180'
	@curl -sf http://localhost:8080/health >/dev/null && echo "buzz: ok"
	@echo "Buzz UI: http://localhost:8080/buzz/"

buzz-down:
	@bash -c 'source "$(LIB)" && compose_buzz stop buzz && compose_buzz rm -f buzz'

down: infra-down

infra-logs:
	@bash -c 'source "$(LIB)" && compose_infra logs -f'

infra-ps:
	@bash -c 'source "$(LIB)" && compose_infra ps -a'

infra-health:
	@bash -c 'source "$(LIB)" && \
	  compose_infra exec -T postgres pg_isready -U "$${POSTGRES_USER:-adh}" && \
	  compose_infra exec -T redis redis-cli ping && \
	  curl -sf http://localhost:4000/health/liveliness >/dev/null && echo "litellm: ok" && \
	  echo "UI: http://localhost:4000/ui"'

down-clean:
	@echo "WARNING: removing containers AND volumes (postgres/redis data)."
	@bash -c 'source "$(LIB)" && compose_infra down -v'
