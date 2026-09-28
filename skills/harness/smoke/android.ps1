# Android runtime smoke check (also used for Flutter).
# Exit codes: 0 = OK, 1 = FAIL, 3 = SKIPPED (no adb / no device / not booted).
# Does NOT start an emulator by itself - only uses an already connected device.
param(
    [Parameter(Mandatory = $true)][string]$Package,
    [Parameter(Mandatory = $true)][string]$Apk,
    [int]$WaitSec = 8,
    [int]$BootTimeoutSec = 120,
    [string]$OutDir = ".dlg\smoke"
)
$ErrorActionPreference = 'Continue'

function Finish([int]$code, [string]$msg) { Write-Output $msg; exit $code }

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    # Not in PATH: look in the usual SDK locations and put platform-tools on PATH for this run.
    $sdk = @($env:ANDROID_HOME, $env:ANDROID_SDK_ROOT, "$env:LOCALAPPDATA\Android\Sdk") |
        Where-Object { $_ -and (Test-Path (Join-Path $_ 'platform-tools\adb.exe')) } | Select-Object -First 1
    if (-not $sdk) { Finish 3 "SKIPPED: adb not found (PATH, ANDROID_HOME, %LOCALAPPDATA%\Android\Sdk)" }
    $env:PATH = (Join-Path $sdk 'platform-tools') + ';' + $env:PATH
}

$devices = @(& adb devices 2>$null | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" })
if ($devices.Count -eq 0) { Finish 3 "SKIPPED: no device or emulator connected" }

# Wait for boot to complete (a booting emulator makes every adb call time out).
$waited = 0
while ((((& adb shell getprop sys.boot_completed 2>$null) -join '').Trim()) -ne '1') {
    if ($waited -ge $BootTimeoutSec) { Finish 3 "SKIPPED: device not booted after ${BootTimeoutSec}s" }
    Start-Sleep -Seconds 5; $waited += 5
}

if (-not (Test-Path $Apk)) { Finish 1 "FAIL: APK not found: $Apk (build step did not produce it)" }

& adb logcat -c 2>$null | Out-Null
$install = (& adb install -r $Apk 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $install -notmatch 'Success') { Finish 1 "FAIL: install failed: $($install.Split("`n")[-1])" }

& adb shell monkey -p $Package -c android.intent.category.LAUNCHER 1 2>$null | Out-Null
Start-Sleep -Seconds $WaitSec

$appPid = ((& adb shell pidof $Package 2>$null) -join '').Trim()
$crash = @(& adb logcat -d -b crash 2>$null | Select-String -SimpleMatch $Package)

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
& adb shell screencap -p /sdcard/harness_smoke.png 2>$null | Out-Null
& adb pull /sdcard/harness_smoke.png (Join-Path $OutDir 'screen.png') 2>$null | Out-Null

if ($crash.Count -gt 0) { Finish 1 "FAIL: crash logged for ${Package}: $($crash[0].Line.Trim())" }
if (-not $appPid) { Finish 1 "FAIL: $Package not running ${WaitSec}s after launch" }
Finish 0 "SMOKE OK: $Package running (pid $appPid). Screenshot: $(Join-Path $OutDir 'screen.png')"
