# Entra SMS MFA Exit Kit: Top 5

_Version 1.0_

The five steps to do first before Microsoft retires its SMS and voice MFA. Free. Microsoft-provided SMS and voice authentication retires on 1 February 2027 for all users except Global Administrators and external users (internal guests are in scope), and on 1 July 2027 for Global Administrators and external users (MC1519855; Microsoft Learn, 'Passkeys by default and retirement of Microsoft-provided SMS and voice authentication'). After the date, users whose only MFA method is SMS or voice get a blocking prompt to register a passkey. There is no opt-out for enforcement. The Complete kit adds admins, guests, SSPR, the telephony-provider decision, helpdesk onboarding and weekly tracking (12 controls).

Read-only checks: run `entra-sms-mfa-exit-kit-top-5-readonly-checks.ps1` (Get-* cmdlets only, changes nothing).

| # | Control | Area | Sprint | Priority | Effort |
|---|---|---|---|---|---|
| S01 | List the users whose only MFA method is SMS or voice | Find who is affected | Sprint 1 - Find | Highest | 30 min |
| S02 | Check where SMS and voice are enabled in the Authentication methods policy | Find who is affected | Sprint 1 - Find | Highest | 30 min |
| S03 | Enable Passkey (FIDO2) for the affected users | Move users to passkeys | Sprint 1 - Find | Highest | 1 h |
| S04 | Run a registration campaign for passkeys aimed at the affected group | Move users to passkeys | Sprint 2 - Move | High | 30 min |
| S05 | Tell users in three waves: awareness, action, reminder | Move users to passkeys | Sprint 2 - Move | High | 2 h |

## S01. List the users whose only MFA method is SMS or voice

**Why:** These are the users who will hit the blocking passkey prompt on the retirement date. Microsoft-provided SMS and voice authentication retires on 1 February 2027 for all users except Global Administrators and external users (internal guests are in scope), and on 1 July 2027 for Global Administrators and external users (MC1519855; Microsoft Learn, 'Passkeys by default and retirement of Microsoft-provided SMS and voice authentication'). After the date, users whose only MFA method is SMS or voice get a blocking prompt to register a passkey. There is no opt-out for enforcement.

**Steps:**
1. Run the read-only check below (Microsoft Graph user registration details report). It exports phone-only-users.csv.
2. Alternatively, in the Entra admin center go to Entra ID > Authentication methods > Activity and filter the user registration details by methods registered.
3. Put the phone-only users in a security group (for example 'SMS-Voice-Exit'). You will target this group in S03 and S04.
4. Write the count in your tracker. Re-run weekly until it reaches zero.

**Check (read-only PowerShell):**

```powershell
$r = @(Get-MgReportAuthenticationMethodUserRegistrationDetail -All); $ph = @('mobilePhone','alternateMobilePhone','officePhone'); $weak = @('mobilePhone','alternateMobilePhone','officePhone','email','securityQuestion'); $only = @($r | Where-Object { $m = @($_.MethodsRegistered); ($m | Where-Object { $ph -contains $_ }).Count -gt 0 -and ($m | Where-Object { $weak -notcontains $_ }).Count -eq 0 }); "Users in registration report: $($r.Count)"; "Phone-only users (SMS/voice is their only MFA method): $($only.Count)"; "  of which admins: $(@($only | Where-Object { $_.IsAdmin }).Count)"; "  of which guests: $(@($only | Where-Object { $_.UserType -eq 'guest' }).Count)"; $only | Select-Object UserPrincipalName, UserType, IsAdmin, @{n='Methods';e={$_.MethodsRegistered -join ';'}} | Export-Csv -NoTypeInformation -Encoding UTF8 .\phone-only-users.csv; 'Exported .\phone-only-users.csv'
```

**Verify:** phone-only-users.csv exists, the count is recorded in the tracker with today's date, and the SMS-Voice-Exit group contains those users.

**Licence:** Entra ID P1 or P2 for the Authentication methods activity report; permission AuditLog.Read.All; role Reports Reader, Security Reader or Global Reader · **Effort:** 30 min · **Priority:** Highest · **Sprint 1 - Find**

## S02. Check where SMS and voice are enabled in the Authentication methods policy

**Why:** Users enabled for SMS or voice in the Authentication methods policy or in legacy MFA settings are the ones Microsoft moves into a passkey profile and nudges. Knowing the targets tells you which groups to plan for.

