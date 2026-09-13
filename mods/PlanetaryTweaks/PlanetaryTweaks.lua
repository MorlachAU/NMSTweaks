--[[
  NMSTweaks - PlanetaryTweaks
  Planet-side gathering and exploration: mining beam, refiners, analysis
  visor, binoculars. Touches three tables:
    GCGAMEPLAYGLOBALS   refiner speed, visor scan times, ship mining yield
    GCPLAYERGLOBALS     mining beam rate, binocular ranges, terrain laser range
    GCTECHNOLOGYTABLE   mining beam heat/drain, visor recharge/radius/rewards

  GCPLAYERGLOBALS is also edited by MovementTweaks. Both mods ship as line
  patches (EXML), so they coexist as long as they never touch the same line.
  Keep the property lists disjoint.

  Every stock value below was read from the Cosmos 7.01 game data on
  2026-09-13. Tunables are multipliers on the stock value.
]]

-- ---------------------------------------------------------------- settings
local MOD_NAME    = "PlanetaryTweaks"
local NMS_VERSION = "7.01"

local REFINER_SPEED     = 3.0   -- refiner throughput (all refiner sizes, normal and survival)
local SCAN_TIME         = 0.5   -- time the visor needs to lock a scan (lower = faster)
local SCAN_RECHARGE     = 0.5   -- visor scan-pulse recharge time (lower = faster)
local SCAN_RADIUS       = 1.5   -- visor scan-pulse radius
local SCAN_REWARDS      = 3.0   -- units/nanites from scanning creatures, flora, minerals
local BINOC_RANGE       = 1.5   -- how far the visor can tag things, planet and space
local MINING_RATE       = 2.0   -- mining beam extraction rate
local MINING_HEAT_TIME  = 2.0   -- seconds of continuous mining before overheat
local MINING_DRAIN      = 0.5   -- mining beam energy drain
local MINING_COOLDOWN   = 0.5   -- overheat recovery time
local SHIP_MINING_YIELD = 2.0   -- asteroid mining yield from the ship
local TERRAIN_RANGE     = 1.5   -- terrain manipulator reach

-- ---------------------------------------------------------------- stock values
local STOCK = {
  -- GCGAMEPLAYGLOBALS
  RefinerProductsMadeInTime         = 2,      -- integer
  RefinerSubsMadeInTime             = 250,    -- integer
  RefinerProductsMadeInTimeSurvival = 1,      -- integer
  RefinerSubsMadeInTimeSurvival     = 100,    -- integer
  BinocTimeBeforeScan               = 0.5,
  BinocMinScanTime                  = 2.2,
  BinocScanTime                     = 2.2,
  BinocCreatureScanTime             = 1.9,
  CreatureMinScanTime               = 0.8,
  WaypointScanTime                  = 3.0,
  ShipMiningMul                     = 0.2,
  -- GCPLAYERGLOBALS
  LaserBeamMineRate                 = 0.3,
  BinocularRangePlanet              = 1000.0,
  BinocularRangeSpace               = 10000.0,
  TerrainLaserRange                 = 100.0,
  -- GCTECHNOLOGYTABLE, tech LASER (mining beam)
  Weapon_Laser_HeatTime             = 8.0,
  Weapon_Laser_ReloadTime           = 0.6,
  Weapon_Laser_Drain                = 1.2,
  -- GCTECHNOLOGYTABLE, tech SCAN1 (analysis visor)
  Weapon_Scan_Radius                = 1.0,
  Weapon_Scan_Recharge_Time         = 1.0,
  Weapon_Scan_Discovery_Creature    = 1.0,
  Weapon_Scan_Discovery_Flora       = 1.0,
  Weapon_Scan_Discovery_Mineral     = 1.0,
}

local function f(name, factor) return string.format("%.6f", STOCK[name] * factor) end
local function i(name, factor) return string.format("%d", math.floor(STOCK[name] * factor + 0.5)) end

