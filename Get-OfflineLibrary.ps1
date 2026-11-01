<#
  Get-OfflineLibrary.ps1
  One-shot downloader for the Offline Emergency Library.
  Downloads: offline AI (3 models + CPU/GPU engines), GPT4All doc-Q&A, full Wikipedia
  (article text), offline US maps (OsmAnd), survival/repair/medical archives (Kiwix ZIM),
  public-domain Army field manuals + medical PDFs, the Kiwix reader, launchers, and all
  documentation (Markdown + HTML).

  Usage:
    .\Get-OfflineLibrary.ps1                      # will ask where to save
    .\Get-OfflineLibrary.ps1 -Destination E:\     # non-interactive
  Everything is RESUMABLE: re-run to continue after an interruption.
#>
[CmdletBinding()]
param(
  [string]$Destination,
  [switch]$SkipWikipedia,   # Wikipedia is the biggest (~24 GB); allow skipping
  [switch]$SkipMaps,        # OsmAnd US maps (~17 GB)
  [switch]$SkipModels       # the large AI chat models (~11 GB)
)

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'
$RepoRaw = 'https://raw.githubusercontent.com/elhajahmadj/offline-emergency-library/main'

# ---------------------------------------------------------------- destination
if (-not $Destination) {
  Write-Host ''
  Write-Host '  Offline Emergency Library installer' -ForegroundColor Cyan
  Write-Host '  -----------------------------------'
  $Destination = Read-Host 'Where would you like to save these files?'
}
if (-not $Destination) { Write-Host 'No destination given. Exiting.' -ForegroundColor Red; return }
$Root = Join-Path $Destination 'OfflineLibrary'
try { New-Item -ItemType Directory -Force $Root | Out-Null }
catch { Write-Host "Cannot create $Root : $($_.Exception.Message)" -ForegroundColor Red; return }

