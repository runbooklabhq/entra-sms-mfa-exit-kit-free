# Entra SMS MFA Exit Kit: Top 5 (free)

Microsoft retires its own SMS and voice MFA on **1 February 2027** for all users except Global Administrators and external users (internal guests included), and on **1 July 2027** for Global Administrators and external users. After the date, users whose only MFA method is SMS or voice get a blocking prompt to register a passkey. There is no opt-out for enforcement. Sources: Microsoft 365 message MC1519855 and Microsoft Learn, "Passkeys by default and retirement of Microsoft-provided SMS and voice authentication".

This kit is the first five steps as a ready-to-run project:

| File | What it is |
|---|---|
| `entra-sms-mfa-exit-kit-top-5-guide.md` | Why, steps, check, verify, licence and effort for each step |
| `entra-sms-mfa-exit-kit-top-5-jira-import.csv` | Jira Cloud import: epics + stories with parent links, priority, sprint and labels |
| `entra-sms-mfa-exit-kit-top-5-tracker.csv` | Same backlog for Planner, Azure DevOps, Excel or Linear |
| `entra-sms-mfa-exit-kit-top-5-project-plan.xlsx` | Excel project plan for teams without Jira: owner, dates, status drop-down, % complete and a progress dashboard by area and sprint |
| `entra-sms-mfa-exit-kit-top-5-readonly-checks.ps1` | Get-* only. Changes nothing. Writes `hardening-check-results.csv` and `phone-only-users.csv` |

Steps: list phone-only users · see where SMS/voice is enabled · enable passkeys · run a registration campaign · tell users in three waves.

## Run the checks
```powershell
Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns, Microsoft.Graph.Reports -Scope CurrentUser
Connect-MgGraph -Scopes AuditLog.Read.All,Policy.Read.All
./entra-sms-mfa-exit-kit-top-5-readonly-checks.ps1
```
The user registration report needs Entra ID P1 or P2 and a role such as Reports Reader, Security Reader or Global Reader. If a property name has changed in your Graph module version, the check reports an ERROR line instead of guessing.

## Next: the Complete kit
**Entra SMS MFA Exit Kit: Complete** adds 7 controls: Global Admins and external users (1 July 2027), internal guests, SSPR for phone-only users, the telephony-provider decision, the temporary opt-out check, safe helpdesk onboarding with Temporary Access Pass, and weekly tracking to zero.
→ https://runbooklab.gumroad.com/l/sms-mfa-exit-kit?utm_source=github&utm_campaign=sms-free-repo

Six-step checklist with the dates: https://runbooklabhq.github.io/guide-entra-sms-voice-mfa-retirement-passkeys.html?utm_source=github&utm_campaign=sms-free-repo

MIT licence. Not affiliated with or endorsed by Microsoft. Test changes on a pilot group first; dates come from Microsoft and can change, so re-check MC1519855 before you plan around them.
