local playerGUID = 0

DOD.spellsOfInterest = {
   "Сны наяву",
   "Ураганные удары",
   "Шулерские игральные кости: искусность",
   "Шулерские игральные кости: скорость",
   "Шулерские игральные кости: критический удар",
   "Безудержная сила",
   "Вспышка ясности",
   "Вспарывание"
}

local eventsOfInterest = {
  "SPELL_DAMAGE",
  "SPELL_ENERGIZE",
  "SPELL_AURA_APPLIED",
  "SPELL_AURA_REFRESH"
}

local procs = { }
local combatTime = 0

local function starts_with(str, start)
   return str:sub(1, #start) == start
end

local function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

local function contains(arr, val)
  for i, v in pairs(arr) do
    if v == val then return true end
  end
  return false
end

local function getProcsPerMinute(s)
  local p = procs[s]
  if p == nil then return 0 end
  return p / combatTime * 60
end

local function increment(s)
  local p = procs
  if procs[s] then procs[s] = procs[s] + 1 else procs[s] = 1 end
end

function DOD.CombatProcessorGetInfo()
  local str = "Time in combat: ".. string.format("%.1f", combatTime) .. "\n"
  for k, v in pairs(procs) do
    local ppm = getProcsPerMinute(k)
    str = str .. string.sub(k, 0, 30)  .. " - " ..  v .. " (" .. string.format("%.1f", ppm) .. "/min)" .. "\n"
  end
  return str
end

function DOD.CombatProcessorInit()
  playerGUID = UnitGUID("player")
end

function DOD.CombatProcessorClear()
  combatTime = 0
  procs = { }
end

function DOD.CombatProcessorUpdate(timeElapsed)
  local inCombat = UnitAffectingCombat("player")
  if inCombat then 
    combatTime = combatTime + timeElapsed
  end
end

function DOD.OnCombatLogEvent(...)
  local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ... 
  if sourceGUID ~= playerGUID then return end
  if destGUID ~= playerGUID then return end

--  print(subevent)
  if starts_with(subevent, "SWING") or starts_with(subevent, "ENVIROMENTAL") then return end
  if not contains(eventsOfInterest, subevent) then return end

  local spellId, spellName = select(12, ...)
  if contains(DOD.spellsOfInterest, spellName) then increment(spellName) end

--  if ends_with(subevent, "ENERGIZE") or ends_with(subevent, "AURA_APPLIED") then
--    local amount, overEnergize = select(15, ...)
--  end
--  end
end

function DOD.OnSpellcastSucceeded(caster, spellId)
  if caster ~= "player" then return end
  name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spellId)
  --    print(name)
end

function DOD.OnUnitAura(unit)
  if (unit ~= "player") then return end

  for i = 1, 40 do 
    name = UnitAura("player", i)
    if name then
      --      print(name)
    end
  end
end
