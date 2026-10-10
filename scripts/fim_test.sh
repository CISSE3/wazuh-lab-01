#!/usr/bin/env bash
#
# fim_test.sh — generate File Integrity Monitoring events for the Wazuh lab.
# Creates, modifies, then deletes a file under the watched directory so you can
# observe rules 554 (added), 550 (modified), and 553 (deleted).
#
# Run on the AGENT:  sudo bash scripts/fim_test.sh
#
set -euo pipefail

WATCH_DIR="/root/fim-lab"
TARGET="${WATCH_DIR}/secret.conf"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root (sudo), since ${WATCH_DIR} is root-owned." >&2
  exit 1
fi

mkdir -p "${WATCH_DIR}"

echo "[*] Creating ${TARGET} (expect FIM rule 554: file added)"
echo "db_password=initial-value-v1" > "${TARGET}"
sleep 8

echo "[*] Modifying ${TARGET} (expect FIM rule 550: integrity checksum changed)"
echo "db_password=TAMPERED-by-attacker" >> "${TARGET}"
sleep 8

echo "[*] Deleting ${TARGET} (expect FIM rule 553: file deleted)"
rm -f "${TARGET}"
sleep 2

echo "[+] Done. Check the dashboard (rule.groups:syscheck) or on the manager:"
echo "    sudo tail -f /var/ossec/logs/alerts/alerts.log | grep -A6 syscheck"
