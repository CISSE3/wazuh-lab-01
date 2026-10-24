# Incident note — IR-2026-001 (Windows brute force)

| | |
|---|---|
| **What** | Wazuh rule **60204** "Multiple Windows Logon Failures" (level 10), MITRE **T1110** Brute Force. 23 × Event 4625 (rule 60122) in ~1 min, NTLM, logon type 3 (network/SMB). |
| **When** | 24 Oct 2026, 19:08:27 – 19:09:09 CEST |
| **Source** | 127.0.0.1 (local origin) |
| **Host** | endpoint-01 (172.16.134.130, Windows 11 Pro, agent 001) |
| **Targets** | `ousma` — valid account (SubStatus 0xC000006A), subsequently locked out (T1531); `fakeuser` — non-existent account |
| **Verdict** | **True positive — authorised lab simulation.** No authentication success (4624) after the failures → attempt, not compromise. |
| **Actions (prod)** | Identify the local process behind the 127.0.0.1 logons (malware / lateral-movement check); reset and unlock `ousma`; review lockout policy; restrict NTLM. |

## Analyst reasoning
- **Source = 127.0.0.1** → the attempts originate on the endpoint itself, so in a real case something is already running there. Higher priority than an external attacker.
- **SubStatus 0xC000006A** → the username exists; the attacker has a valid account name.
- **Brute force + 0 successes** = attempt. **Brute force followed by a 4624** = likely compromise — escalate.
- **Clock skew:** the endpoint clock was 2 h off (FIM `mtime` vs alert timestamp). Verify time sync before building a timeline.

![60204 details](../screenshots/04c-bruteforce-60204-details.png)
