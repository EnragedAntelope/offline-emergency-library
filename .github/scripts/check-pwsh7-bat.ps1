# CHECK-DRIVE.bat (and every other .bat that starts Windows PowerShell) works when it is
# started from a PowerShell 7 window (#117). Offline, a few seconds.
#
# The bug: PowerShell 7 puts its own module folders in PSModulePath. A .bat started from it
# runs in cmd.exe, which passes that value on to powershell.exe (Windows PowerShell 5.1).
# 5.1 then finds PowerShell 7's Microsoft.PowerShell.Utility first, cannot load it, and
# Get-FileHash fails: CHECK-DRIVE reported every file UNREADABLE. The fix in each .bat:
# setlocal, then set "PSModulePath=" before powershell; Windows PowerShell rebuilds its default.
# Microsoft documents both the failure and this fix in about_PSModulePath ("Starting Windows
# PowerShell from PowerShell 7").
#
# 1. Every .bat in the repo, and every .bat text the installers and the picker page write,
#    clears PSModulePath (after setlocal) before its first powershell line.
# 2. CHECK-DRIVE.bat, built by the installer's own CHECK-DRIVE and checksum sections, runs with
#    an unloadable PowerShell-7-style Microsoft.PowerShell.Utility first in PSModulePath. This
#    works without PowerShell 7; a copy without the fix must fail (self-test of the simulation).
# 3. The same CHECK-DRIVE.bat started from a real pwsh. Skipped when pwsh is missing, unless
#    OEL_REQUIRE_PWSH=1 (CI sets it; GitHub's Windows runners have PowerShell 7).
# Run it with Windows PowerShell 5.1, as CI does.
$ErrorActionPreference = 'Continue'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
function Fail($m){ Write-Host "FAIL: $m"; exit 1 }

