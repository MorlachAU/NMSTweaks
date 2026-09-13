# NMSTweaks

Data-driven mods for [No Man's Sky](https://www.nomanssky.com/), built from Lua scripts with [AMUMSS](https://github.com/HolterPhylo/AMUMSS). Same shape as [RiftbreakerTweaks](https://github.com/MorlachAU/RiftbreakerTweaks): the scripts are the source of truth, the generated mod folders are the deliverable.

> Single-player focused. Mods do **not** disable Steam achievements in No Man's Sky.

## The mods

| Mod | What it changes |
|-----|-----------------|
| *(none yet)* | First mod goes here. |

## How NMS modding works (as of Cosmos 7.01, September 2026)

- Game data lives in binary **MBIN** tables inside the archives under `GAMEDATA\PCBANKS`.
- **MBINCompiler** turns MBIN into editable **MXML** text and back. Its version number tracks the game version.
- **AMUMSS** is a script processor, not a mod manager. You write a Lua script that says "in this table, set this property to this value"; AMUMSS unpacks the table, applies the edit, and repacks it as a mod.
- Since game version 5.5 the old packed `.pak` mods no longer load. A mod is now a **folder of loose files** under `GAMEDATA\MODS\<ModName>\`, one level deep, no nesting.
- The game's on/off switch is `Binaries\SETTINGS\GCMODSETTINGS.MXML` (`DisableAllMods` is false by default).
- Every game update can rename or move properties, so scripts are re-run against fresh game data rather than shipping edited files that rot.

## Repo layout

```
scripts/   AMUMSS Lua scripts - the source. _TEMPLATE.lua is the starting point.
mods/      Generated mod folders - the deliverable. Drop into GAMEDATA\MODS.
build/     build.ps1 (scripts -> mods via AMUMSS), deploy.ps1 (mods -> game)
```

## Setup (one time)

Done on this machine 2026-09-13; kept here for a rebuild.

1. **.NET 8 x64 Desktop Runtime** - MBINCompiler needs it.
2. **7-Zip** - AMUMSS ships as a `.7z`: <https://www.7-zip.org/download.html>
3. **AMUMSS** - download the latest full release from <https://github.com/HolterPhylo/AMUMSS/releases> (v5.6.2.0W, 53 MB; check the SHA-256 against the digest GitHub shows on the asset).
   - Add an antivirus exclusion for `E:\AMUMSS` first; the maintainers warn it trips heuristics.
   - Unblock the file, extract to `E:\AMUMSS`. Never Desktop, Downloads or Documents, and no accented characters in the path.
   - `CONFIG\NMS_FOLDER.txt` holds the game path, one line, no quotes, no trailing slash. AMUMSS normally writes it itself; it was pre-seeded here.
   - Copy `build\BUILDMOD_AUTO.bat` from this repo into `E:\AMUMSS` (build.ps1 does this every run). It presets the options so AMUMSS asks fewer questions.
   - Run `BUILDMOD_AUTO.bat` once by hand. It creates the user folders (`ModScript`, `CreatedMODS`, `TOOLS\...`) and auto-downloads the MBINCompiler that matches the installed game. Re-run until it stops offering updates.

AMUMSS layout that matters: `ModScript\` is input, `CreatedMODS\<ModName>\` is output, `TOOLS\UNPACKED_DECOMPILED_PAKs\` and `TOOLS\MapFileTrees\` are where you look up property names.

## Workflow

```powershell
powershell -ExecutionPolicy Bypass -File build\build.ps1    # scripts/ -> AMUMSS -> mods/
powershell -ExecutionPolicy Bypass -File build\deploy.ps1   # mods/ -> GAMEDATA\MODS
```

`build.ps1` copies every `scripts\*.lua` (except `_`-prefixed helpers) into AMUMSS's `ModScript` folder, launches `BUILDMOD.bat`, waits for you to close it, then copies the produced mod folders back into `mods\`. To retune, edit the numbers at the top of a script and rebuild.

To remove a mod, delete its folder from `GAMEDATA\MODS`. Nothing in the game install is permanently changed.

## Writing a script

Copy `scripts\_TEMPLATE.lua`, rename it, and fill in the tables. The template explains each field in plain English. To find property names and their current values, unpack the game's tables with AMUMSS (it keeps decompiled copies under `TOOLS\UNPACKED_DECOMPILED_PAKs`) and search the MXML.

Reference material:
- [Public script collection](https://github.com/MetaIdea/nms-amumss-lua-mod-script-collection) - hundreds of real scripts by author, plus a learning folder of commented examples. Gumsk's scripts are the cleanest model for "settings block at the top, tables below".
- [MBINCompiler releases](https://github.com/monkeyman192/MBINCompiler/releases) - watch this after a game update; nothing builds until it catches up.
- NMS Modding Discord, `#amumss-lua` channel, is where AMUMSS questions get answered.

## License

MIT - see [LICENSE](LICENSE).
