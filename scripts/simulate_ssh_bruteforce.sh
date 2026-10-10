#!/usr/bin/env bash
#
# simulate_ssh_bruteforce.sh — generate failed SSH logins to trip Wazuh's
# brute-force detection (rule 5712) in the lab.
#
# ⚠️  LAB USE ONLY. This targets localhost / your own VM. Running credential
#     guessing against machines you do not own is illegal.
#
# Run on the AGENT:  bash scripts/simulate_ssh_bruteforce.sh
#
set -uo pipefail

TARGET="127.0.0.1"
BAD_USER="baduser"
ATTEMPTS="${1:-12}"     # override: bash simulate_ssh_bruteforce.sh 20

echo "[*] Firing ${ATTEMPTS} failed SSH logins at ${TARGET} as '${BAD_USER}'..."
echo "    (You should see rule 5712 'SSH brute force' on the manager.)"

if command -v sshpass >/dev/null 2>&1; then
  # Automated wrong-password attempts — cleanest signal.
  for i in $(seq 1 "${ATTEMPTS}"); do
    sshpass -p "wrongpassword${i}" \
      ssh -o StrictHostKeyChecking=no \
          -o PreferredAuthentications=password \
          -o PubkeyAuthentication=no \
          -o ConnectTimeout=3 \
          "${BAD_USER}@${TARGET}" "true" 2>/dev/null
    echo "    attempt ${i}/${ATTEMPTS}"
  done
else
  echo "[!] 'sshpass' not found. Install it for automated attempts:"
  echo "      sudo apt install sshpass -y"
  echo "[*] Falling back to interactive ssh — press Enter / type a wrong password each time."
  for i in $(seq 1 "${ATTEMPTS}"); do
    ssh -o StrictHostKeyChecking=no \
        -o PreferredAuthentications=password \
        -o PubkeyAuthentication=no \
        -o ConnectTimeout=3 \
        "${BAD_USER}@${TARGET}" "true" 2>/dev/null
    echo "    attempt ${i}/${ATTEMPTS}"
  done
fi

echo "[+] Done. Verify on the manager:"
echo "    sudo grep -A8 '5712' /var/ossec/logs/alerts/alerts.log | tail -n 20"
