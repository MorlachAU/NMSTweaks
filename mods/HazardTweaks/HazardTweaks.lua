--[[
  NMSTweaks - HazardTweaks
  Surviving planets: hazard protection, life support, and the exocraft/mech
  equivalents. Touches two tables:
    GCPLAYERGLOBALS     difficulty-mode hazard drain/recharge/damage
                        multipliers, life-support discharge rates, solar regen
    GCTECHNOLOGYTABLE   base suit techs PROTECT (hazard) and ENERGY (life
                        support), exocraft EXO_PROT_* and Minotaur MECH_PROT

  GCPLAYERGLOBALS is shared with MovementTweaks and PlanetaryTweaks. Line
  patches merge as long as no two mods edit the same line, so the property
  list here must stay disjoint from both.

  Every stock value below was read from the Cosmos 7.01 game data on
  2026-09-13. Tunables are multipliers on the stock value.

  Semantics, checked against the table's own Normal/Hard mode pairs:
    HazardTimeMultiplier      higher = protection lasts longer (Hard 0.3 < Normal 0.9)
    HazardRechargeUnderground higher = recharges faster when sheltered
    HazardDamageRateMultiplier lower = less damage once protection is gone
    EnergyDischargeRate*      lower = life support drains slower
]]

-- ---------------------------------------------------------------- settings
local MOD_NAME    = "HazardTweaks"
local NMS_VERSION = "7.01"

local HAZARD_DURATION   = 2.0   -- how long hazard protection lasts in the open
local HAZARD_RECHARGE   = 2.0   -- recharge speed when sheltered (caves, buildings)
local HAZARD_DAMAGE     = 0.5   -- damage taken once protection is depleted
local HAZARD_CAPACITY   = 2.0   -- base suit hazard protection stat (PROTECT tech)
local PRESSURE_CAPACITY = 2.0   -- underwater pressure protection (PROTECT tech)
local LIFE_SUPPORT_CAP  = 2.0   -- life support capacity and regen (ENERGY tech)
local LIFE_SUPPORT_DRAIN = 0.5  -- life support discharge, all situations
local SOLAR_REGEN       = 2.0   -- daylight trickle recharge of life support
local EXOCRAFT_PROT     = 2.0   -- exocraft hazard protection modules (all four hazards)
local MECH_PROT         = 2.0   -- Minotaur built-in hazard protection

-- ---------------------------------------------------------------- stock values
local STOCK = {
  -- GCPLAYERGLOBALS
  NormalModeHazardTimeMultiplier            = 0.9,
  NormalModeHazardRechargeUnderground       = 1.5,
  NormalModeHazardDamageRateMultiplier      = 0.8,
  NormalModeHazardDamageWoundRateMultiplier = 0.8,
  HardModeHazardTimeMultiplier              = 0.3,
  HardModeHazardRechargeUnderground         = 3.5,
  HardModeHazardDamageRateMultiplier        = 0.3,
  HardModeHazardDamageWoundRateMultiplier   = 0.5,
  EnergyDischargeRateLow                    = 0.02,
  EnergyDischargeRateMedium                 = 0.25,
  EnergyDischargeRateHigh                   = 0.9,
  EnergyDischargeRateFloatingInSpace        = 0.2,
  EnergyDischargeRateDeepWater              = 3.0,
  SolarRegenFactor                          = 0.01,
  -- GCTECHNOLOGYTABLE
  Suit_Protection          = 1.0,   -- PROTECT
  Suit_Protection_Pressure = 1.0,   -- PROTECT
  Suit_Energy              = 1.0,   -- ENERGY
  Suit_Energy_Regen        = 1.0,   -- ENERGY
  Exo_Protection           = 3.0,   -- EXO_PROT_COLD/HOT/RAD/TOX, one stat each
  Mech_Protection          = 1.0,   -- MECH_PROT, four stats
}

local function f(name, factor) return string.format("%.6f", STOCK[name] * factor) end

-- Tech-table stat bonus: find the tech by ID, anchor on the stat name, go up
-- one section, change the next Bonus. Same pattern as PlanetaryTweaks.
local function techBonus(techId, preceding, value)
  return {
    ["SPECIAL_KEY_WORDS"]   = {"ID", techId},
    ["PRECEDING_KEY_WORDS"] = preceding,
    ["SECTION_UP"]          = 1,
    ["INTEGER_TO_FLOAT"]    = "FORCE",
    ["VALUE_CHANGE_TABLE"]  = { {"Bonus", value} },
  }
end

