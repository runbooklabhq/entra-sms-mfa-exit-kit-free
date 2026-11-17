# Entra SMS MFA Exit Kit: Top 5 (free)

Microsoft retires its own SMS and voice MFA on **1 February 2027** for all users except Global Administrators and external users (internal guests included), and on **1 July 2027** for Global Administrators and external users. The July date applies only while the Global Administrator role is active; users only eligible for it follow 1 February 2027. After the date, users whose only MFA method is SMS or voice get a blocking prompt to register a passkey. There is no opt-out for enforcement. Sources: Microsoft Learn, "Passkeys by default and retirement of Microsoft-provided SMS and voice authentication", and message center post MC1426371.

This kit is the first five steps as a ready-to-run project:

| File | What it is |
|---|---|
| `entra-sms-mfa-exit-kit-top-5-guide.md` | Why, steps, check, verify, impact, rollback, Microsoft Learn sources, licence and effort for each step |
| `entra-sms-mfa-exit-kit-top-5-jira-import.csv` | Jira Cloud import: epics + tasks with parent links, priority and one label per column (sprint as a `sprint-N` label) |
| `entra-sms-mfa-exit-kit-top-5-tracker.csv` | Same backlog for Planner, Azure DevOps, Excel or Linear |
| `entra-sms-mfa-exit-kit-top-5-project-plan.xlsx` | Excel project plan for teams without Jira: owner, dates, status drop-down, % complete and a progress dashboard by area and sprint |
| `entra-sms-mfa-exit-kit-top-5-readonly-checks.ps1` | Get-* only. Changes nothing. Writes `hardening-check-results.csv` and `phone-only-users.csv` |

Steps: list phone-only users · see where SMS/voice is enabled · enable passkeys · run a registration campaign · tell users in three waves.

## Run the checks
```powershell
Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns, Microsoft.Graph.Reports -Scope CurrentUser
Connect-MgGraph -Scopes AuditLog.Read.All,Policy.Read.AuthenticationMethod
./entra-sms-mfa-exit-kit-top-5-readonly-checks.ps1
```
The user registration report in the portal needs Entra ID P1 or P2; the checks need a role such as Reports Reader, Security Reader or Global Reader. If a property name has changed in your Graph module version, the check reports an ERROR line instead of guessing. If a check misreads your setup, reply to your receipt.

## Next: the Complete kit
**Entra SMS MFA Exit Kit: Complete** adds 7 controls: Global Admins and external users (1 July 2027), internal guests, SSPR for phone-only users, the telephony-provider decision, the temporary opt-out check, safe helpdesk onboarding with Temporary Access Pass, and weekly tracking to zero.
→ https://runbooklab.gumroad.com/l/sms-mfa-exit-kit?utm_source=github&utm_medium=readme&utm_campaign=sms-free-repo

Six-step checklist with the dates: https://runbooklabhq.com/guides/entra-sms-voice-mfa-retirement-passkeys/?utm_source=github&utm_medium=readme&utm_campaign=sms-free-repo

MIT licence. Not affiliated with or endorsed by Microsoft. Test changes on a pilot group first; dates come from Microsoft and can change, so re-check the Microsoft Learn page 'Passkeys by default and retirement of Microsoft-provided SMS and voice authentication' (it states both dates) and, for SSPR, message center post MC1536049 before you plan around them. Version 1.1, sources re-read 16 Nov 2026; see CHANGELOG.md.
