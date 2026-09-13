--[[
  NMSTweaks - InventoryTweaks
  Carry more: bigger stacks for every product and substance, new ships /
  multi-tools / freighters always generate with their maximum slot count,
  and cheaper slot purchases. Touches four tables:
    NMS_REALITY_GCPRODUCTTABLE     StackMultiplier on every product
    NMS_REALITY_GCSUBSTANCETABLE   StackMultiplier on every substance
    INVENTORYTABLE                 slot generation ranges per inventory size type
    GCPLAYERGLOBALS                slot purchase cost bases (ships, weapons, freighters)

  What applies to an existing save:
    stack sizes and slot costs   immediately
    slot generation              only to inventories created after the mod is
                                 installed (a new ship, tool or freighter);
                                 your current ones keep their slots
    exosuit                      not touched here; exosuit slots come from
                                 drop pods and station purchases

  GCPLAYERGLOBALS is shared with Movement, Planetary, Hazard and Health.
  Line patches merge as long as no two mods edit the same line; keep the
  property list here disjoint from all of them.

  Every stock value below was read from the Cosmos 7.01 game data on
  2026-09-13.
]]

-- ---------------------------------------------------------------- settings
local MOD_NAME    = "InventoryTweaks"
local NMS_VERSION = "7.01"

local STACK_PRODUCTS   = 5     -- multiply every product's stack size (non-stackables stay 0)
local STACK_SUBSTANCES = 5     -- multiply every substance's stack size
local SLOT_COST        = 0.5   -- base cost per slot when buying ship/weapon/freighter slots

-- Slot generation: every inventory size type rolls between Min and Max
-- slots when created. Setting Min = Max guarantees the best roll. Values
-- are the stock maximums; raise MAX_BOOST above 1.0 to go beyond them, but
-- the grid bounds in the same table cap what the game will actually lay out.
local MAX_BOOST = 1.0

-- ---------------------------------------------------------------- stock values
-- name, stock MaxSlots, stock MaxTechSlots  (from INVENTORYTABLE GenerationDataPerSizeType)
local SIZE_TYPES = {
  {"SciSmall",       29, 19}, {"SciMedium",      32, 24}, {"SciLarge",      38, 30},
  {"FgtSmall",       28, 19}, {"FgtMedium",      32, 24}, {"FgtLarge",      38, 30},
  {"ShuSmall",       32, 19}, {"ShtMedium",      36, 26}, {"ShtLarge",      42, 28},
  {"DrpSmall",       36, 18}, {"DrpMedium",      40, 24}, {"DrpLarge",      48, 30},
  {"RoySmall",       30, 19}, {"RoyMedium",      30, 28}, {"RoyLarge",      32, 30},
  {"AlienSmall",     36, 30}, {"AlienMedium",    36, 30}, {"AlienLarge",    36, 30},
  {"SailSmall",      30, 18}, {"SailMedium",     32, 22}, {"SailLarge",     36, 30},
  {"RobotSmall",     40, 28}, {"RobotMedium",    40, 28}, {"RobotLarge",    40, 28},
  {"WeaponSmall",    18, 18}, {"WeaponMedium",   20, 20}, {"WeaponLarge",   30, 30},
  {"FreighterSmall", 19, 12}, {"FreighterMedium",34, 20}, {"FreighterLarge",48, 30},
  {"Corvette",       48, 30},
}

local STOCK = {
  ShipBaseCostPerSlot      = 1.0,
  WeaponBaseCostPerSlot    = 4.0,
  FreighterBaseCostPerSlot = 1.0,
}

local function f(v) return string.format("%.6f", v) end
local function n(v) return string.format("%d", math.floor(v + 0.5)) end

-- Build the per-size-type change list.
local sizeTypeChanges = {}
for _, st in ipairs(SIZE_TYPES) do
  local name, maxSlots, maxTech = st[1], st[2], st[3]
  sizeTypeChanges[#sizeTypeChanges + 1] = {
    ["SPECIAL_KEY_WORDS"] = {name, "GcInventoryLayoutGenerationDataEntry"},
    ["VALUE_CHANGE_TABLE"] = {
      {"MinSlots",     n(maxSlots * MAX_BOOST)},
      {"MaxSlots",     n(maxSlots * MAX_BOOST)},
      {"MinTechSlots", n(maxTech  * MAX_BOOST)},
      {"MaxTechSlots", n(maxTech  * MAX_BOOST)},
    },
  }
end

local function slotCost(block, stockName)
  return {
    ["SPECIAL_KEY_WORDS"]  = {block, "GcInventoryValueData"},
    ["INTEGER_TO_FLOAT"]   = "FORCE",
    ["VALUE_CHANGE_TABLE"] = { {"BaseCostPerSlot", f(STOCK[stockName] * SLOT_COST)} },
  }
end

-- ---------------------------------------------------------------- definition
NMS_MOD_DEFINITION_CONTAINER =
{
  ["MOD_FILENAME"]    = MOD_NAME,
  ["MOD_AUTHOR"]      = "MorlachAU",
  ["LUA_AUTHOR"]      = "MorlachAU",
  ["NMS_VERSION"]     = NMS_VERSION,
  ["MOD_DESCRIPTION"] = "Bigger stacks, new ships/tools/freighters spawn with max slots, cheaper slot purchases",
  ["MODIFICATIONS"]   =
  {
    {
      ["MBIN_CHANGE_TABLE"] =
      {
        -- ---------------------------------------------- stack sizes
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\\REALITY\\TABLES\\NMS_REALITY_GCPRODUCTTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["REPLACE_TYPE"]   = "ALL",
              ["MATH_OPERATION"] = "*",
              ["VALUE_CHANGE_TABLE"] = { {"StackMultiplier", STACK_PRODUCTS} },
            },
          },
        },
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\\REALITY\\TABLES\\NMS_REALITY_GCSUBSTANCETABLE.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            {
              ["REPLACE_TYPE"]   = "ALL",
              ["MATH_OPERATION"] = "*",
              ["VALUE_CHANGE_TABLE"] = { {"StackMultiplier", STACK_SUBSTANCES} },
            },
          },
        },
        -- ---------------------------------------------- slot generation
        {
          ["MBIN_FILE_SOURCE"] = "METADATA\\REALITY\\TABLES\\INVENTORYTABLE.MBIN",
          ["MXML_CHANGE_TABLE"] = sizeTypeChanges,
        },
        -- ---------------------------------------------- slot purchase cost
        -- Disjoint from the other GCPLAYERGLOBALS mods.
        {
          ["MBIN_FILE_SOURCE"] = "GCPLAYERGLOBALS.GLOBAL.MBIN",
          ["MXML_CHANGE_TABLE"] =
          {
            slotCost("ShipValueData",      "ShipBaseCostPerSlot"),      -- Original 1.000000
            slotCost("WeaponValueData",    "WeaponBaseCostPerSlot"),    -- Original 4.000000
            slotCost("FreighterValueData", "FreighterBaseCostPerSlot"), -- Original 1.000000
          },
        },
      },
    },
  },
}
