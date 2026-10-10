# 02 — Agent enrolment

Register a Linux agent so it reports events to the manager.

## 1. Install the agent package (on the agent VM)

Replace `<MANAGER_IP>` with your manager's address. For the single-VM variant
use `127.0.0.1`.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh  # not needed if using the repo method below

# Add the Wazuh APT repo and install the agent:
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring \
  --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && \
  sudo chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | \
  sudo tee /etc/apt/sources.list.d/wazuh.list

sudo apt update

sudo WAZUH_MANAGER="<MANAGER_IP>" WAZUH_AGENT_NAME="lab-agent-01" apt install wazuh-agent -y
```

The `WAZUH_MANAGER` and `WAZUH_AGENT_NAME` environment variables pre-configure
the agent during install, so it knows where to enrol.

## 2. Enable and start the agent

```bash
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
sudo systemctl status wazuh-agent      # expect: active (running)
```

The agent auto-enrols with the manager over TCP **1515** on first start, then
sends events over TCP **1514**.

## 3. Confirm registration on the manager

On the **manager** VM:

```bash
sudo /var/ossec/bin/manage_agents -l
```

You should see `lab-agent-01` with status **Active**.

Or in the dashboard: **Agents** → the agent appears with a green *Active* badge.

## 4. If auto-enrolment fails — register manually

On the manager:

```bash
sudo /var/ossec/bin/manage_agents
# Press A → add agent → name it lab-agent-01 → accept the IP
# Press E → extract its key, copy the long string
```

On the agent:

```bash
sudo /var/ossec/bin/manage_agents
# Press I → import key → paste the string
sudo systemctl restart wazuh-agent
```

## Checkpoint

- [ ] Agent shows **Active** in `manage_agents -l` and in the dashboard.
- [ ] Firewall allows TCP 1514 and 1515 from agent → manager.

Next → [03 — File Integrity Monitoring](03-fim.md)
