# FIM test for the Windows endpoint — run in an elevated PowerShell.
# Wait ~1 minute after Restart-Service WazuhSvc before running (agent baseline).
$dir  = "$env:USERPROFILE\secret-docs"
$file = Join-Path $dir "payroll.txt"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

Set-Content $file "salary list v1"   # -> rule 554 (added)
Start-Sleep 10
Add-Content $file "salary list v2"   # -> rule 550 (modified, with diff)
Start-Sleep 10
Remove-Item $file                    # -> rule 553 (deleted)
Write-Host "Done. Check Wazuh > File Integrity Monitoring > Events."
