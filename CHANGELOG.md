# Changelog: Entra SMS MFA Exit Kit

## 1.1 (2026-11-16)
- Every control now has impact (who notices, what breaks), rollback and the Microsoft Learn pages it was checked against, read on 16 Nov 2026; the guide and the Jira import show them.
- Dates: both retirement dates are now cited to Microsoft Learn ('Passkeys by default and retirement of Microsoft-provided SMS and voice authentication') and message center post MC1426371, which state both. New from Microsoft's FAQ: the 1 July 2027 date applies only while the Global Administrator role is active; users only eligible for it (for example in PIM) follow 1 February 2027; as before, all other admin roles follow 1 February 2027 (intro, SM01, SM06).
- SM09 (SSPR): MC1536049 re-read (act by 22 March 2027): SMS and voice stop working for SSPR 50 days after the rollout reaches your tenant; from February 2027 SSPR also accepts only explicitly registered methods; never-registered directory phone numbers and emails stop working (Learn). Users moved to a telephony provider keep SMS/voice for SSPR.
- SM03 (passkeys): steps follow Learn's passkey profiles (Device-bound / Synced, Enforce attestation, 'Allow self-service set up'); opting in to passkey profiles cannot be undone; guests cannot register passkeys yet.
- SM04 (registration campaign): Microsoft-managed campaigns allow unlimited snoozes; to stop skipping, set State to Enabled with 'Limited number of snoozes'. The check also shows that setting.
- SM01, SM09 checks: any registered method whose name contains 'phone' counts as SMS/voice; SM01 now ends with APPLIES, NOT FOUND or REVIEW (empty report). SM11 check also shows the Temporary Access Pass targets. A Temporary Access Pass no longer counts as a lasting method in SM01/SM09.
- Permissions follow Learn: Policy.Read.AuthenticationMethod for the authentication methods policy and its methods (SM02, SM03, SM04, SM10, SM11); the connect line is AuditLog.Read.All,Policy.Read.AuthenticationMethod.
- SM02, SM08, SM11, SM12: portal paths, provider wording, Temporary Access Pass roles and lifetimes, report delay (up to 36 hours) follow Learn.
- Jira CSV: one label per column (runbooklab, the kit label, the control ID, sprint-N, area) and Task instead of Story, as in the other Runbook Lab kits.
- Control IDs renamed from S01–S12 to SM01–SM12, so no two Runbook Lab kits share an ID (the M365 Hardening Kit uses S01–S08 for SharePoint). If you imported 1.0 into Jira or a tracker, the old S-numbers map one to one (S01 = SM01 … S12 = SM12).

## 1.0 (2026-10-27)
- First release.
