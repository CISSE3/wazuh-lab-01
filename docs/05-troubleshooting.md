# 05 — Troubleshooting

## Agent shows "Never connected" / "Disconnected"

- Confirm the manager IP in the agent config:
  ```bash
  sudo grep -A2 "<server>" /var/ossec/etc/ossec.conf
  ```
- Open the ports on the manager (UFW example):
  ```bash
  sudo ufw allow 1514/tcp
  sudo ufw allow 1515/tcp
  ```
- Test reachability from the agent:
  ```bash
  nc -vz <MANAGER_IP> 1514
  ```
- Re-register the key manually (see [02](02-agent-enrolment.md) step 4).

## Dashboard won't load

```bash
sudo systemctl status wazuh-dashboard wazuh-indexer wazuh-manager
sudo journalctl -u wazuh-indexer --no-pager | tail -n 40
```

The indexer needs enough RAM — if it's OOM-killed, give the VM 4 GB and set
`vm.max_map_count`:

```bash
sudo sysctl -w vm.max_map_count=262144
```

## No FIM alerts

- Confirm the watched path exists and is inside a `<syscheck>` `<directories>` entry.
- `realtime="yes"` needs inotify; after editing config, restart the agent.
- Force a scan:
  ```bash
  sudo /var/ossec/bin/agent_control -r -a   # on the manager
  ```

## No brute-force alert

- Verify the auth log path for your distro (`/var/log/auth.log` on Ubuntu,
  `/var/log/secure` on RHEL) is in a `<localfile>` block on the agent.
- Check events are arriving:
  ```bash
  sudo tail -f /var/ossec/logs/archives/archives.log   # needs <logall> enabled, optional
  sudo tail -f /var/ossec/logs/alerts/alerts.log
  ```
- The frequency rule needs enough failures *within the timeframe* — run the
  script again back-to-back.

## Useful log locations

| Path | What |
|---|---|
| `/var/ossec/logs/alerts/alerts.log` | Human-readable alerts (manager) |
| `/var/ossec/logs/alerts/alerts.json` | JSON alerts (manager) |
| `/var/ossec/logs/ossec.log` | Agent/manager daemon log |

## Reset the whole lab

Uninstall the central components and start over:

```bash
sudo bash ./wazuh-install.sh -u
```
