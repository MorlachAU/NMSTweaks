--[[
  NMSTweaks - MovementTweaks
  On-foot movement: faster jetpack recharge, cheaper horizontal jetpack flight,
  faster sprint that drains less stamina. Single table, GCPLAYERGLOBALS.

  Every value below was read from the Cosmos 7.01 game data on 2026-09-13.
  Tunables are multipliers on the stock value; the tables at the bottom only
  reference them. Retune here, rebuild, redeploy.
]]

-- ---------------------------------------------------------------- settings
local MOD_NAME    = "MovementTweaks"
local NMS_VERSION = "7.01"

local JETPACK_REFILL       = 2.0   -- jetpack recharge rate on the ground and mid-air
local JETPACK_HORIZ_DRAIN  = 0.5   -- extra drain while flying forwards (lower = cheaper)
local SPRINT_SPEED         = 1.5   -- ground running speed (walk untouched)
local STAMINA_DRAIN        = 0.5   -- stamina used per second while sprinting
local STAMINA_RECOVERY     = 2.0   -- stamina regained per second when not sprinting

-- ---------------------------------------------------------------- stock values
-- Kept as a reference and as the base the multipliers apply to.
local STOCK = {
  JetpackFillRate             = 0.5,
  JetpackFillRateMidair       = 0.25,
  JetpackDrainHorizontalFactor = 2.5,
  GroundRunSpeed              = 8.0,
  GroundRunSpeedLowG          = 3.5,
  StaminaRate                 = 0.1,
  StaminaRecoveryRate         = 0.1,
}

local function scaled(name, factor)
  return string.format("%.6f", STOCK[name] * factor)
end

-- ---------------------------------------------------------------- definition
NMS_MOD_DEFINITION_CONTAINER =
{
  ["MOD_FILENAME"]    = MOD_NAME,
  ["MOD_AUTHOR"]      = "MorlachAU",
  ["LUA_AUTHOR"]      = "MorlachAU",
  ["NMS_VERSION"]     = NMS_VERSION,
  ["MOD_DESCRIPTION"] = "Jetpack recharges faster and flies further, sprint is faster and cheaper",
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
              -- GLOBALS files are flat: every property name here is unique,
              -- so no section keywords are needed.
              ["INTEGER_TO_FLOAT"] = "FORCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"JetpackFillRate",              scaled("JetpackFillRate", JETPACK_REFILL)},               -- Original 0.500000
                {"JetpackFillRateMidair",        scaled("JetpackFillRateMidair", JETPACK_REFILL)},         -- Original 0.250000
                {"JetpackDrainHorizontalFactor", scaled("JetpackDrainHorizontalFactor", JETPACK_HORIZ_DRAIN)}, -- Original 2.500000
                {"GroundRunSpeed",               scaled("GroundRunSpeed", SPRINT_SPEED)},                  -- Original 8.000000
                {"GroundRunSpeedLowG",           scaled("GroundRunSpeedLowG", SPRINT_SPEED)},              -- Original 3.500000
                {"StaminaRate",                  scaled("StaminaRate", STAMINA_DRAIN)},                    -- Original 0.100000
                {"StaminaRecoveryRate",          scaled("StaminaRecoveryRate", STAMINA_RECOVERY)},         -- Original 0.100000
              },
            },
          },
        },
      },
    },
  },
}
