--[[
  NMSTweaks - ShipTweaks
  Starship systems: hyperdrive range and fuel, launch cost, pulse drive speed
  and fuel, boost and handling, shield strength, scanner recharge, and raw
  flight speed. Touches three tables:
    GCTECHNOLOGYTABLE   base ship techs and their alien/robot/special variants
    GCGAMEPLAYGLOBALS   ship scanner recharge multipliers
    GCSPACESHIPGLOBALS  per-control-type engine speeds (6 control types x 4 modes)

  GCGAMEPLAYGLOBALS is shared with PlanetaryTweaks and the technology table
  with PlanetaryTweaks and HazardTweaks. Line patches merge as long as no two
  mods edit the same line; this mod's lines are disjoint from all of them.

  Every stock value below was read from the Cosmos 7.01 game data on
  2026-09-14. Tunables are multipliers on the stock value.

  Semantics notes:
    JumpDistance      light-years per warp (100 base)
    JumpsPerCell      warps one warp cell provides
    TakeOffCost       percent of launch thruster fuel used per launch
    MiniJumpSpeed     pulse drive speed multiplier
    MiniJumpFuelSpending  pulse drive fuel multiplier (lower = cheaper)
    Ship_Boost / Ship_Maneuverability  boost and handling multipliers
    ScanRechargeMultiplier  scales scanner cooldown; space is 0.3 vs planet
                      1.0 and the scanner is known to recharge faster in
                      space, so lower = faster (inferred from the data)
]]

-- ---------------------------------------------------------------- settings
local MOD_NAME    = "ShipTweaks"
local NMS_VERSION = "7.01"

local WARP_RANGE       = 3.0   -- hyperdrive jump distance
local WARPS_PER_CELL   = 2.0   -- jumps per warp cell
local LAUNCH_COST      = 0.5   -- launch thruster fuel per take-off
local PULSE_SPEED      = 2.0   -- pulse drive speed
local PULSE_FUEL       = 0.5   -- pulse drive fuel use
local BOOST            = 1.25  -- boost strength
local MANEUVERABILITY  = 1.25  -- handling
local SHIELD_STRENGTH  = 2.0   -- ship shield strength
local SCAN_RECHARGE    = 0.5   -- ship scanner cooldown (lower = faster)
local FLIGHT_SPEED     = 1.5   -- normal and boost top speed and thrust, all
                               -- ship types, space / planet / combat / atmosphere combat

-- ---------------------------------------------------------------- stock values
-- techId, stat, stock bonus
local TECH = {
  -- hyperdrive
  {"HYPERDRIVE",      "Ship_Hyperdrive_JumpDistance", 100.0, WARP_RANGE},
  {"HYPERDRIVE",      "Ship_Hyperdrive_JumpsPerCell",   1.0, WARPS_PER_CELL},
  {"HYPERDRIVE_ROBO", "Ship_Hyperdrive_JumpDistance", 600.0, WARP_RANGE},
  {"HYPERDRIVE_ROBO", "Ship_Hyperdrive_JumpsPerCell",   2.0, WARPS_PER_CELL},
  {"HYPERDRIVE_SPEC", "Ship_Hyperdrive_JumpDistance", 600.0, WARP_RANGE},
  {"HYPERDRIVE_SPEC", "Ship_Hyperdrive_JumpsPerCell",   2.0, WARPS_PER_CELL},
  {"WARP_ALIEN",      "Ship_Hyperdrive_JumpDistance", 100.0, WARP_RANGE},
  {"WARP_ALIEN",      "Ship_Hyperdrive_JumpsPerCell",   1.0, WARPS_PER_CELL},
  -- launch thruster
  {"LAUNCHER",        "Ship_Launcher_TakeOffCost", 50.0, LAUNCH_COST},
  {"LAUNCHER_ALIEN",  "Ship_Launcher_TakeOffCost", 50.0, LAUNCH_COST},
  {"LAUNCHER_ROBO",   "Ship_Launcher_TakeOffCost", 25.0, LAUNCH_COST},
  {"LAUNCHER_SPEC",   "Ship_Launcher_TakeOffCost", 25.0, LAUNCH_COST},
  -- pulse drive (SHIPJUMP_SPEC lists Ship_Maneuverability twice; the first,
  -- 1.1, is the one edited)
  {"SHIPJUMP1",       "Ship_PulseDrive_MiniJumpSpeed",        1.0, PULSE_SPEED},
  {"SHIPJUMP1",       "Ship_PulseDrive_MiniJumpFuelSpending", 1.0, PULSE_FUEL},
  {"SHIPJUMP1",       "Ship_Boost",                         100.0, BOOST},
  {"SHIPJUMP1",       "Ship_Maneuverability",                 1.0, MANEUVERABILITY},
  {"SHIPJUMP_ALIEN",  "Ship_PulseDrive_MiniJumpSpeed",        1.0, PULSE_SPEED},
  {"SHIPJUMP_ALIEN",  "Ship_PulseDrive_MiniJumpFuelSpending", 0.5, PULSE_FUEL},
  {"SHIPJUMP_ALIEN",  "Ship_Boost",                         100.0, BOOST},
  {"SHIPJUMP_ALIEN",  "Ship_Maneuverability",                 1.0, MANEUVERABILITY},
  {"SHIPJUMP_ROBO",   "Ship_PulseDrive_MiniJumpSpeed",        1.1, PULSE_SPEED},
  {"SHIPJUMP_ROBO",   "Ship_PulseDrive_MiniJumpFuelSpending", 1.0, PULSE_FUEL},
  {"SHIPJUMP_ROBO",   "Ship_Boost",                         120.0, BOOST},
  {"SHIPJUMP_ROBO",   "Ship_Maneuverability",                 1.0, MANEUVERABILITY},
  {"SHIPJUMP_SPEC",   "Ship_PulseDrive_MiniJumpSpeed",        1.0, PULSE_SPEED},
  {"SHIPJUMP_SPEC",   "Ship_PulseDrive_MiniJumpFuelSpending", 1.0, PULSE_FUEL},
  {"SHIPJUMP_SPEC",   "Ship_Boost",                         120.0, BOOST},
  {"SHIPJUMP_SPEC",   "Ship_Maneuverability",                 1.1, MANEUVERABILITY},
  -- shield
  {"SHIPSHIELD",      "Ship_Armour_Shield_Strength", 0.65, SHIELD_STRENGTH},
  {"SHIPSHIELD_ROBO", "Ship_Armour_Shield_Strength", 0.65, SHIELD_STRENGTH},
  {"SHIELD_ALIEN",    "Ship_Armour_Shield_Strength", 0.65, SHIELD_STRENGTH},
}

