--[[
  NMSTweaks - AMUMSS script template
  ----------------------------------
  This file is SOURCE. AMUMSS reads it and produces a mod folder that the
  game loads from GAMEDATA\MODS. Think of it like the Riftbreaker build.ps1:
  the numbers live here, the generated files are the deliverable.

  How AMUMSS reads this file, in plain English:
    1. MBIN_FILE_SOURCE names one of the game's binary data tables.
    2. AMUMSS unpacks it to readable MXML text (via MBINCompiler).
    3. Each entry in MXML_CHANGE_TABLE finds a spot in that text and edits it.
    4. AMUMSS repacks the result into GAMEDATA\MODS\<MOD_FILENAME>\...

  Finding a spot:
    SPECIAL_KEY_WORDS   = {"Name", "Value"}  -> jump to the section where the
                           property called Name has that Value (e.g. an ID).
    PRECEDING_KEY_WORDS = "SomeSection"      -> start looking after this word.
    VALUE_CHANGE_TABLE  = {{"Property", newValue}, ...} -> the actual edits.
    Leave PRECEDING_KEY_WORDS and SPECIAL_KEY_WORDS out to edit the first
    match in the whole file (fine for GLOBALS files, which are flat lists).

  Multiplying instead of setting: AMUMSS also accepts MATH_OPERATION = "*"
  with the value as the factor - see the learning collection linked in the
  README before relying on it.

  Copy this file, rename it (no leading underscore), fill in the blanks.
  Always keep the ORIGINAL value in a comment so retuning is easy.
]]

-- ---------------------------------------------------------------- settings
-- Put every tunable number up here, Riftbreaker-style. The tables below only
-- reference these names, so retuning never means hunting through the tables.
local MOD_NAME    = "ExampleTweak"      -- becomes the mod folder name
local NMS_VERSION = "7.01"              -- game version this was written against

local EXAMPLE_VALUE = "1.0"             -- Original "0.62"

-- ------------------------------------------------------------ definition
NMS_MOD_DEFINITION_CONTAINER =
{
  ["MOD_FILENAME"]    = MOD_NAME,
  ["MOD_AUTHOR"]      = "MorlachAU",
  ["LUA_AUTHOR"]      = "MorlachAU",
  ["NMS_VERSION"]     = NMS_VERSION,
  ["MOD_DESCRIPTION"] = "Describe what this changes and why",
  ["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          -- One of the game's data tables. GLOBALS files sit at the root of
          -- the unpacked game data; most other things live under METADATA\.
          ["MBIN_FILE_SOURCE"] = "GCSKYGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["VALUE_CHANGE_TABLE"] =
              {
                {"MinNightFade", EXAMPLE_VALUE},   -- Original "0.62"
              },
            },
          },
        },
        -- Add another { MBIN_FILE_SOURCE = ..., MXML_CHANGE_TABLE = {...} }
        -- block here to edit a second table in the same mod.
      },
    },
  },
}
