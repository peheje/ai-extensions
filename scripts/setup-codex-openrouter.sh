#!/usr/bin/env bash
set -euo pipefail

START_MARKER="# >>> codex-openrouter >>>"
END_MARKER="# <<< codex-openrouter <<<"
BASHRC="${HOME}/.bashrc"
CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
PROFILE_NAME="openrouter"
PROFILE_FILE="${CODEX_HOME}/${PROFILE_NAME}.config.toml"
BACKUP="${BASHRC}.bak.$(date +%Y%m%d%H%M%S)"

BASE_URL="https://openrouter.ai/api/v1"
DEFAULT_MODEL="openrouter/auto"

log() {
  printf '[codex-openrouter-setup] %s\n' "$*"
}

fail() {
  printf '[codex-openrouter-setup] ERROR: %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

shell_quote() {
  printf '%q' "$1"
}

log "Codex CLI + OpenRouter setup"
log "Base URL: ${BASE_URL}"
printf '\n'

if ! command_exists codex; then
  fail "codex command not found. Install Codex CLI first, then rerun this script."
fi

if [[ ! -f "${BASHRC}" ]]; then
  log "Creating ${BASHRC}"
  touch "${BASHRC}"
fi

mkdir -p "${CODEX_HOME}"

printf 'Enter your OpenRouter API key: '
IFS= read -rs OPENROUTER_KEY
printf '\n'

if [[ -z "${OPENROUTER_KEY}" ]]; then
  fail "OpenRouter API key cannot be empty."
fi

if [[ "${OPENROUTER_KEY}" == *$'\n'* || "${OPENROUTER_KEY}" == *$'\r'* ]]; then
  fail "OpenRouter API key contains a newline. Paste only the raw key."
fi

printf 'OpenRouter model [%s]: ' "${DEFAULT_MODEL}"
IFS= read -r MODEL
MODEL="${MODEL:-${DEFAULT_MODEL}}"

if [[ -z "${MODEL}" ]]; then
  fail "Model cannot be empty."
fi

log "Writing ${PROFILE_FILE}"
cat > "${PROFILE_FILE}" <<EOF
model = "${MODEL}"
model_provider = "openrouter"

# Codex 0.133+ requires the Responses wire API for custom model providers.
# OpenRouter exposes this at /api/v1/responses, currently marked beta by OpenRouter.
# Leave reasoning off by default because support varies by routed model/provider.
model_reasoning_effort = "none"

[model_providers.openrouter]
name = "OpenRouter"
base_url = "${BASE_URL}"
env_key = "OPENROUTER_API_KEY"
wire_api = "responses"
http_headers = { "HTTP-Referer" = "https://github.com/openai/codex", "X-Title" = "Codex CLI via OpenRouter" }
EOF
chmod 600 "${PROFILE_FILE}"

log "Backing up ${BASHRC} to ${BACKUP}"
cp "${BASHRC}" "${BACKUP}"

tmp_file="$(mktemp)"
awk -v start="${START_MARKER}" -v end="${END_MARKER}" '
  $0 == start { skip = 1; next }
  $0 == end { skip = 0; next }
  skip != 1 { print }
' "${BASHRC}" > "${tmp_file}"

quoted_key="$(shell_quote "${OPENROUTER_KEY}")"

cat >> "${tmp_file}" <<EOF

${START_MARKER}
export OPENROUTER_API_KEY=${quoted_key}

# Normal Codex remains unchanged:
#   codex
#
# OpenRouter Codex uses ${PROFILE_FILE}:
codex-openrouter() {
  codex --profile-v2 ${PROFILE_NAME} "\$@"
}

codex-or() {
  codex-openrouter "\$@"
}

# Explicit no-op helper for readability when switching back.
codex-normal() {
  codex "\$@"
}
${END_MARKER}
EOF

mv "${tmp_file}" "${BASHRC}"
chmod 600 "${BASHRC}"
unset OPENROUTER_KEY quoted_key

log "Updated ${BASHRC}"
log "Codex version: $(codex --version 2>/dev/null || printf 'unknown')"
printf '\n'

log "Next commands:"
printf '  source ~/.bashrc\n'
printf '  codex-openrouter\n'
printf '\n'

log "Switching:"
printf '  codex              # normal ChatGPT subscription / existing config\n'
printf '  codex-openrouter   # OpenRouter profile\n'
printf '  codex-or           # short alias for OpenRouter profile\n'
printf '\n'

log "To change OpenRouter model later, edit ${PROFILE_FILE} or rerun this script."
