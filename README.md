# detection-as-code

A CI/CD pipeline for network and (later) SIEM detections. Rules live in version
control as the source of truth. On every push, CI validates them, tests them
against known traffic, and (eventually) deploys them to a sensor.

```
detection-as-code/
├── .github/
│   └── workflows/
│       └── ci.yml
├── rules/
│   ├── suricata/        ← build this first
│   └── sigma/           ← empty seam for Splunk later
├── tests/
│   └── pcaps/           ← test traffic (logs/ seam added later)
├── scripts/
│   ├── validate.sh
│   └── deploy.sh
├── ai/                  ← build-time AI helpers (empty seam)
├── README.md
└── .gitignore
```


## Status

In progress. Honest current state:

| Stage    | Suricata (IDS)                          | Sigma (SIEM)        |
| -------- | --------------------------------------- | ------------------- |
| validate | done: rules load-checked with suricata -T | not started (seam)  |
| test     | done: fires on malicious, quiet on benign | not started (seam)  |
| deploy   | stub only, not wired to a live sensor   | not started (seam)  |

## Why it is built this way

Rules are the source of truth: you edit the actual rule file, and what you see
is what runs. No framework hides the mechanics.

Test logic lives in `scripts/`, not inside the workflow YAML, so the exact same
checks run on a laptop (`bash scripts/validate.sh`) and in CI. Test before you
push.

The test stage is the point. Anyone can lint a rule. This proves each rule
fires on a known-bad sample and stays silent on a benign one, which is what
separates a detection that works from a detection that merely parses.

## Layout

```
rules/suricata/   Suricata rules (built)
rules/sigma/      Sigma rules -> compiled to SPL for Splunk (seam, week two)
tests/pcaps/      Traffic fixtures for Suricata (built)
tests/logs/       Log fixtures for Sigma (seam, week two)
tests/generate_pcaps.py   Reproducible source for the pcap fixtures
scripts/          validate | test | deploy stage logic
ai/               Build-time AI helpers, human-in-the-loop (seam)
.github/workflows/ci.yml   The pipeline
```

## AI roadmap (build-time, human-in-the-loop)

Planned helpers that operate on rules and always land output in a pull request a
human reviews and merges. Nothing auto-merges. Candidates: draft a Sigma rule
from a plain-English description | review a rule against repo conventions |
generate additional test fixtures | map detections to MITRE ATT&CK.

## Run it locally

```
python3 tests/generate_pcaps.py
bash scripts/validate.sh
bash scripts/test.sh
```

## Target (not yet fully earned)

The resume bullet this repo is being built toward. Each clause becomes true as
the matching capability lands:

> Built a detection-as-code CI/CD pipeline (GitHub Actions) that validates,
> tests, and deploys IDS and SIEM detections, with automated testing that fires
> rules against known-malicious and benign samples to verify true-positive and
> false-positive behavior before deployment.

Today you can honestly claim the validate and test halves for Suricata (IDS).
Add "deploys" when `deploy.sh` pushes to a real sensor. Add "SIEM" when the
Sigma path is real.