local CONTROL_TYPES = {"Control", "ControlLight", "ControlHeavy", "ControlHeavyHover", "ControlCorvette", "ControlHover"}
local ENGINES       = {"SpaceEngine", "PlanetEngine", "CombatEngine", "AtmosCombatEngine"}

local STOCK = {
  ShipScanPlanetRechargeMultiplier = 1.0,
  ShipScanSpaceRechargeMultiplier  = 0.3,
}

local function f(v) return string.format("%.6f", v) end

-- ---------------------------------------------------------------- change lists
local techChanges = {}
for _, t in ipairs(TECH) do
  local id, stat, stock, factor = t[1], t[2], t[3], t[4]
  techChanges[#techChanges + 1] = {
    ["SPECIAL_KEY_WORDS"]   = {"ID", id},
    ["PRECEDING_KEY_WORDS"] = stat,
    ["SECTION_UP"]          = 1,
    ["INTEGER_TO_FLOAT"]    = "FORCE",
    ["VALUE_CHANGE_TABLE"]  = { {"Bonus", f(stock * factor)} },
  }
end

-- Engine speeds: anchor on the control block, then the engine name inside
-- it, and multiply the four speed/thrust fields that follow.
local engineChanges = {}
for _, ctrl in ipairs(CONTROL_TYPES) do
  for _, eng in ipairs(ENGINES) do
    engineChanges[#engineChanges + 1] = {
      ["SPECIAL_KEY_WORDS"]   = {ctrl, "GcPlayerSpaceshipControlData"},
      ["PRECEDING_KEY_WORDS"] = eng,
      ["MATH_OPERATION"]      = "*",
      ["INTEGER_TO_FLOAT"]    = "FORCE",
      ["VALUE_CHANGE_TABLE"]  = {
        {"ThrustForce",      FLIGHT_SPEED},
        {"MaxSpeed",         FLIGHT_SPEED},
        {"BoostThrustForce", FLIGHT_SPEED},
        {"BoostMaxSpeed",    FLIGHT_SPEED},
      },
    }
  end
end

-- ---------------------------------------------------------------- definition
NMS_MOD_DEFINITION_CONTAINER =
{
  ["MOD_FILENAME"]    = MOD_NAME,
  ["MOD_AUTHOR"]      = "MorlachAU",
  ["LUA_AUTHOR"]      = "MorlachAU",
  ["NMS_VERSION"]     = NMS_VERSION,
  ["MOD_DESCRIPTION"] = "Longer warps, cheaper launches, faster pulse drive and flight, stronger shields, quicker scanner",
  ["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\\REALITY\\TABLES\\NMS_REALITY_GCTECHNOLOGYTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] = techChanges,
        },
        {
          ["MBIN_FILE_SOURCE"] = "GCGAMEPLAYGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["INTEGER_TO_FLOAT"] = "FORCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"ShipScanPlanetRechargeMultiplier", f(STOCK.ShipScanPlanetRechargeMultiplier * SCAN_RECHARGE)}, -- Original 1.000000
                {"ShipScanSpaceRechargeMultiplier",  f(STOCK.ShipScanSpaceRechargeMultiplier  * SCAN_RECHARGE)}, -- Original 0.300000
              },
            },
          },
        },
        {
          ["MBIN_FILE_SOURCE"] = "GCSPACESHIPGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] = engineChanges,
        },
      },
    },
  },
}
