# 03 — File Integrity Monitoring (FIM)

Wazuh's FIM module (`syscheck`) watches directories and alerts on file
create / modify / delete events. We'll watch a dedicated lab directory so the
alerts are easy to spot.

## 1. Add a watched directory on the agent

Edit `/var/ossec/etc/ossec.conf` on the **agent** and add a `<directories>`
entry inside the existing `<syscheck>` block. The ready-made snippet is in
[`config/agent/ossec.conf.snippet`](../config/agent/ossec.conf.snippet):

```xml
<syscheck>
  <!-- ...existing entries... -->

  <!-- Lab: watch a test directory in near real time -->
  <directories check_all="yes" realtime="yes" report_changes="yes">/root/fim-lab</directories>
</syscheck>
```

- `realtime="yes"` → alerts fire within seconds (inotify), not just on the scan cycle.
- `report_changes="yes"` → the alert includes a diff of what changed.
- `check_all="yes"` → checks size, permissions, owner, and content hashes (MD5/SHA1/SHA256).

Create the directory and restart:

```bash
sudo mkdir -p /root/fim-lab
sudo systemctl restart wazuh-agent
```

## 2. Trigger FIM events

Use the helper script (copy it to the agent first):

```bash
sudo bash scripts/fim_test.sh
```

It creates, modifies, then deletes a file under `/root/fim-lab`, producing three
distinct FIM alerts.

Manual equivalent:

```bash
echo "secret config v1" | sudo tee /root/fim-lab/secret.conf   # added
echo "tampered!"        | sudo tee -a /root/fim-lab/secret.conf # modified
sudo rm /root/fim-lab/secret.conf                              # deleted
```

## 3. See the alerts

**Dashboard:** go to **Threat Hunting** (or **Security events**), filter on
`rule.groups:syscheck`, or search the agent. Look for:

| Event | Rule ID | Description |
|---|---|---|
| File added | `554` | File added to the system |
| File modified | `550` | Integrity checksum changed |
| File deleted | `553` | File deleted |

**CLI (on the manager):** tail the alert log:

```bash
sudo tail -f /var/ossec/logs/alerts/alerts.log | grep -A6 syscheck
```

The `report_changes` diff shows the before/after content for modifications.

## Why this matters

FIM is a core control for detecting tampering with system binaries, config
files, and web content — it maps to PCI-DSS 11.5 and is a standard SOC
detection. Watching `/etc`, `/bin`, `/sbin`, and web roots in production is
common; here we isolate `/root/fim-lab` so the signal is clean.

## Checkpoint

- [ ] Add/modify/delete each produce an alert (rules 554 / 550 / 553).
- [ ] The modify alert contains a content diff.

Next → [04 — SSH brute-force detection](04-ssh-bruteforce.md)
