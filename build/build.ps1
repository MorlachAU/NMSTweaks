<#
  NMSTweaks - build script
  Stages every script in scripts/ into AMUMSS, runs AMUMSS, then copies the
  mod folders it produced back into this repo's mods/ folder.

  The committed mods/ folders are the deliverable. scripts/*.lua is the
  single source of truth for every value.

  Usage:
    powershell -ExecutionPolicy Bypass -File build\build.ps1
    (optionally pass -Amumss pointing at your AMUMSS install)

  AMUMSS's BUILDMOD.bat is interactive: it asks a few questions in its own
  window and does not return until you close it. Answer the prompts, let it
  finish, then this script harvests the output.
#>
param(
  [string]$Amumss  = "E:\AMUMSS",
  [string]$Scripts = (Join-Path $PSScriptRoot "..\scripts"),
  [string]$OutDir  = (Join-Path $PSScriptRoot "..\mods")
)

$buildmod  = Join-Path $Amumss "BUILDMOD.bat"
$modScript = Join-Path $Amumss "ModScript"
$builds    = Join-Path $Amumss "Builds"

if(-not (Test-Path $buildmod)){
  Write-Error "AMUMSS not found at $Amumss (expected BUILDMOD.bat there). See README > Setup."
  exit 1
}
if(-not (Test-Path $modScript)){
  Write-Error "No ModScript folder in $Amumss - run BUILDMOD.bat once by hand first so AMUMSS creates its user folders."
  exit 1
}

# 1. Stage scripts. Anything starting with _ is a template/helper, not a mod.
$staged = Get-ChildItem -Path $Scripts -Filter *.lua -File | Where-Object { $_.Name -notlike '_*' }
if($staged.Count -eq 0){ Write-Error "No scripts to build in $Scripts"; exit 1 }
Get-ChildItem -Path $modScript -Filter *.lua -File | Remove-Item -Force
foreach($s in $staged){ Copy-Item -Force -Path $s.FullName -Destination $modScript; "Staged  $($s.Name)" }

# 2. Run AMUMSS and wait for its window to close.
"Launching AMUMSS - answer its prompts, then close it when the build is done."
Start-Process -FilePath $buildmod -WorkingDirectory $Amumss -Wait

# 3. Harvest. For NMS 5.5+ AMUMSS writes one folder per mod under Builds\.
if(-not (Test-Path $builds)){
  Write-Warning "No Builds folder found under $Amumss - check where AMUMSS wrote its output and adjust the `$builds path in this script."
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
