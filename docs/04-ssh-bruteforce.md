# 04 — SSH brute-force detection

Wazuh ships rules that correlate repeated SSH authentication failures into a
single brute-force alert. We'll generate failed logins against the agent and
watch the alert fire.

## How the detection works

Wazuh reads the agent's auth log (`/var/log/auth.log` on Ubuntu). Each failed
SSH password attempt matches base rule **`5710`** (*sshd: Attempt to login using
a non-existent user*) or **`5716`** (*authentication failure*). When several of
these land from the same source within the timeframe, the **frequency** rule
**`5712`** (*sshd: brute force trying to get access to the system*) fires at a
higher severity.

```
  many 5710/5716  ──(frequency + timeframe)──►  5712  "SSH brute force"
```

## 1. Make sure SSH is running on the agent

```bash
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

Confirm the agent is tailing the auth log — `/var/ossec/etc/ossec.conf` should
contain (it does by default on Debian/Ubuntu):

```xml
<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/auth.log</location>
</localfile>
```

Restart the agent if you changed anything:

```bash
sudo systemctl restart wazuh-agent
```

## 2. Simulate the attack (lab only)

Run the helper script **on the agent**. It fires rapid failed logins against
`localhost` with a bogus user, which is enough to trip rule 5712.

```bash
bash scripts/simulate_ssh_bruteforce.sh
```

> ⚠️ This only targets `localhost`. Never run credential-guessing tools against
> machines you don't own.

Manual equivalent (no script):

```bash
for i in $(seq 1 10); do
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=3 \
      baduser@127.0.0.1 "echo hi" 2>/dev/null
done
```

It will prompt for a password each time — just press Enter or type a wrong one.
Using `sshpass` (as the script does) automates the wrong-password attempts.

## 3. See the alert

**Dashboard:** **Threat Hunting / Security events**, filter on `rule.id:5712`
or search `brute force`. You'll see one correlated alert summarising the burst,
with `rule.level` around **10**.

**CLI (manager):**

```bash
sudo grep -A8 "5712" /var/ossec/logs/alerts/alerts.log | tail -n 20
```

Expected fields: `rule.id: 5712`, `rule.description: sshd: brute force trying to
get access to the system`, the source IP (`127.0.0.1`), and the agent name.

## 4. (Optional) a custom, stricter rule

If you want to show a tuned detection, add the rule in
[`config/manager/local_rules.xml`](../config/manager/local_rules.xml) to the
manager's `/var/ossec/etc/rules/local_rules.xml`. It raises the level when the
same source fails **5 times in 90 seconds**, and demonstrates you can author
rules, not just use defaults. Restart the manager after adding it:

```bash
sudo systemctl restart wazuh-manager
```

## Checkpoint

- [ ] A burst of failed logins produces a single `5712` brute-force alert.
- [ ] The alert shows the source IP and agent, at level ~10.
- [ ] (Optional) your custom rule in `local_rules.xml` also fires.

Next → [05 — Troubleshooting](05-troubleshooting.md)
