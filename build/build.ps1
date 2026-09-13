<#
  NMSTweaks - build script
  Stages every script in scripts/ into AMUMSS, runs AMUMSS, then copies the
  mod folders it produced back into this repo's mods/ folder.

  The committed mods/ folders are the deliverable. scripts/*.lua is the
  single source of truth for every value.

  Usage:
    powershell -ExecutionPolicy Bypass -File build\build.ps1
    (optionally pass -Amumss pointing at your AMUMSS install)

  AMUMSS runs in its own console window and does not return until that window
  closes. Our BUILDMOD_AUTO.bat presets answer most of its questions (individual
  mods, public game branch, no copy to game). Answer anything it still asks,
  let it finish, then this script harvests the output from CreatedMODS\.
#>
param(
  [string]$Amumss  = "E:\AMUMSS",
  [string]$Scripts = (Join-Path $PSScriptRoot "..\scripts"),
  [string]$OutDir  = (Join-Path $PSScriptRoot "..\mods")
)

# BUILDMOD_AUTO.bat is our options wrapper (presets: individual mods, no copy
# to game, public branch). Fall back to the stock interactive BUILDMOD.bat.
$buildmod  = Join-Path $Amumss "BUILDMOD_AUTO.bat"
if(-not (Test-Path $buildmod)){ $buildmod = Join-Path $Amumss "BUILDMOD.bat" }
$modScript = Join-Path $Amumss "ModScript"
$builds    = Join-Path $Amumss "CreatedMODS"   # one sub-folder per mod (verified in AMUMSS 5.6.2.0 source)

if(-not (Test-Path $buildmod)){
  Write-Error "AMUMSS not found at $Amumss (expected BUILDMOD.bat there). See README > Setup."
  exit 1
}
if(-not (Test-Path $modScript)){
  Write-Error "No ModScript folder in $Amumss - run BUILDMOD.bat once by hand first so AMUMSS creates its user folders."
  exit 1
}

# 0. Refresh our options wrapper so AMUMSS runs with the repo's presets.
Copy-Item -Force -Path (Join-Path $PSScriptRoot "BUILDMOD_AUTO.bat") -Destination (Join-Path $Amumss "BUILDMOD_AUTO.bat")

# 1. Stage scripts. Anything starting with _ is a template/helper, not a mod.
$staged = Get-ChildItem -Path $Scripts -Filter *.lua -File | Where-Object { $_.Name -notlike '_*' }
if($staged.Count -eq 0){ Write-Error "No scripts to build in $Scripts"; exit 1 }
Get-ChildItem -Path $modScript -Filter *.lua -File | Remove-Item -Force
foreach($s in $staged){ Copy-Item -Force -Path $s.FullName -Destination $modScript; "Staged  $($s.Name)" }

# 2. Run AMUMSS and wait for its window to close.
"Launching AMUMSS - answer its prompts, then close it when the build is done."
Start-Process -FilePath $buildmod -WorkingDirectory $Amumss -Wait

# 3. Harvest. For NMS 5.5+ AMUMSS writes one folder per mod under CreatedMODS\.
if(-not (Test-Path $builds)){
  Write-Warning "No CreatedMODS folder found under $Amumss - AMUMSS did not produce a mod. Check its REPORT.lua output."
  exit 1
}
$produced = Get-ChildItem -Path $builds -Directory
if($produced.Count -eq 0){ Write-Warning "AMUMSS produced nothing in $builds"; exit 1 }
foreach($p in $produced){
  $dst = Join-Path $OutDir $p.Name
  if(Test-Path $dst){ Remove-Item -Recurse -Force -LiteralPath $dst }
  Copy-Item -Recurse -Force -Path $p.FullName -Destination $dst
  $n=(Get-ChildItem -Recurse -File $dst).Count
  "Built   {0,-28} ({1} files)" -f $p.Name,$n
}
"Done. Run build\deploy.ps1 to copy into the game."
