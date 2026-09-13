<#
  NMSTweaks - deploy script
  Copies every mod folder in mods/ into the game's GAMEDATA\MODS directory.
  The game picks them up on next launch; nothing else needs enabling.

  Usage:
    powershell -ExecutionPolicy Bypass -File build\deploy.ps1
    (optionally pass -GameMods pointing at <No Man's Sky>\GAMEDATA\MODS)
#>
param(
  [string]$GameMods = "E:\SteamLibrary\steamapps\common\No Man's Sky\GAMEDATA\MODS",
  [string]$SrcDir   = (Join-Path $PSScriptRoot "..\mods")
)

if(-not (Test-Path $GameMods)){ New-Item -ItemType Directory -Force -Path $GameMods | Out-Null }
$mods = Get-ChildItem -Path $SrcDir -Directory
if($mods.Count -eq 0){ Write-Warning "Nothing to deploy - mods/ is empty. Run build\build.ps1 first."; exit 1 }
foreach($m in $mods){
  $dst = Join-Path $GameMods $m.Name
  if(Test-Path $dst){ Remove-Item -Recurse -Force -LiteralPath $dst }
  Copy-Item -Recurse -Force -Path $m.FullName -Destination $dst
  $n=(Get-ChildItem -Recurse -File $dst).Count
  "Deployed {0,-28} ({1} files)" -f $m.Name,$n
}
"Done. Launch No Man's Sky."
