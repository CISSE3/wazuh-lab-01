# Lab 1 — Wazuh SIEM: Install, Agent Enrolment, FIM & SSH Brute-Force Detection

A hands-on home lab that stands up a **Wazuh** SIEM, enrols an agent, turns on
**File Integrity Monitoring (FIM)**, and detects an **SSH brute-force attack** —
end to end, with reproducible configs and verification steps.

> Built as part of an MSc Cybersecurity portfolio. Everything here runs on free,
> open-source software inside two local VMs.

---

## What this lab demonstrates

| Capability | How it's shown |
|---|---|
| SIEM deployment | Wazuh 4.14 central components via the official install assistant |
| Agent enrolment | Linux agent registered to the manager and reporting |
| File Integrity Monitoring | Alerts on create/modify/delete under a watched directory |
| Brute-force detection | SSH authentication-failure correlation fires rule `5712` |
| Analyst workflow | Generate the attack, read the alert, explain the rule |

---

## Architecture

```
  ┌─────────────────────────┐          ┌─────────────────────────┐
  │   wazuh-manager (VM 1)   │          │   wazuh-agent (VM 2)     │
  │                         │          │                         │
  │  • Wazuh manager        │◄────1514─┤  • Wazuh agent          │
  │  • Wazuh indexer        │   /1515  │  • OpenSSH server       │
  │  • Wazuh dashboard      │          │  • /etc watched (FIM)   │
  │  Ubuntu 22.04, 4 GB RAM │          │  Ubuntu 22.04, 2 GB RAM │
  └─────────────────────────┘          └─────────────────────────┘
        443 (dashboard UI)
```

A single-VM variant (agent on the manager host itself) also works if you only
have one machine — see [`docs/01-install.md`](docs/01-install.md).

---

## Repository layout

```
wazuh-lab-01/
├── README.md                     ← you are here
├── docs/
│   ├── 01-install.md             ← install the manager + dashboard
│   ├── 02-agent-enrolment.md     ← register and verify the agent
│   ├── 03-fim.md                 ← file integrity monitoring
│   ├── 04-ssh-bruteforce.md      ← brute-force detection + testing
│   └── 05-troubleshooting.md     ← common issues and fixes
├── config/
│   ├── manager/
│   │   ├── ossec.conf.snippet     ← manager-side FIM / global settings
│   │   └── local_rules.xml        ← optional custom brute-force rule
│   └── agent/
│       └── ossec.conf.snippet     ← agent-side FIM block
├── scripts/
│   ├── simulate_ssh_bruteforce.sh ← generate failed SSH logins (lab only)
│   └── fim_test.sh                ← create/modify/delete a watched file
├── screenshots/                   ← drop your own evidence here
└── .gitignore
```

---

## Quick start

```bash
# On the manager VM
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

Then follow the docs in order:

1. [Install Wazuh](docs/01-install.md)
2. [Enrol the agent](docs/02-agent-enrolment.md)
3. [File Integrity Monitoring](docs/03-fim.md)
4. [SSH brute-force detection](docs/04-ssh-bruteforce.md)

---

## Requirements

- **Manager VM:** 64-bit Linux (Ubuntu 22.04 LTS recommended), 2 vCPU, **4 GB RAM**, 50 GB disk.
- **Agent VM:** any 64-bit Linux, 1 vCPU, 2 GB RAM.
- Both VMs on the same host-only / NAT network so the agent can reach the manager on TCP **1514/1515**.
- `sudo` on both machines.

---

## Safety note

The brute-force script in `scripts/` only attacks **`localhost` / your own lab VM**.
Running credential-guessing tools against systems you do not own is illegal.
Keep this lab on an isolated network.

---

## Credits & references

- Wazuh documentation — Quickstart & Agent install (v4.14): https://documentation.wazuh.com/4.14/
- Wazuh ruleset (rule `5712`, SSH brute force): shipped default rules in `/var/ossec/ruleset/rules/`

## License

MIT — see [`LICENSE`](LICENSE).
