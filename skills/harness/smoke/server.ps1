# Web/Node server runtime smoke check: start server, wait until URL answers, stop server.
# Exit codes: 0 = OK, 1 = FAIL, 3 = SKIPPED (port already in use by something else).
param(
    [Parameter(Mandatory = $true)][string]$StartCmd,
    [Parameter(Mandatory = $true)][string]$Url,
    [int]$TimeoutSec = 60,
    [string]$WorkDir = "."
)
$ErrorActionPreference = 'Continue'

function Finish([int]$code, [string]$msg) { Write-Output $msg; exit $code }
function Test-Url([string]$u) {
    try { $r = Invoke-WebRequest -UseBasicParsing -Uri $u -TimeoutSec 5; return [int]$r.StatusCode }
    catch { if ($_.Exception.Response) { return [int]$_.Exception.Response.StatusCode } ; return 0 }
}

if ((Test-Url $Url) -ne 0) { Finish 3 "SKIPPED: $Url already answers before start (another server is running on that port)" }

$proc = Start-Process -FilePath cmd.exe -ArgumentList "/c $StartCmd" -WorkingDirectory $WorkDir -PassThru -WindowStyle Hidden
$code = 0; $waited = 0; $early = $false
while ($waited -lt $TimeoutSec) {
    if ($proc.HasExited) { $early = $true; break }
    $code = Test-Url $Url
    if ($code -ge 200 -and $code -lt 500) { break }   # 404 counts as alive (API servers have no page at /)
    Start-Sleep -Seconds 2; $waited += 2
}
# Always stop the whole process tree (cmd -> npm -> node) before reporting.
if (-not $proc.HasExited) { & taskkill /PID $proc.Id /T /F 2>$null | Out-Null }
if ($early) { Finish 1 "FAIL: server process exited early (exit code $($proc.ExitCode))" }
if ($code -ge 200 -and $code -lt 500) { Finish 0 "SMOKE OK: $Url answered HTTP $code within ${waited}s" }
if ($code -ne 0) { Finish 1 "FAIL: $Url kept answering HTTP $code (server error) for ${TimeoutSec}s" }
Finish 1 "FAIL: $Url did not answer within ${TimeoutSec}s"