-- One tech-table stat bonus: find the tech by ID, then the stat by name, then
-- edit the Bonus that follows it. Same pattern as the AMUMSS learning examples.
local function techBonus(techId, statName, value)
  return {
    ["SPECIAL_KEY_WORDS"]   = {"ID", techId},
    ["PRECEDING_KEY_WORDS"] = statName,
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
  ["MOD_DESCRIPTION"] = "Faster mining, refining and scanning; better scan rewards; longer visor range",
  ["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        -- ---------------------------------------------- gameplay globals
        {
          ["MBIN_FILE_SOURCE"] = "GCGAMEPLAYGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              -- integers: no float forcing here
              ["VALUE_CHANGE_TABLE"] =
              {
                {"RefinerProductsMadeInTime",         i("RefinerProductsMadeInTime", REFINER_SPEED)},         -- Original 2
                {"RefinerSubsMadeInTime",             i("RefinerSubsMadeInTime", REFINER_SPEED)},             -- Original 250
                {"RefinerProductsMadeInTimeSurvival", i("RefinerProductsMadeInTimeSurvival", REFINER_SPEED)}, -- Original 1
                {"RefinerSubsMadeInTimeSurvival",     i("RefinerSubsMadeInTimeSurvival", REFINER_SPEED)},     -- Original 100
              },
            },
            {
              ["INTEGER_TO_FLOAT"] = "FORCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"BinocTimeBeforeScan",   f("BinocTimeBeforeScan", SCAN_TIME)},   -- Original 0.500000
                {"BinocMinScanTime",      f("BinocMinScanTime", SCAN_TIME)},      -- Original 2.200000
                {"BinocScanTime",         f("BinocScanTime", SCAN_TIME)},         -- Original 2.200000
                {"BinocCreatureScanTime", f("BinocCreatureScanTime", SCAN_TIME)}, -- Original 1.900000
                {"CreatureMinScanTime",   f("CreatureMinScanTime", SCAN_TIME)},   -- Original 0.800000
                {"WaypointScanTime",      f("WaypointScanTime", SCAN_TIME)},      -- Original 3.000000
                {"ShipMiningMul",         f("ShipMiningMul", SHIP_MINING_YIELD)}, -- Original 0.200000
              },
            },
          },
        },
        -- ---------------------------------------------- player globals
        -- Disjoint from MovementTweaks (jetpack, sprint, stamina lines).
        {
          ["MBIN_FILE_SOURCE"] = "GCPLAYERGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["INTEGER_TO_FLOAT"] = "FORCE",
              ["VALUE_CHANGE_TABLE"] =
              {
                {"LaserBeamMineRate",    f("LaserBeamMineRate", MINING_RATE)},    -- Original 0.300000
                {"BinocularRangePlanet", f("BinocularRangePlanet", BINOC_RANGE)}, -- Original 1000.000000
                {"BinocularRangeSpace",  f("BinocularRangeSpace", BINOC_RANGE)},  -- Original 10000.000000
                {"TerrainLaserRange",    f("TerrainLaserRange", TERRAIN_RANGE)},  -- Original 100.000000
              },
            },
          },
        },
        -- ---------------------------------------------- technology table
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\REALITY\TABLES\NMS_REALITY_GCTECHNOLOGYTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            -- Mining beam
            techBonus("LASER", "Weapon_Laser_HeatTime",   f("Weapon_Laser_HeatTime", MINING_HEAT_TIME)),  -- Original 8.000000
            techBonus("LASER", "Weapon_Laser_ReloadTime", f("Weapon_Laser_ReloadTime", MINING_COOLDOWN)), -- Original 0.600000
            techBonus("LASER", "Weapon_Laser_Drain",      f("Weapon_Laser_Drain", MINING_DRAIN)),         -- Original 1.200000
            -- Analysis visor
            techBonus("SCAN1", "Weapon_Scan_Radius",             f("Weapon_Scan_Radius", SCAN_RADIUS)),               -- Original 1.000000
            techBonus("SCAN1", "Weapon_Scan_Recharge_Time",      f("Weapon_Scan_Recharge_Time", SCAN_RECHARGE)),      -- Original 1.000000
            techBonus("SCAN1", "Weapon_Scan_Discovery_Creature", f("Weapon_Scan_Discovery_Creature", SCAN_REWARDS)),  -- Original 1.000000
            techBonus("SCAN1", "Weapon_Scan_Discovery_Flora",    f("Weapon_Scan_Discovery_Flora", SCAN_REWARDS)),     -- Original 1.000000
            techBonus("SCAN1", "Weapon_Scan_Discovery_Mineral",  f("Weapon_Scan_Discovery_Mineral", SCAN_REWARDS)),   -- Original 1.000000
          },
        },
      },
    },
  },
}