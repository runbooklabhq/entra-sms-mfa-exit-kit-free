<#
 Entra SMS MFA Exit Kit: Top 5 - read-only checks (Runbook Lab)
 Uses Get-* cmdlets and Graph GET requests only. Changes nothing in your tenant; writes local CSV files.
 Requires: Microsoft.Graph.Authentication, Microsoft.Graph.Identity.SignIns, Microsoft.Graph.Reports.
 The script does not connect by itself: it uses your current Microsoft Graph session. Connect first (read-only scopes):
   Connect-MgGraph -Scopes AuditLog.Read.All,Policy.Read.AuthenticationMethod
 Output: .\hardening-check-results.csv (ID, Control, Output or Error).
#>
$ErrorActionPreference = 'Stop'
$results = @()
function Invoke-Check($Id, $Title, [scriptblock]$Block) {
  try { $o = & $Block | Out-String -Width 400; $s = 'OK' } catch { $o = $_.Exception.Message; $s = 'ERROR' }
  Write-Host "[$Id] $Title -> $s"
  $script:results += [pscustomobject]@{ ID = $Id; Control = $Title; Status = $s; Output = $o.Trim() }
}

Invoke-Check 'SM01' 'List the users whose only MFA method is SMS or voice' { $r = @(Get-MgReportAuthenticationMethodUserRegistrationDetail -All); $ph = { param($m) @($m | Where-Object { $_ -match 'phone' }).Count -gt 0 -and @($m | Where-Object { $_ -notmatch 'phone' -and $_ -notin 'email','securityQuestion','securityQuestions','temporaryAccessPass' }).Count -eq 0 }; $only = @($r | Where-Object { & $ph @($_.MethodsRegistered) }); "Users in registration report: $($r.Count)"; if ($r.Count -eq 0) { 'REVIEW: the report returned no users (permission, licence or report delay)' } elseif ($only.Count -gt 0) { "APPLIES: phone-only users (SMS/voice is their only MFA method): $($only.Count)" } else { 'NOT FOUND: no phone-only users in the report' }; "  of which admins (any admin role): $(@($only | Where-Object { $_.IsAdmin }).Count)"; "  of which guests: $(@($only | Where-Object { $_.UserType -eq 'guest' }).Count)"; $only | Select-Object UserPrincipalName, UserType, IsAdmin, @{n='Methods';e={$_.MethodsRegistered -join ';'}} | Export-Csv -NoTypeInformation -Encoding UTF8 .\phone-only-users.csv; 'Exported .\phone-only-users.csv' }
Invoke-Check 'SM02' 'Check where SMS and voice are enabled in the Authentication methods policy' { $p = Get-MgPolicyAuthenticationMethodPolicy; foreach ($id in 'Sms','Voice') { $c = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $id; $t = @($c.AdditionalProperties['includeTargets'] | ForEach-Object { $_['id'] }) -join ', '; "$id method: state=$($c.State); include targets: $t" }; "Policy migration state: $($p.PolicyMigrationState)" }
Invoke-Check 'SM03' 'Enable Passkey (FIDO2) for the affected users' { $c = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId Fido2; $t = @($c.AdditionalProperties['includeTargets'] | ForEach-Object { $_['id'] }) -join ', '; "Passkey (FIDO2): state=$($c.State); include targets: $t" }
Invoke-Check 'SM04' 'Run a registration campaign for passkeys aimed at the affected group' { $rc = (Get-MgPolicyAuthenticationMethodPolicy).RegistrationEnforcement.AuthenticationMethodsRegistrationCampaign; "Registration campaign state: $($rc.State)"; "Snooze duration (days): $($rc.SnoozeDurationInDays)"; "Limited snoozes (enforce after allowed snoozes): $($rc.EnforceRegistrationAfterAllowedSnoozes)"; "Targets: $(@($rc.IncludeTargets | ForEach-Object { "$($_.Id) -> $($_.TargetedAuthenticationMethod)" }) -join '; ')" }

$results | Export-Csv -NoTypeInformation -Encoding UTF8 .\hardening-check-results.csv
Write-Host "Done: $($results.Count) checks -> hardening-check-results.csv"
