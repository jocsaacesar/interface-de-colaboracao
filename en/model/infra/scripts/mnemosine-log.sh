#!/bin/bash
# Logging utility for skills
# Usage: mnemosine-log.sh <skill> <project> <status> <duration> <description>
#
# Examples:
#   mnemosine-log.sh audit-php my-app COMPLETED 45s "12 files, 3 ERROR violations"
#   mnemosine-log.sh start - COMPLETED 2s "Session started, 4 memories loaded"
#   mnemosine-log.sh audit-security my-app ERROR 12s "Failed to read file"
#
# Configuration:
#   MNEMOSINE_LOGS_DIR — log directory (default: ../../../logs relative to script)

LOGS_DIR="${MNEMOSINE_LOGS_DIR:-$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")/logs}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

SKILL="${1:?Skill is required}"
PROJETO="${2:--}"
STATUS="${3:?Status is required}"
DURACAO="${4:--}"
DESCRICAO="${5:?Description is required}"

ENTRADA="[${TIMESTAMP}] [${SKILL}] [${PROJETO}] [${STATUS}] [${DURACAO}] — ${DESCRICAO}"

# Create directories if they don't exist
mkdir -p "${LOGS_DIR}/skills" "${LOGS_DIR}/projetos"

# General log
echo "$ENTRADA" >> "${LOGS_DIR}/atividade.log"

# Per-skill log
echo "$ENTRADA" >> "${LOGS_DIR}/skills/${SKILL}.log"

# Per-project log (if not global)
if [ "$PROJETO" != "-" ]; then
    echo "$ENTRADA" >> "${LOGS_DIR}/projetos/${PROJETO}.log"
fi
