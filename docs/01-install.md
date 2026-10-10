# 01 — Install Wazuh (manager, indexer, dashboard)

This installs all three Wazuh central components on one VM using the official
installation assistant (the "all-in-one" quickstart).

## 1. Prepare the manager VM

Ubuntu 22.04 LTS, 2 vCPU, 4 GB RAM, 50 GB disk. Update first:

```bash
sudo apt update && sudo apt upgrade -y
```

Note the VM's IP — you'll need it for the agent and the dashboard URL:

```bash
ip -4 addr show | grep inet
```

## 2. Run the install assistant

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

The `-a` flag does an all-in-one install. It takes 5–10 minutes. When it
finishes it prints the admin credentials — **copy them now**.

## 3. Retrieve credentials later if needed

Passwords are stored inside the generated tarball:

```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

The user you log in with is `admin`.

## 4. Open the dashboard

From a browser on the same network:

```
https://<MANAGER_IP>
```

Accept the self-signed certificate warning, then log in as `admin` with the
password from step 2/3. You should land on the Wazuh overview.

## 5. (Optional) stop automatic updates

Pinning the version keeps the lab reproducible:

```bash
sudo sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list
sudo apt update
```

## Single-VM variant

If you only have one machine, you can install the agent on this same host after
the central components are up — just point the agent at `127.0.0.1` in
[`02-agent-enrolment.md`](02-agent-enrolment.md). FIM and brute-force detection
work identically.

## Checkpoint

- [ ] Dashboard loads at `https://<MANAGER_IP>` and you can log in.
- [ ] `sudo systemctl status wazuh-manager` shows **active (running)**.

Next → [02 — Agent enrolment](02-agent-enrolment.md)
