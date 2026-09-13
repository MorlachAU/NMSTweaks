@echo off
rem NMSTweaks options wrapper for AMUMSS - versioned copy lives in the repo at build\BUILDMOD_AUTO.bat.
rem build.ps1 copies it into the AMUMSS folder before every run. Edit the repo copy, not the AMUMSS one.
rem See README\README-OPTIONS_DEFINITIONS.txt in AMUMSS for every option. Order is irrelevant.
set "_O= "
set _O=%_O%      -AutoUpdateAMUMSS Y
set _O=%_O%      -AutoUpdateMBinCompiler Y
set _O=%_O%      -GameVersion P
set _O=%_O%      -CombineModPak N
set _O=%_O%      -CopyToGamefolder NONE
set _O=%_O%      -CheckForModConflicts M
set _O=%_O%      -UseExtraFilesInPAK N
set _O=%_O%      -UseLuaScriptInPak Y
set _O=%_O%      -IncludeLuaScriptInPak Y
set _O=%_O%      -DEV_MODE D
set _O=%_O%      -SHOWOPTIONS N
BUILDMOD.bat %_O%
