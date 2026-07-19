#!/usr/bin/env bash
#
# test.sh - Stage 2 of the pipeline. THE part most people skip.
# Runs each rule against known traffic and asserts behavior:
#   - malicious.pcap MUST raise the alert (true positive)
#   - benign.pcap    MUST NOT raise it   (false positive check)
#
# Exit non-zero on any mismatch so CI fails loudly.
set -euo pipefail

RULES="rules/suricata/local.rules"
SID="1000001"

# count_alerts <pcap> -> number of alerts for $SID
count_alerts () {
  local pcap="$1"
  local out
  out="$(mktemp -d)"
  suricata -r "${pcap}" -S "${RULES}" -l "${out}" >/dev/null 2>&1
  # grep -c exits 1 when count is 0; `|| true` keeps set -e happy.
  grep -c "\"signature_id\":${SID}" "${out}/eve.json" 2>/dev/null || true
}

fail=0

mal="$(count_alerts tests/pcaps/malicious.pcap)"
if [ "${mal:-0}" -ge 1 ]; then
  echo "[test] PASS  malicious.pcap fired the rule (${mal} alert/s)"
else
  echo "[test] FAIL  malicious.pcap did NOT fire the rule (expected >=1, got ${mal:-0})"
  fail=1
fi

ben="$(count_alerts tests/pcaps/benign.pcap)"
if [ "${ben:-0}" -eq 0 ]; then
  echo "[test] PASS  benign.pcap stayed quiet (0 alerts)"
else
  echo "[test] FAIL  benign.pcap raised a false positive (expected 0, got ${ben})"
  fail=1
fi

if [ "${fail}" -ne 0 ]; then
  echo "[test] one or more assertions failed"
  exit 1
fi
echo "[test] OK - all detection assertions passed"