$Log = Join-Path $Root '_download.log'
function Log($m){ $s = "{0}  {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m; Add-Content $Log $s; Write-Host $s }
function Fetch($url,$out){ curl.exe -L -C - --retry 10 --retry-delay 5 --retry-all-errors -s -o $out $url }
function UA(){ 'Mozilla/5.0' }

# free-space check (needs roughly 60 GB for everything)
try {
  $drive = (Get-Item $Root).PSDrive
  $freeGB = [math]::Round((Get-PSDrive $drive.Name).Free/1GB,1)
  Log "Destination: $Root   (free space: $freeGB GB)"
  if ($freeGB -lt 65) { Log "WARNING: ~65 GB recommended for the full library. You have $freeGB GB free. Consider -SkipWikipedia / -SkipMaps / -SkipModels." }
} catch {}

# ---------------------------------------------------------------- folder tree
$dirs = @(
 'AI-Offline','AI-Offline\engine','AI-Offline\models','AI-Offline\DocReader-GPT4All',
 'Manuals','Manuals\ArmyFieldManuals','Manuals\Repair-iFixit','Manuals\DIY-Appropedia',
 'Manuals\Survival-Water-Food','Manuals\Radio-Communications',
 'Medical','Medical\WikiMed','Medical\zimgit-medicine','Medical\Manuals-PDF',
 'Wikipedia','OsmAnd','Kiwix-Reader','Kiwix-Reader\app'
)
foreach($d in $dirs){ New-Item -ItemType Directory -Force (Join-Path $Root $d) | Out-Null }

# ---------------------------------------------------------------- helpers
function Latest-Zim($dirUrl,$prefix){
  $html = curl.exe -sL -A (UA) $dirUrl
  $names = [regex]::Matches($html, [regex]::Escape($prefix)+'[^"<]*\.zim') | ForEach-Object {$_.Value} | Sort-Object -Unique
  if($names){ return ($names | Select-Object -Last 1) } else { return $null }
}
function Gh-ReleaseWith($repo,$needle){
  $rels = Invoke-RestMethod "https://api.github.com/repos/$repo/releases?per_page=20" -Headers @{'User-Agent'='ps'}
  foreach($r in $rels){ if($r.assets | Where-Object { $_.name -match $needle }){ return $r } }
  return $null
}

# ================================================================ 1. AI engine
Log '=== [1/8] Offline AI engine (llama.cpp, CPU + GPU) ==='
try{
  $rel = Gh-ReleaseWith 'ggml-org/llama.cpp' 'bin-win-cpu-x64'
  if($rel){
    foreach($pat in @('bin-win-cpu-x64\.zip$','bin-win-cpu-arm64\.zip$','bin-win-vulkan-x64\.zip$')){
      $a = $rel.assets | Where-Object { $_.name -match $pat } | Select-Object -First 1
      if($a){
        $zip = Join-Path $Root ("AI-Offline\engine\"+$a.name)
        Log "engine: $($a.name)"; Fetch $a.browser_download_url $zip
        $sub = if($a.name -match 'arm64'){'arm64'} elseif($a.name -match 'vulkan'){'vulkan-x64'} else {'x64'}
        try{ Expand-Archive $zip -DestinationPath (Join-Path $Root "AI-Offline\engine\$sub") -Force }catch{ Log "  extract failed: $($_.Exception.Message)" }
      }
    }
  } else { Log 'engine: no suitable llama.cpp release found' }
}catch{ Log "engine ERROR: $($_.Exception.Message)" }

# ================================================================ 2. AI models
Log '=== [2/8] AI chat models (GGUF, Q4_K_M) ==='
$models = @(
 @{n='Llama-3.2-3B-Instruct-Q4_K_M.gguf';      u='https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf'; big=$false}
 @{n='Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf'; u='https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf'; big=$true}
 @{n='Qwen2.5-7B-Instruct-Q4_K_M.gguf';        u='https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf'; big=$true}
)
foreach($m in $models){
  if($SkipModels -and $m.big){ Log "model (skipped): $($m.n)"; continue }
  Log "model: $($m.n)"; Fetch $m.u (Join-Path $Root "AI-Offline\models\$($m.n)")
}

# ================================================================ 3. GPT4All
Log '=== [3/8] GPT4All (offline document Q&A) ==='
try{
  $rel = Gh-ReleaseWith 'nomic-ai/gpt4all' 'installer-win64-v'
  $a = $rel.assets | Where-Object { $_.name -match 'installer-win64-v.*\.exe$' -and $_.name -notmatch 'arm' } | Select-Object -First 1
  if($a){ Log "gpt4all: $($a.name)"; Fetch $a.browser_download_url (Join-Path $Root "AI-Offline\DocReader-GPT4All\$($a.name)") }
}catch{ Log "gpt4all ERROR: $($_.Exception.Message)" }

# ================================================================ 4. Kiwix reader
Log '=== [4/8] Kiwix reader (portable) ==='
try{
  $kdir = 'https://download.kiwix.org/release/kiwix-desktop/'
  $html = curl.exe -sL -A (UA) $kdir
  $zip = [regex]::Matches($html,'kiwix-desktop_windows_x64_[0-9][^"<]*\.zip') | ForEach-Object {$_.Value} | Sort-Object -Unique | Select-Object -Last 1
  if($zip){
    $out = Join-Path $Root "Kiwix-Reader\$zip"
    Log "kiwix: $zip"; Fetch ($kdir+$zip) $out
    try{ Expand-Archive $out -DestinationPath (Join-Path $Root 'Kiwix-Reader\app') -Force }catch{ Log "  extract failed: $($_.Exception.Message)" }
  }
}catch{ Log "kiwix ERROR: $($_.Exception.Message)" }

# ================================================================ 5. ZIM archives
Log '=== [5/8] Offline archives (Kiwix ZIM: repair, DIY, medical, survival) ==='
$zims = @(
 @{dir='https://download.kiwix.org/zim/ifixit/'; pre='ifixit_en_all_';            d='Manuals\Repair-iFixit'}
 @{dir='https://download.kiwix.org/zim/other/';  pre='appropedia_en_all_maxi_';   d='Manuals\DIY-Appropedia'}
 @{dir='https://download.kiwix.org/zim/other/';  pre='zimgit-post-disaster_en_';  d='Manuals\Survival-Water-Food'}
 @{dir='https://download.kiwix.org/zim/other/';  pre='zimgit-water_en_';          d='Manuals\Survival-Water-Food'}
 @{dir='https://download.kiwix.org/zim/other/';  pre='zimgit-food-preparation_en_'; d='Manuals\Survival-Water-Food'}
 @{dir='https://download.kiwix.org/zim/other/';  pre='zimgit-knots_en_';          d='Manuals\Survival-Water-Food'}
 @{dir='https://download.kiwix.org/zim/wikipedia/'; pre='wikipedia_en_medicine_maxi_'; d='Medical\WikiMed'}
 @{dir='https://download.kiwix.org/zim/other/';  pre='zimgit-medicine_en_';       d='Medical\zimgit-medicine'}
)
foreach($z in $zims){
  $name = Latest-Zim $z.dir $z.pre
  if($name){ Log "zim: $name"; Fetch ($z.dir+$name) (Join-Path $Root "$($z.d)\$name") }
  else { Log "zim: NOT FOUND for prefix $($z.pre)" }
}

# ================================================================ 6. PDFs (Internet Archive)
Log '=== [6/8] Public-domain manuals (PDF) ==='
$pdfs = @(
 @{id='fm-21-76-us-army-survival-manual';                    n='FM 21-76 Army Survival Manual.pdf';               d='Manuals\ArmyFieldManuals'}
 @{id='fm-3-05.70-survival-2002';                            n='FM 3-05.70 Survival (2002).pdf';                  d='Manuals\ArmyFieldManuals'}
 @{id='105-page-survival-field-manual';                      n='105-Page Survival Field Manual.pdf';              d='Manuals\ArmyFieldManuals'}
 @{id='UsArmyFirstAidManualFm4-25.11';                       n='FM 4-25.11 First Aid.pdf';                        d='Manuals\ArmyFieldManuals'}
 @{id='Survival-FirstAidForSoldiers-AFieldManual';           n='Survival and First Aid for Soldiers.pdf';         d='Manuals\ArmyFieldManuals'}
 @{id='use-and-care-of-hand-tools-and-measuring-tools-1983'; n='TM 9-243 Use and Care of Hand Tools.pdf';         d='Manuals\ArmyFieldManuals'}
 @{id='fm-5-426-carpentry-1995';                             n='FM 5-426 Carpentry.pdf';                          d='Manuals\ArmyFieldManuals'}
 @{id='tm-9-8000-principles-of-automotive-vehicles-1985';    n='TM 9-8000 Principles of Automotive Vehicles.pdf'; d='Manuals\ArmyFieldManuals'}
 @{id='u-s-army-guide-to-rigging';                           n='FM 5-125 Army Guide to Rigging.pdf';              d='Manuals\ArmyFieldManuals'}
 @{id='fm-90-3-desert-operations-1993';                      n='FM 90-3 Desert Operations.pdf';                   d='Manuals\ArmyFieldManuals'}
 @{id='tm-10-412-armed-forces-recipe-service-2003';          n='TM 10-412 Armed Forces Recipe Service.pdf';       d='Manuals\ArmyFieldManuals'}
 @{id='bwb_S0-EJI-512';                                      n='Where There Is No Doctor.pdf';                    d='Medical\Manuals-PDF'}
 @{id='where-there-is-no-dentist-13th-printing-2010';        n='Where There Is No Dentist.pdf';                   d='Medical\Manuals-PDF'}
 @{id='shipsmedicineche0000medi';                            n='Ships Medicine Chest and First Aid at Sea.pdf';   d='Medical\Manuals-PDF'}
)
foreach($p in $pdfs){
  try{
    $meta = curl.exe -sL "https://archive.org/metadata/$($p.id)" -A (UA) | ConvertFrom-Json
    $f = $meta.files | Where-Object {$_.name -match '\.pdf$' -and $_.name -notmatch '_text\.pdf$'} | Sort-Object {[double]$_.size} -Descending | Select-Object -First 1
    if($f){ Log "pdf: $($p.n)"; Fetch "https://archive.org/download/$($p.id)/$([uri]::EscapeDataString($f.name))" (Join-Path $Root "$($p.d)\$($p.n)") }
    else { Log "pdf: NO PDF for $($p.id)" }
  }catch{ Log "pdf ERROR $($p.n): $($_.Exception.Message)" }
}

# ================================================================ 7. Wikipedia + Maps
if(-not $SkipWikipedia){
  Log '=== [7/8] Wikipedia (article text, compressed ~24 GB) ==='
  Fetch 'https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles.xml.bz2' (Join-Path $Root 'Wikipedia\enwiki-latest-pages-articles.xml.bz2')
} else { Log '=== [7/8] Wikipedia SKIPPED ===' }

if(-not $SkipMaps){
  Log '=== [8/8] Offline US maps (OsmAnd, ~17 GB) ==='
  try{
    $idxFile = Join-Path $env:TEMP 'osmand_idx.xml'
    curl.exe -s 'https://download.osmand.net/get_indexes' -o $idxFile
    [xml]$idx = Get-Content $idxFile
    $us = $idx.osmand_regions.region | Where-Object { $_.name -like 'US_*' -and $_.type -eq 'map' }
    Log "osmand: $($us.Count) US map files"
    foreach($r in $us){
      $out = Join-Path $Root "OsmAnd\$($r.name)"
      Fetch "https://download.osmand.net/download.php?standard=yes&file=$($r.name)" $out
    }
  }catch{ Log "osmand ERROR: $($_.Exception.Message)" }
} else { Log '=== [8/8] Maps SKIPPED ===' }

# ================================================================ launchers
Log '=== Writing launchers (.bat) ==='
function WriteBat($path,$text){ Set-Content -Path $path -Value $text -Encoding ascii }
$ao = Join-Path $Root 'AI-Offline'
WriteBat (Join-Path $ao 'CHAT-3B-light.bat') @"
@echo off
title Offline AI - Llama 3.2 3B (light)
cd /d "%~dp0"
"%~dp0engine\x64\llama-cli.exe" -m "%~dp0models\Llama-3.2-3B-Instruct-Q4_K_M.gguf" -c 4096 -cnv
pause
"@
WriteBat (Join-Path $ao 'CHAT-8B-smart.bat') @"
@echo off
title Offline AI - Llama 3.1 8B (smart)
cd /d "%~dp0"
"%~dp0engine\x64\llama-cli.exe" -m "%~dp0models\Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf" -c 4096 -cnv
pause
"@
WriteBat (Join-Path $ao 'CHAT-GPU-Qwen7B.bat') @"
@echo off
title Offline AI - Qwen2.5 7B (GPU)
cd /d "%~dp0"
echo If this errors with out-of-memory, your GPU is too small - change -ngl 99 to a lower
echo number (e.g. -ngl 20) or use a CPU launcher instead.
"%~dp0engine\vulkan-x64\llama-cli.exe" -m "%~dp0models\Qwen2.5-7B-Instruct-Q4_K_M.gguf" -c 4096 -ngl 99 -cnv
pause
"@
WriteBat (Join-Path $ao 'WEB-UI.bat') @"
@echo off
title Offline AI - Web UI
cd /d "%~dp0"
echo When it says "server listening", open a browser to http://127.0.0.1:8080
"%~dp0engine\x64\llama-server.exe" -m "%~dp0models\Llama-3.2-3B-Instruct-Q4_K_M.gguf" -c 4096 --host 127.0.0.1 --port 8080
pause
"@

# ================================================================ documentation
Log '=== Documentation (Markdown + HTML) ==='
# doc source: local .\docs if present (repo clone), else download from GitHub raw
$scriptDir = if($PSScriptRoot){$PSScriptRoot}else{(Get-Location).Path}
$localDocs = Join-Path $scriptDir 'docs'
function Get-Doc($name){
  $lp = Join-Path $localDocs $name
  if(Test-Path $lp){ return (Get-Content $lp -Raw) }
  try { return (curl.exe -sL "$RepoRaw/docs/$name" -A (UA)) } catch { return $null }
}
# md -> html (minimal converter)
$css = @'
<style>:root{--bg:#0f1420;--card:#171f2e;--ink:#e7ecf3;--muted:#9fb0c3;--accent:#4fd1c5;--accent2:#f6ad55;--line:#273246;--code:#0b0f17}@media(prefers-color-scheme:light){:root{--bg:#f4f6fb;--card:#fff;--ink:#15202b;--muted:#56657a;--accent:#0d9488;--accent2:#b45309;--line:#e2e8f0;--code:#f1f5f9}}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:16px/1.65 -apple-system,Segoe UI,Roboto,Arial,sans-serif}.wrap{max-width:900px;margin:0 auto;padding:28px 20px 80px}h1{font-size:28px;background:linear-gradient(135deg,var(--accent),var(--accent2));-webkit-background-clip:text;background-clip:text;color:transparent}h2{font-size:22px;border-bottom:2px solid var(--line);padding-bottom:6px;margin-top:30px}h3{font-size:17px;color:var(--accent)}h4{font-size:15px;color:var(--accent2)}a{color:var(--accent)}code{background:var(--code);padding:2px 6px;border-radius:6px;font-family:Consolas,monospace;font-size:14px}pre{background:var(--code);border:1px solid var(--line);border-radius:12px;padding:14px 16px;overflow-x:auto}pre code{background:none;padding:0}table{border-collapse:collapse;width:100%;margin:12px 0;font-size:15px}th,td{border:1px solid var(--line);padding:9px 12px;text-align:left;vertical-align:top}th{background:rgba(127,127,127,.12)}blockquote{border-left:4px solid var(--accent);background:rgba(79,209,197,.08);padding:10px 16px;border-radius:0 10px 10px 0}hr{border:none;border-top:1px solid var(--line);margin:26px 0}ul,ol{padding-left:26px}</style>
'@
function Esc($s){ $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' }
function Inline($s){ $s=Esc $s; $s=[regex]::Replace($s,'`([^`]+)`','<code>$1</code>'); $s=[regex]::Replace($s,'\*\*([^*]+)\*\*','<strong>$1</strong>'); $s=[regex]::Replace($s,'\[([^\]]+)\]\(([^)]+)\)','<a href="$2">$1</a>'); return $s }
function Md2Html($md,$title){
  $lines = $md -split "`r?`n"
  $o = New-Object System.Collections.Generic.List[string]
  $i = 0; $inCode=$false; $listType=$null
  function CloseList([ref]$lt,$out){ if($lt.Value){ $out.Add($(if($lt.Value -eq 'ul'){'</ul>'}else{'</ol>'})); $lt.Value=$null } }
  while($i -lt $lines.Count){
    $ln=$lines[$i]
    if($ln -match '^\s*```'){ if(-not $inCode){CloseList ([ref]$listType) $o;$o.Add('<pre><code>');$inCode=$true}else{$o.Add('</code></pre>');$inCode=$false}; $i++; continue }
    if($inCode){ $o.Add((Esc $ln)); $i++; continue }
    if($ln -match '^\s*\|' -and $i+1 -lt $lines.Count -and $lines[$i+1] -match '^\s*\|?\s*:?-{2,}'){
      CloseList ([ref]$listType) $o; $h=$ln.Trim().Trim('|').Split('|'); $o.Add('<table><thead><tr>'); foreach($c in $h){$o.Add('<th>'+(Inline $c.Trim())+'</th>')}; $o.Add('</tr></thead><tbody>'); $i+=2
      while($i -lt $lines.Count -and $lines[$i] -match '^\s*\|'){ $cs=$lines[$i].Trim().Trim('|').Split('|'); $o.Add('<tr>'); foreach($c in $cs){$o.Add('<td>'+(Inline $c.Trim())+'</td>')}; $o.Add('</tr>'); $i++ }
      $o.Add('</tbody></table>'); continue }
    if($ln -match '^\s*---\s*$'){ CloseList ([ref]$listType) $o;$o.Add('<hr>');$i++;continue }
    if($ln -match '^(#{1,4})\s+(.*)$'){ CloseList ([ref]$listType) $o;$l=$matches[1].Length;$o.Add("<h$l>"+(Inline $matches[2])+"</h$l>");$i++;continue }
    if($ln -match '^\s*>\s?(.*)$'){ CloseList ([ref]$listType) $o;$b=@();while($i -lt $lines.Count -and $lines[$i] -match '^\s*>\s?(.*)$'){$b+=$matches[1];$i++};$o.Add('<blockquote>'+(Inline ($b -join ' '))+'</blockquote>');continue }
    if($ln -match '^\s*[-*]\s+(.*)$'){ if($listType -ne 'ul'){CloseList ([ref]$listType) $o;$o.Add('<ul>');$listType='ul'}; $it=$matches[1] -replace '^\[ \]\s*','&#9744; ' -replace '^\[x\]\s*','&#9745; '; $o.Add('<li>'+(Inline $it)+'</li>');$i++;continue }
    if($ln -match '^\s*\d+\.\s+(.*)$'){ if($listType -ne 'ol'){CloseList ([ref]$listType) $o;$o.Add('<ol>');$listType='ol'}; $o.Add('<li>'+(Inline $matches[1])+'</li>');$i++;continue }
    if($ln -match '^\s*$'){ CloseList ([ref]$listType) $o;$i++;continue }
    CloseList ([ref]$listType) $o; $o.Add('<p>'+(Inline $ln)+'</p>'); $i++
  }
  if($inCode){$o.Add('</code></pre>')}; CloseList ([ref]$listType) $o
  return "<!DOCTYPE html><html lang=`"en`"><head><meta charset=`"utf-8`"><meta name=`"viewport`" content=`"width=device-width,initial-scale=1`"><title>$title</title>$css</head><body><div class=`"wrap`">`n"+($o -join "`n")+"`n</div></body></html>"
}
function PlaceDoc($srcName,$destPath,$title){
  $md = Get-Doc $srcName
  if(-not $md){ Log "  doc missing: $srcName"; return }
  Set-Content -Path "$destPath.md" -Value $md -Encoding utf8
  [System.IO.File]::WriteAllText("$destPath.html",(Md2Html $md $title),[System.Text.UTF8Encoding]::new($false))
}
PlaceDoc 'START-HERE.md'            (Join-Path $Root 'START-HERE')                                  'Offline Emergency Kit - Start Here'
PlaceDoc 'HOW-TO-RUN-OFFLINE-AI.md' (Join-Path $Root 'AI-Offline\HOW-TO-RUN-OFFLINE-AI')            'Offline AI - How To Run'
PlaceDoc 'HOW-TO-ASK-YOUR-DOCS.md'  (Join-Path $Root 'AI-Offline\DocReader-GPT4All\HOW-TO-ASK-YOUR-DOCS') 'Ask Your Documents - GPT4All'
PlaceDoc 'HOW-TO-USE-KIWIX.md'      (Join-Path $Root 'Kiwix-Reader\HOW-TO-USE-KIWIX')               'How to Use Kiwix'
PlaceDoc 'Manuals-READ-ME-FIRST.md' (Join-Path $Root 'Manuals\READ-ME-FIRST')                       'Manuals - Read Me First'
PlaceDoc 'Medical-READ-ME-FIRST.md' (Join-Path $Root 'Medical\READ-ME-FIRST')                       'Medical - Read Me First'
PlaceDoc 'RADIO-GUIDE.md'           (Join-Path $Root 'Manuals\Radio-Communications\RADIO-GUIDE')     'Emergency Radio Communications Guide'

Log '=== DONE. Open START-HERE.html in the destination folder. ==='
Write-Host ''
Write-Host "  Finished. Your offline library is in: $Root" -ForegroundColor Green
Write-Host "  Start by opening START-HERE.html" -ForegroundColor Green
