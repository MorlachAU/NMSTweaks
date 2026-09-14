# NMSTweaks

Data-driven mods for [No Man's Sky](https://www.nomanssky.com/), built from Lua scripts with [AMUMSS](https://github.com/HolterPhylo/AMUMSS). Same shape as [RiftbreakerTweaks](https://github.com/MorlachAU/RiftbreakerTweaks): the scripts are the source of truth, the generated mod folders are the deliverable.

> Single-player focused. Mods do **not** disable Steam achievements in No Man's Sky.
> Current mods tested in-game on Cosmos 7.01 (September 2026).

## The mods

| Mod | What it changes |
|-----|-----------------|
| **MovementTweaks** | Jetpack recharge **×4** (ground and mid-air), horizontal jetpack drain **×0.2**, sprint speed **×1.5** (normal and low gravity), sprint stamina drain **×0.1**, stamina recovery **×5**. Walk speed untouched. Edits `GCPLAYERGLOBALS` only. *Tested in-game.* |
| **PlanetaryTweaks** | Refiners **×3** throughput (all sizes, normal and survival). Analysis visor: scan lock time **×0.5**, pulse recharge **×0.5**, pulse radius **×1.5**, scan rewards for creatures/flora/minerals **×3**, visor tag range **×1.5** on planet and in space. Mining beam: extraction rate **×2**, time before overheat **×2**, overheat cooldown **×0.5**, energy drain **×0.5**. Ship asteroid mining yield **×2**. Terrain manipulator reach **×1.5**. Edits `GCGAMEPLAYGLOBALS`, `GCPLAYERGLOBALS` and the technology table (mining beam `LASER`, visor `SCAN1`). *Tested in-game.* |
| **HazardTweaks** | Hazard protection lasts **×5** longer in the open, recharges **×2** faster when sheltered, and depleted-protection damage is **×0.5** (Normal and Hard mode figures both scaled). Base suit hazard capacity **×2** and underwater pressure protection **×2**. Life support capacity and regen **×2**, all discharge rates **×0.5** (idle, active, floating in space, deep water), daylight solar trickle **×2**. Exocraft hazard modules **×2** and Minotaur built-in protection **×2**. Edits `GCPLAYERGLOBALS` and the technology table (`PROTECT`, `ENERGY`, `EXO_PROT_*`, `MECH_PROT`). *Suit parts tested in-game. Exocraft and Minotaur parts untested (none owned yet).* |
| **HealthTweaks** | Full health bar from the start (**9** pips, stock 3). Health regen **×2** faster, starts **×0.5** sooner after damage. Shield maximum **×2**, shield regen **×2** faster, starts **×0.5** sooner. Wounds need **×2** the damage to inflict and fade **×0.5** as fast. Edits `GCPLAYERGLOBALS` only. *Tested in-game.* |
| **InventoryTweaks** | Stack sizes **×5** for every product and substance (non-stackables stay non-stackable). New ships, multi-tools, freighters and corvettes always generate with their **maximum** slot count (stock rolls a range). Slot purchase base cost **×0.5** for ships, weapons and freighters. Edits the product, substance and inventory tables plus `GCPLAYERGLOBALS`. *Tested in-game.* Stack sizes and slot costs apply to an existing save at once; slot generation only affects inventories created after install. Exosuit slots are not touched (those come from drop pods and station purchases). |
| **ShipTweaks** | Hyperdrive range **×3** and warps per warp cell **×2**. Launch thruster cost **×0.5**. Pulse drive speed **×2** and fuel use **×0.5**, boost **×1.25**, handling **×1.25**. Ship shield strength **×2**. Ship scanner cooldown **×0.5** in space and on planets. Flight speed and thrust **×1.5** (normal and boost) for every ship control type (standard, light, heavy, hover, heavy hover, corvette) in every flight mode (space, planet, combat, atmosphere combat). Base techs and their alien/robot/special variants all scaled. Edits the technology table, `GCGAMEPLAYGLOBALS` and `GCSPACESHIPGLOBALS`. *Built from data; in-game test pending.* Ship weapons are deliberately untouched. |

**Coexistence:** all five mods edit `GCPLAYERGLOBALS`, and two of them edit the technology table. That works because mods ship as line patches (`.EXML` with only the changed lines) and no two mods ever touch the same line. AMUMSS's docs: "If two mods edit the same MBIN by using an EXML, they will work fine provided they aren't editing the same value lines." Confirmed in-game with all five active. Keep the property lists disjoint when adding to any mod; if a new change needs a line another mod already owns, it belongs in that mod. AMUMSS's own conflict checker only compares at file level, so it will flag these; that warning is expected.

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

`build.ps1` copies every `scripts\*.lua` (except `_`-prefixed helpers) into AMUMSS's `ModScript` folder, runs AMUMSS unattended with the presets in `build\BUILDMOD_AUTO.bat`, then copies the produced mod folders from `CreatedMODS\` back into `mods\`. Pass `-Interactive` to run AMUMSS in its own window and answer its prompts yourself. A full build of all five mods takes about two minutes; the product table is the slow part. To retune, edit the numbers at the top of a script and rebuild.

To remove a mod, delete its folder from `GAMEDATA\MODS`. Nothing in the game install is permanently changed.

## Writing a script

Copy `scripts\_TEMPLATE.lua`, rename it, and fill in the tables. The template explains each field in plain English. To find property names and their current values, unpack the game's tables with AMUMSS (it keeps decompiled copies under `TOOLS\UNPACKED_DECOMPILED_PAKs`) and search the MXML.

Reference material:
- [Public script collection](https://github.com/MetaIdea/nms-amumss-lua-mod-script-collection) - hundreds of real scripts by author, plus a learning folder of commented examples. Gumsk's scripts are the cleanest model for "settings block at the top, tables below".
- [MBINCompiler releases](https://github.com/monkeyman192/MBINCompiler/releases) - watch this after a game update; nothing builds until it catches up.
- NMS Modding Discord, `#amumss-lua` channel, is where AMUMSS questions get answered.

## License

MIT - see [LICENSE](LICENSE).
