#!/usr/bin/env bash
#
# deploy.sh - Stage 3 of the pipeline.
#
# STATUS: NOT WIRED TO A REAL SENSOR YET. This is an honest stub.
# Do not claim "deploys" on a resume until the real path below is implemented
# and you have watched it push a rule to a live sensor.
#
# The intended real implementation (uncomment/fill when you have a sensor):
#   1. Copy validated rules to the sensor:
#        rsync -az rules/suricata/local.rules "${SENSOR_USER}@${SENSOR_HOST}:/etc/suricata/rules/"
#   2. Trigger a live rule reload without dropping traffic:
#        ssh "${SENSOR_USER}@${SENSOR_HOST}" 'suricatasc -c reload-rules'
#
# Secrets (SENSOR_HOST, SSH key) would come from GitHub Actions secrets, never
# committed to the repo.
set -euo pipefail

echo "[deploy] STUB: rules validated and tested, but no live sensor configured."
echo "[deploy] Wire up rsync + suricatasc reload here when a sensor exists."