Write-Host '== every .bat that starts powershell clears PSModulePath first'
$texts = @()
foreach($f in @(git -C $repo ls-files '*.bat')){ $texts += ,@($f, [System.IO.File]::ReadAllText((Join-Path $repo $f))) }
foreach($f in 'Get-OfflineLibrary.ps1','get-offline-library.sh','web/index.html'){
  $src = [System.IO.File]::ReadAllText((Join-Path $repo $f)) -replace "`r`n", "`n"
  # A .bat text starts at '@echo off' and ends at the here-string, heredoc or JS array end.
  foreach($m in [regex]::Matches($src, '(?ms)^\s*"?@echo off.*?(?=^(?:''@|"@|EOS)$|\]\.join\()')){ $texts += ,@($f, $m.Value) }
}
$checked = 0
foreach($t in $texts){
  $lines = $t[1] -split "`r?`n"
  $ps = -1; for($i = 0; $i -lt $lines.Count; $i++){ if($lines[$i] -match '(?i)\bpowershell(\.exe)?\s+-NoProfile'){ $ps = $i; break } }
  if($ps -lt 0){ continue }
  $before = $lines[0..($ps - 1)] -join "`n"
  $first = ($lines[$ps].Trim() -replace '\s+', ' ')
  if($first.Length -gt 70){ $first = $first.Substring(0, 70) + '...' }
  if($before -notmatch '(?im)^\s*"?setlocal\b'){ Fail "$($t[0]): a .bat runs '$first' without setlocal before it" }
  if($before -notmatch '(?im)^\s*"?set \\?"PSModulePath=\\?"'){ Fail "$($t[0]): a .bat runs '$first' without set `"PSModulePath=`" before it" }
  Write-Host "  ok: $($t[0]): $first"
  $checked++
}
# drive\CHECK-DRIVE.bat, install.bat, 2 map viewer .bat and TRANSLATE-BROWSER.bat (Windows
# installer), TRANSLATE-BROWSER.bat (bash installer), the picker page's installer .bat.
if($checked -lt 7){ Fail "found only $checked .bat texts that start powershell, expected 7 (did a marker change?)" }

# ---- a drive with the installer's own CHECK-DRIVE files and checksum list ----
$src = [System.IO.File]::ReadAllText((Join-Path $repo 'Get-OfflineLibrary.ps1')) -replace "`r`n", "`n"
function Section($start, $end){
  $m = [regex]::Match($src, "(?ms)^($start.*?)^$end")
  if(-not $m.Success -or $m.Groups[1].Value.Length -lt 200){ Fail "section '$start' not found in Get-OfflineLibrary.ps1. Were its markers renamed?" }
  $m.Groups[1].Value
}
$checkDrv = Section '# CHECK-DRIVE scripts' "Log '=== Building README\.html"
$sums     = Section '# =+ drive check \(#28\)' '# =+ self-check'
function Log($m){ Write-Host "  $m" }
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('oel-pwsh7-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
$Root = Join-Path $tmp 'Library copy\OfflineLibrary'
$oldPath = $env:PSModulePath
try {
  New-Item -ItemType Directory -Force (Join-Path $Root 'Docs') | Out-Null
  Set-Content -Path (Join-Path $Root 'Docs\guide one.txt') -Value 'first file' -Encoding ascii
  Set-Content -Path (Join-Path $Root 'START-HERE.html') -Value '<p>start</p>' -Encoding ascii
  $scriptDir = $repo; $Only = $null
  . ([scriptblock]::Create($checkDrv))
  . ([scriptblock]::Create($sums))

  # As check-smoke.ps1 runs it: a copy without the final 'pause'.
  $bat = [System.IO.File]::ReadAllText((Join-Path $Root 'CHECK-DRIVE.bat')) -replace '(?m)^pause\r?$', ''
  $fixed = Join-Path $Root '_t-CHECK-DRIVE.bat'
  [System.IO.File]::WriteAllText($fixed, $bat, [System.Text.Encoding]::ASCII)
  $unfixed = Join-Path $Root '_t-unfixed-CHECK-DRIVE.bat'
  $noFix = $bat -replace '(?m)^set "PSModulePath="\r?\n', ''
  if($noFix -eq $bat){ Fail 'CHECK-DRIVE.bat has no set "PSModulePath=" line to remove for the self-test' }
  [System.IO.File]::WriteAllText($unfixed, $noFix, [System.Text.Encoding]::ASCII)
  function RunBat($b){ $script:out = (& $b 2>&1 | Out-String); $script:rc = $LASTEXITCODE; $global:LASTEXITCODE = 0 }
  function Ok(){ $script:rc -eq 0 -and $script:out -match 'RESULT: ALL [1-9][0-9]* FILES OK' }

  Write-Host '== CHECK-DRIVE.bat, this PowerShell'
  RunBat $fixed
  if(-not (Ok)){ Fail "CHECK-DRIVE.bat failed (exit $rc):`n$out" }
  Write-Host "  ok: $(([regex]::Match($out, 'RESULT:.*')).Value.Trim())"

  Write-Host '== CHECK-DRIVE.bat with a PowerShell 7 style module path first in PSModulePath'
  # Like PowerShell 7's $PSHOME\Modules: a Microsoft.PowerShell.Utility that 5.1 cannot load,
  # listing (as PowerShell 7's manifest does) the Utility commands check-drive.ps1 uses. With
  # Get-FileHash alone, 5.1 loads its own Utility for Write-Host and the bug does not show.
  $fake = Join-Path $tmp 'fake-pwsh7\Modules'
  $um = Join-Path $fake 'Microsoft.PowerShell.Utility'
  New-Item -ItemType Directory -Force $um | Out-Null
  Set-Content -Path (Join-Path $um 'Microsoft.PowerShell.Utility.psd1') -Encoding ascii -Value @'
@{
ModuleVersion = '7.0.0.0'
GUID = '1DA87E53-152B-403E-98DC-74D7B4D63D59'
CompatiblePSEditions = @('Core')
PowerShellVersion = '3.0'
NestedModules = 'Microsoft.PowerShell.Commands.Utility.dll'
CmdletsToExport = @('Get-FileHash', 'Write-Host', 'Select-Object')
}
'@
  [System.IO.File]::WriteAllBytes((Join-Path $um 'Microsoft.PowerShell.Commands.Utility.dll'), [byte[]](1..64))
  $env:PSModulePath = "$fake;$oldPath"
  RunBat $unfixed
  if(Ok){ Fail "self-test: without the fix, CHECK-DRIVE.bat still passed with the PowerShell 7 style module path, so this check would not catch the bug:`n$out" }
  Write-Host "  ok: without the fix it fails (exit $rc): $(([regex]::Match($out, 'RESULT:.*')).Value.Trim())"
  RunBat $fixed
  if(-not (Ok)){ Fail "CHECK-DRIVE.bat failed with a PowerShell 7 module path (exit $rc):`n$out" }
  Write-Host "  ok: $(([regex]::Match($out, 'RESULT:.*')).Value.Trim())"
  # A real problem must still exit 1 through setlocal.
  Add-Content -Path (Join-Path $Root 'Docs\guide one.txt') -Value 'changed' -Encoding ascii
  RunBat $fixed
  if($rc -ne 1 -or $out -notmatch 'DAMAGED: Docs/guide one\.txt'){ Fail "a damaged file did not make CHECK-DRIVE.bat exit 1 (exit $rc):`n$out" }
  Write-Host '  ok: a damaged file still exits 1'
  Set-Content -Path (Join-Path $Root 'Docs\guide one.txt') -Value 'first file' -Encoding ascii
  $env:PSModulePath = $oldPath

  Write-Host '== CHECK-DRIVE.bat started from PowerShell 7 (pwsh)'
  $pwsh = Get-Command pwsh -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if(-not $pwsh){
    if($env:OEL_REQUIRE_PWSH -eq '1'){ Fail 'pwsh (PowerShell 7) not found, and OEL_REQUIRE_PWSH=1' }
    Write-Host '  SKIP: pwsh (PowerShell 7) is not installed here'
  } else {
    # What a user does: type the .bat's path at a PowerShell 7 prompt.
    $wrap = Join-Path $tmp 'from-pwsh.ps1'
    Set-Content -Path $wrap -Encoding ascii -Value @'
param($Bat)
"PowerShell $($PSVersionTable.PSVersion); its own modules in PSModulePath: $(@($env:PSModulePath -split ';') -contains (Join-Path $PSHOME 'Modules'))"
& $Bat
exit $LASTEXITCODE
'@
    function FromPwsh($b){ $script:out = (& $pwsh.Source -NoProfile -ExecutionPolicy Bypass -File $wrap $b 2>&1 | Out-String); $script:rc = $LASTEXITCODE; $global:LASTEXITCODE = 0 }
    FromPwsh $unfixed
    Write-Host "  $(([regex]::Match($out, 'PowerShell [^\r\n]*')).Value)"
    if(Ok){ Write-Host '  note: without the fix it also passes on this computer (the bug does not show here)' }
    else { Write-Host "  without the fix it fails here (exit $rc): $(([regex]::Match($out, 'RESULT:.*')).Value.Trim())" }
    FromPwsh $fixed
    if(-not (Ok)){ Fail "CHECK-DRIVE.bat started from pwsh failed (exit $rc):`n$out" }
    Write-Host "  ok: $(([regex]::Match($out, 'RESULT:.*')).Value.Trim())"
  }
  Write-Host 'PowerShell 7 .bat check: OK'
}
finally {
  $env:PSModulePath = $oldPath
  Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
