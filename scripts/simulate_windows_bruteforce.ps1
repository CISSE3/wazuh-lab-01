# LAB ONLY — run on YOUR OWN Windows VM in an elevated PowerShell.
# Generates failed network (type 3, NTLM) logons against the local host:
#   Event 4625 -> Wazuh rule 60122, correlated into rule 60204 (T1110).
# WARNING: Windows 11 locks a VALID account after ~10 failures (default policy).
#          Replace $realUser with a throwaway local account, or wait 10 min to unlock.
$realUser = "ousma"
for ($i = 1; $i -le 12; $i++) {
    net use \\127.0.0.1\IPC$ /user:fakeuser  "WrongPass$i" 2>$null   # SubStatus 0xC0000064 (no such user)
    net use \\127.0.0.1\IPC$ /user:$realUser "WrongPass$i" 2>$null   # SubStatus 0xC000006A (bad password)
    Start-Sleep 2
}
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625} -MaxEvents 5 |
    Format-Table TimeCreated, Id -AutoSize
Write-Host "Check Wazuh > Threat Hunting > Events:  agent.name: endpoint-01 and rule.id: 60204"