**Steps:**
1. Run the read-only check below: it shows the state and include targets of the SMS and Voice methods and the policy migration state.
2. Optional: run Microsoft's own scanner, github.com/microsoft/entra-sms-voice-usage-analyzer (Get-SmsVoicePolicyUsers.ps1). It reads policy scope only; it does not list users.
3. If the migration state is not 'migrationComplete', legacy MFA/SSPR settings may still enable phone methods: review them in the legacy MFA settings page.

**Check (read-only PowerShell):**

```powershell
$p = Get-MgPolicyAuthenticationMethodPolicy; foreach ($id in 'Sms','Voice') { $c = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $id; $t = @($c.AdditionalProperties['includeTargets'] | ForEach-Object { $_['id'] }) -join ', '; "$id method: state=$($c.State); include targets: $t" }; "Policy migration state: $($p.PolicyMigrationState)"
```

**Verify:** You know which groups have SMS/voice enabled and whether the policy migration is complete; both are written in the tracker.

**Licence:** Any Entra ID tenant; permission Policy.Read.All · **Effort:** 30 min · **Priority:** Highest · **Sprint 1 - Find**

## S03. Enable Passkey (FIDO2) for the affected users

**Why:** Passkeys are Microsoft's recommended replacement and moving SMS/voice users to passkeys costs nothing extra. Users can register a passkey in Microsoft Authenticator, a synced passkey (iCloud Keychain, Google Password Manager) or a FIDO2 security key.

**Steps:**
1. Entra admin center > Entra ID > Authentication methods > Policies > Passkey (FIDO2): enable it and include the SMS-Voice-Exit group (or All users).
2. Decide which passkey types you allow (device-bound in Authenticator, synced, hardware keys) and whether to require attestation.
3. Pilot with IT staff first: each pilot user registers one passkey and signs in with it.

**Check (read-only PowerShell):**

```powershell
$c = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId Fido2; $t = @($c.AdditionalProperties['includeTargets'] | ForEach-Object { $_['id'] }) -join ', '; "Passkey (FIDO2): state=$($c.State); include targets: $t"
```

**Verify:** Passkey (FIDO2) state is enabled and its include targets cover the SMS-Voice-Exit group; at least the pilot users show a passkey in the registration report.

**Licence:** Any Entra ID tenant · **Effort:** 1 h · **Priority:** Highest · **Sprint 1 - Find**

## S04. Run a registration campaign for passkeys aimed at the affected group

**Why:** The registration campaign prompts users at their next MFA sign-in. Snoozes are unlimited by default, so without a plan users keep postponing until the blocking prompt on the retirement date.

**Steps:**
1. Entra admin center > Entra ID > Authentication methods > Registration campaign (role: Authentication Policy Administrator).
2. Target the SMS-Voice-Exit group and the passkey method; review the snooze settings and set a date by which you stop allowing snoozes.
3. Tell users before the prompt appears (see S05).

**Check (read-only PowerShell):**

```powershell
$rc = (Get-MgPolicyAuthenticationMethodPolicy).RegistrationEnforcement.AuthenticationMethodsRegistrationCampaign; "Registration campaign state: $($rc.State)"; "Snooze duration (days): $($rc.SnoozeDurationInDays)"; "Targets: $(@($rc.IncludeTargets | ForEach-Object { "$($_.Id) -> $($_.TargetedAuthenticationMethod)" }) -join '; ')"
```

**Verify:** The campaign is enabled and targets the SMS-Voice-Exit group; the phone-only count from S01 goes down week by week.

**Licence:** Any Entra ID tenant · **Effort:** 30 min · **Priority:** High · **Sprint 2 - Move**

## S05. Tell users in three waves: awareness, action, reminder

**Why:** Users who register before the date avoid a blocking prompt on a busy morning, and the helpdesk avoids a spike of lock-outs.

**Steps:**
1. Use Microsoft's end-user templates (aka.ms/mfatemplates) and adapt them: what changes, by when, how long it takes.
2. Wave 1 awareness (now), wave 2 action with step-by-step registration per device type (iPhone, Android, Windows, hardware key), wave 3 reminders to whoever is still in phone-only-users.csv.
3. Give the helpdesk a short script for 'I got a passkey prompt and can't continue'.

**Verify:** Three messages are scheduled with dates before 1 February 2027 and the helpdesk script is published.

**Licence:** None · **Effort:** 2 h · **Priority:** High · **Sprint 2 - Move**

---
Not affiliated with or endorsed by Microsoft. Test every change in Report-only or on a pilot group first. Licence names and portal paths change; check Microsoft Learn if a menu has moved.