-- ---------------------------------------------------------------- definition
NMS_MOD_DEFINITION_CONTAINER =
{
  ["MOD_FILENAME"]    = MOD_NAME,
  ["MOD_AUTHOR"]      = "MorlachAU",
  ["LUA_AUTHOR"]      = "MorlachAU",
  ["NMS_VERSION"]     = NMS_VERSION,
  ["MOD_DESCRIPTION"] = "Hazard protection lasts longer and recharges faster; life support drains slower; exocraft and Minotaur protection doubled",
  ["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        -- ---------------------------------------------- player globals
        -- Disjoint from MovementTweaks (jetpack/sprint/stamina) and
        -- PlanetaryTweaks (mining beam, binocular range, terrain range).
        {
          ["MBIN_FILE_SOURCE"] = "GCPLAYERGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["INTEGER_TO_FLOAT"] = "FORCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"NormalModeHazardTimeMultiplier",            f("NormalModeHazardTimeMultiplier", HAZARD_DURATION)},            -- Original 0.900000
                {"NormalModeHazardRechargeUnderground",       f("NormalModeHazardRechargeUnderground", HAZARD_RECHARGE)},       -- Original 1.500000
                {"NormalModeHazardDamageRateMultiplier",      f("NormalModeHazardDamageRateMultiplier", HAZARD_DAMAGE)},        -- Original 0.800000
                {"NormalModeHazardDamageWoundRateMultiplier", f("NormalModeHazardDamageWoundRateMultiplier", HAZARD_DAMAGE)},   -- Original 0.800000
                {"HardModeHazardTimeMultiplier",              f("HardModeHazardTimeMultiplier", HAZARD_DURATION)},              -- Original 0.300000
                {"HardModeHazardRechargeUnderground",         f("HardModeHazardRechargeUnderground", HAZARD_RECHARGE)},         -- Original 3.500000
                {"HardModeHazardDamageRateMultiplier",        f("HardModeHazardDamageRateMultiplier", HAZARD_DAMAGE)},          -- Original 0.300000
                {"HardModeHazardDamageWoundRateMultiplier",   f("HardModeHazardDamageWoundRateMultiplier", HAZARD_DAMAGE)},     -- Original 0.500000
                {"EnergyDischargeRateLow",                    f("EnergyDischargeRateLow", LIFE_SUPPORT_DRAIN)},                 -- Original 0.020000
                {"EnergyDischargeRateMedium",                 f("EnergyDischargeRateMedium", LIFE_SUPPORT_DRAIN)},              -- Original 0.250000
                {"EnergyDischargeRateHigh",                   f("EnergyDischargeRateHigh", LIFE_SUPPORT_DRAIN)},                -- Original 0.900000
                {"EnergyDischargeRateFloatingInSpace",        f("EnergyDischargeRateFloatingInSpace", LIFE_SUPPORT_DRAIN)},     -- Original 0.200000
                {"EnergyDischargeRateDeepWater",              f("EnergyDischargeRateDeepWater", LIFE_SUPPORT_DRAIN)},           -- Original 3.000000
                {"SolarRegenFactor",                          f("SolarRegenFactor", SOLAR_REGEN)},                              -- Original 0.010000
              },
            },
          },
        },
        -- ---------------------------------------------- technology table
        -- Disjoint from PlanetaryTweaks (LASER and SCAN1 entries).
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\REALITY\TABLES\NMS_REALITY_GCTECHNOLOGYTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            -- Base suit hazard protection. Suit_Protection also appears as the
            -- tech's BaseStat a few lines earlier; AMUMSS anchors on that first
            -- hit and searches forward, and the next Bonus is the right one.
            -- (A two-step keyword list does NOT work here: AMUMSS skips the edit.)
            techBonus("PROTECT", "Suit_Protection",          f("Suit_Protection", HAZARD_CAPACITY)),            -- Original 1.000000
            techBonus("PROTECT", "Suit_Protection_Pressure", f("Suit_Protection_Pressure", PRESSURE_CAPACITY)), -- Original 1.000000
            -- Base suit life support. Same BaseStat shape.
            techBonus("ENERGY",  "Suit_Energy",              f("Suit_Energy", LIFE_SUPPORT_CAP)),               -- Original 1.000000
            techBonus("ENERGY",  "Suit_Energy_Regen",        f("Suit_Energy_Regen", LIFE_SUPPORT_CAP)),         -- Original 1.000000
            -- Exocraft hazard modules (one hazard each). Untested: no exocraft yet.
            techBonus("EXO_PROT_COLD", "Suit_Protection_Cold",      f("Exo_Protection", EXOCRAFT_PROT)),   -- Original 3.000000
            techBonus("EXO_PROT_HOT",  "Suit_Protection_Heat",      f("Exo_Protection", EXOCRAFT_PROT)),   -- Original 3.000000
            techBonus("EXO_PROT_RAD",  "Suit_Protection_Radiation", f("Exo_Protection", EXOCRAFT_PROT)),   -- Original 3.000000
            techBonus("EXO_PROT_TOX",  "Suit_Protection_Toxic",     f("Exo_Protection", EXOCRAFT_PROT)),   -- Original 3.000000
            -- Minotaur built-in protection (all four hazards). Untested: no Minotaur yet.
            techBonus("MECH_PROT", "Suit_Protection_Cold",      f("Mech_Protection", MECH_PROT)),   -- Original 1.000000
            techBonus("MECH_PROT", "Suit_Protection_Heat",      f("Mech_Protection", MECH_PROT)),   -- Original 1.000000
            techBonus("MECH_PROT", "Suit_Protection_Radiation", f("Mech_Protection", MECH_PROT)),   -- Original 1.000000
            techBonus("MECH_PROT", "Suit_Protection_Toxic",     f("Mech_Protection", MECH_PROT)),   -- Original 1.000000
          },
        },
      },
    },
  },
}