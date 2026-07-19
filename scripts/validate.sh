#!/usr/bin/env bash
#
# validate.sh - Stage 1 of the pipeline.
# Confirms every Suricata rule file loads without error. This is a syntax/config
# gate: it does NOT prove a rule detects anything, only that it is well-formed.
#
# Runs identically on your laptop and in CI. Run it locally before you push.
set -euo pipefail

RULES="rules/suricata/local.rules"
LOGDIR="$(mktemp -d)"

echo "[validate] checking ${RULES} ..."
suricata -T -S "${RULES}" -l "${LOGDIR}"
echo "[validate] OK - rules loaded cleanly"
