<#
.SYNOPSIS
    Checks (and optionally opens) the Windows Firewall for the GPU voice services.

.DESCRIPTION
    The compose stack publishes two Wyoming ports on the desktop:
        10300  whisper (STT)
        10200  kokoro  (TTS, via the wyoming_openai bridge)

    Run with no arguments to inspect only -- nothing is changed. Add -Apply to
    create the inbound rules.

    Rules are scoped to the local subnets rather than Any, so these ports are
    not exposed to the internet even if the machine later lands on an untrusted
    network. Adjust $AllowedSubnets if your addressing changes.

.EXAMPLE
    .\Open-VoicePorts.ps1              # report only
    .\Open-VoicePorts.ps1 -Apply       # create missing rules (needs admin)

.NOTES
    Testing from this machine proves nothing -- loopback bypasses the firewall
    entirely. Verify from another host; the script prints how at the end.
#>
[CmdletBinding()]
param(
    [switch]$Apply,

    # Subnets permitted to reach the voice services.
    #   192.168.1.0/24   LAN     - the desktop, phones, and OPNsense itself
    #   192.168.80.0/24  K8s     - Talos nodes, for the in-cluster reachability check
    #   192.168.20.0/24  Primary - the desktop's VLAN20 interface
    [string[]]$AllowedSubnets = @('192.168.1.0/24', '192.168.80.0/24', '192.168.20.0/24')
)

$ports = [ordered]@{
    10300 = 'whisper (Wyoming STT)'
    10200 = 'kokoro  (Wyoming TTS)'
}
$rulePrefix = 'HA Voice -'

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

Write-Host "`n=== Listening sockets ===" -ForegroundColor Cyan
foreach ($port in $ports.Keys) {
    $listen = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($listen) {
        $addrs = ($listen.LocalAddress | Sort-Object -Unique) -join ', '
        Write-Host ("  {0}  {1,-24} LISTENING on {2}" -f $port, $ports[$port], $addrs) -ForegroundColor Green
        if ($addrs -notmatch '0\.0\.0\.0|::') {
            Write-Host "         bound to loopback only - not reachable from the LAN." -ForegroundColor Yellow
            Write-Host "         Check the compose 'ports:' mapping publishes on 0.0.0.0." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host ("  {0}  {1,-24} NOT LISTENING - is the stack running?" -f $port, $ports[$port]) -ForegroundColor Yellow
    }
}

Write-Host "`n=== Firewall rules ===" -ForegroundColor Cyan
$missing = @()
foreach ($port in $ports.Keys) {
    $name = "$rulePrefix $port"
    $rule = Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue
    if ($rule) {
        $scope = ($rule | Get-NetFirewallAddressFilter).RemoteAddress -join ', '
        Write-Host ("  {0,-28} EXISTS  enabled={1} scope={2}" -f $name, $rule.Enabled, $scope) -ForegroundColor Green
    }
    else {
        Write-Host ("  {0,-28} MISSING" -f $name) -ForegroundColor Yellow
        $missing += $port
    }
}

if ($missing.Count -gt 0) {
    if (-not $Apply) {
        Write-Host "`n  Re-run with -Apply (as Administrator) to create $($missing.Count) rule(s)." -ForegroundColor Cyan
    }
    elseif (-not (Test-Admin)) {
        Write-Host "`n  -Apply needs an elevated shell. Re-run PowerShell as Administrator." -ForegroundColor Red
        exit 1
    }
    else {
        Write-Host "`n=== Creating rules ===" -ForegroundColor Cyan
        foreach ($port in $missing) {
            New-NetFirewallRule `
                -DisplayName "$rulePrefix $port" `
                -Description "Wyoming voice service for Home Assistant - $($ports[$port])" `
                -Direction Inbound -Protocol TCP -LocalPort $port `
                -RemoteAddress $AllowedSubnets -Action Allow -Profile Any | Out-Null
            Write-Host ("  created {0} {1} (scoped to {2})" -f $rulePrefix, $port, ($AllowedSubnets -join ', ')) -ForegroundColor Green
        }
    }
}

Write-Host "`n=== Addresses HAProxy can target ===" -ForegroundColor Cyan
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } |
    Sort-Object InterfaceAlias |
    ForEach-Object { Write-Host ("  {0,-16} {1}" -f $_.IPAddress, $_.InterfaceAlias) }

Write-Host @"

=== Verify from somewhere else ===
  Loopback bypasses the firewall, so testing from this machine proves nothing.
  From a cluster pod:

    kubectl -n home run netcheck --rm -it --restart=Never --image=busybox -- \
      sh -c 'nc -vz <desktop-ip> 10300 && nc -vz <desktop-ip> 10200'

  A successful connect still only means the port is open. To confirm the
  service actually answers, run the Wyoming probe in README.md.

"@ -ForegroundColor Cyan
