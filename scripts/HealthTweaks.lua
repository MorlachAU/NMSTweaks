--[[
  NMSTweaks - HealthTweaks
  Health and shield: bigger shield, faster shield and health regen, shorter
  delays before regen starts, full health bar from the start, harder to wound.
  One table: GCPLAYERGLOBALS.

  GCPLAYERGLOBALS is shared with MovementTweaks, PlanetaryTweaks and
  HazardTweaks. Line patches merge as long as no two mods edit the same line,
  so this property list must stay disjoint from all three.

  Every stock value below was read from the Cosmos 7.01 game data on
  2026-09-13. Tunables are multipliers unless marked absolute.
]]

-- ---------------------------------------------------------------- settings
local MOD_NAME    = "HealthTweaks"
local NMS_VERSION = "7.01"

local HEALTH_PIPS_START  = 9     -- ABSOLUTE: health pips at game start (stock 3, game max 9)
local HEALTH_REGEN_RATE  = 2.0   -- health pip recharge speed
local HEALTH_REGEN_DELAY = 0.5   -- seconds after damage before health regen starts
local SHIELD_CAPACITY    = 2.0   -- shield maximum
local SHIELD_REGEN_RATE  = 2.0   -- shield restore/recharge speed
local SHIELD_REGEN_DELAY = 0.5   -- seconds after damage before shield regen starts
local WOUND_THRESHOLD    = 2.0   -- damage needed in one hit to inflict a wound
local WOUND_DECAY        = 0.5   -- how long wounds linger

-- ---------------------------------------------------------------- stock values
local STOCK = {
  DefaultHealthPips                = 3,      -- integer
  HealthPipRechargeRate            = 200.0,
  HealthRechargeMinTimeSinceDamage = 10.0,
  ShieldMaximum                    = 100,    -- integer
  ShieldRestoreSpeed               = 0.2,
  ShieldRestoreDelay               = 10.0,
  ShieldRechargeRate               = 10.0,
  ShieldRechargeMinTimeSinceDamage = 30.0,
  WoundDamageLimit                 = 75.0,
  WoundDamageDecayTime             = 20.0,
}

local function f(name, factor) return string.format("%.6f", STOCK[name] * factor) end
local function i(name, factor) return string.format("%d", math.floor(STOCK[name] * factor + 0.5)) end

-- ---------------------------------------------------------------- definition
NMS_MOD_DEFINITION_CONTAINER =
{
  ["MOD_FILENAME"]    = MOD_NAME,
  ["MOD_AUTHOR"]      = "MorlachAU",
  ["LUA_AUTHOR"]      = "MorlachAU",
  ["NMS_VERSION"]     = NMS_VERSION,
  ["MOD_DESCRIPTION"] = "Bigger shield, faster health and shield regen, full health bar from the start, harder to wound",
  ["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "GCPLAYERGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              -- integers: no float forcing
              ["VALUE_CHANGE_TABLE"] =
              {
                {"DefaultHealthPips", string.format("%d", HEALTH_PIPS_START)},   -- Original 3
                {"ShieldMaximum",     i("ShieldMaximum", SHIELD_CAPACITY)},      -- Original 100
              },
            },
            {
              ["INTEGER_TO_FLOAT"] = "FORCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"HealthPipRechargeRate",            f("HealthPipRechargeRate", HEALTH_REGEN_RATE)},             -- Original 200.000000
                {"HealthRechargeMinTimeSinceDamage", f("HealthRechargeMinTimeSinceDamage", HEALTH_REGEN_DELAY)}, -- Original 10.000000
                {"ShieldRestoreSpeed",               f("ShieldRestoreSpeed", SHIELD_REGEN_RATE)},                -- Original 0.200000
                {"ShieldRestoreDelay",               f("ShieldRestoreDelay", SHIELD_REGEN_DELAY)},               -- Original 10.000000
                {"ShieldRechargeRate",               f("ShieldRechargeRate", SHIELD_REGEN_RATE)},                -- Original 10.000000
                {"ShieldRechargeMinTimeSinceDamage", f("ShieldRechargeMinTimeSinceDamage", SHIELD_REGEN_DELAY)}, -- Original 30.000000
                {"WoundDamageLimit",                 f("WoundDamageLimit", WOUND_THRESHOLD)},                    -- Original 75.000000
                {"WoundDamageDecayTime",             f("WoundDamageDecayTime", WOUND_DECAY)},                    -- Original 20.000000
              },
            },
          },
        },
      },
    },
  },
}
