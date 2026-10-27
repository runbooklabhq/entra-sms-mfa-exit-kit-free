<#
 Entra SMS MFA Exit Kit: Top 5 - read-only checks (Runbook Lab)
 Uses Get-* cmdlets only. Changes nothing in your tenant.
 Requires: Microsoft.Graph, ExchangeOnlineManagement, MicrosoftTeams, Microsoft.Online.SharePoint.PowerShell (as needed).
 Connect first, e.g.:
   Connect-MgGraph -Scopes Policy.Read.All,Directory.Read.All,AuditLog.Read.All,RoleManagement.Read.Directory
   Connect-ExchangeOnline; Connect-IPPSSession; Connect-MicrosoftTeams; Connect-SPOService -Url https://<tenant>-admin.sharepoint.com
 Output: .\hardening-check-results.csv (ID, Control, Output or Error). Feed it to the m365-hardening-coach skill.
#>
$ErrorActionPreference = 'Stop'
$results = @()
function Invoke-Check($Id, $Title, [scriptblock]$Block) {
  try { $o = & $Block | Out-String -Width 400; $s = 'OK' } catch { $o = $_.Exception.Message; $s = 'ERROR' }
  Write-Host "[$Id] $Title -> $s"
  $script:results += [pscustomobject]@{ ID = $Id; Control = $Title; Status = $s; Output = $o.Trim() }
}

Invoke-Check 'S01' 'List the users whose only MFA method is SMS or voice' { $r = @(Get-MgReportAuthenticationMethodUserRegistrationDetail -All); $ph = @('mobilePhone','alternateMobilePhone','officePhone'); $weak = @('mobilePhone','alternateMobilePhone','officePhone','email','securityQuestion'); $only = @($r | Where-Object { $m = @($_.MethodsRegistered); ($m | Where-Object { $ph -contains $_ }).Count -gt 0 -and ($m | Where-Object { $weak -notcontains $_ }).Count -eq 0 }); "Users in registration report: $($r.Count)"; "Phone-only users (SMS/voice is their only MFA method): $($only.Count)"; "  of which admins: $(@($only | Where-Object { $_.IsAdmin }).Count)"; "  of which guests: $(@($only | Where-Object { $_.UserType -eq 'guest' }).Count)"; $only | Select-Object UserPrincipalName, UserType, IsAdmin, @{n='Methods';e={$_.MethodsRegistered -join ';'}} | Export-Csv -NoTypeInformation -Encoding UTF8 .\phone-only-users.csv; 'Exported .\phone-only-users.csv' }
Invoke-Check 'S02' 'Check where SMS and voice are enabled in the Authentication methods policy' { $p = Get-MgPolicyAuthenticationMethodPolicy; foreach ($id in 'Sms','Voice') { $c = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId $id; $t = @($c.AdditionalProperties['includeTargets'] | ForEach-Object { $_['id'] }) -join ', '; "$id method: state=$($c.State); include targets: $t" }; "Policy migration state: $($p.PolicyMigrationState)" }
Invoke-Check 'S03' 'Enable Passkey (FIDO2) for the affected users' { $c = Get-MgPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -AuthenticationMethodConfigurationId Fido2; $t = @($c.AdditionalProperties['includeTargets'] | ForEach-Object { $_['id'] }) -join ', '; "Passkey (FIDO2): state=$($c.State); include targets: $t" }
Invoke-Check 'S04' 'Run a registration campaign for passkeys aimed at the affected group' { $rc = (Get-MgPolicyAuthenticationMethodPolicy).RegistrationEnforcement.AuthenticationMethodsRegistrationCampaign; "Registration campaign state: $($rc.State)"; "Snooze duration (days): $($rc.SnoozeDurationInDays)"; "Targets: $(@($rc.IncludeTargets | ForEach-Object { "$($_.Id) -> $($_.TargetedAuthenticationMethod)" }) -join '; ')" }

$results | Export-Csv -NoTypeInformation -Encoding UTF8 .\hardening-check-results.csv
Write-Host "Done: $($results.Count) checks -> hardening-check-results.csv"
