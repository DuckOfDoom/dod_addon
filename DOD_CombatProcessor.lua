-- Track procs per minute
DOD.trackedProcs = {
--  "Enrage"
}

-- Track uptime of status in combat
DOD.trackedUptime = {
  "Enrage"
}

local eventsOfInterest = {
  "SPELL_DAMAGE",
  "SPELL_ENERGIZE",
  "SPELL_AURA_APPLIED",
  "SPELL_AURA_REFRESH",
  "SPELL_AURA_REMOVED",
}

local playerGUID = 0
local procs = { }
local uptime = { }
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
  if procs[s] then procs[s] = procs[s] + 1 else procs[s] = 1 end
end

local function seconds(t) 
  return string.format("%.1f", t)
end

------------------------------------------------------------------------------------------

function DOD.CombatProcessorInit()
  playerGUID = UnitGUID("player")
  local _, pClass = UnitClass("player")

  if DOD.savedVars.combatProcs == nil then
    DOD.savedVars.combatProcs = { } 
  end

  if DOD.savedVars.uptime == nil then
    DOD.savedVars.uptime = { } 
  end

  procs = DOD.savedVars.combatProcs
  uptime = DOD.savedVars.uptime
end

function DOD.CombatProcessorGetProcsInfo()
  local str = "Time in combat: ".. string.format("%.1f", combatTime) .. "\n"
  for k, v in pairs(uptime) do
    local percent = string.format("%.1f", v/combatTime * 100)
    str = str .. string.sub(k, 0, 30)  .. " - " ..  string.format("%.1f", v) .. " (" .. percent .."%)\n"
  end

  for k, v in pairs(procs) do
    local ppm = getProcsPerMinute(k)
    str = str .. string.sub(k, 0, 30)  .. " - " ..  v .. " (" .. seconds(ppm) .. "/min)\n"
  end
  return str
end

function DOD.CombatProcessorClear()
  combatTime = 0
  procs = { }
  uptime = { } 
end

function DOD.CombatProcessorUpdate(timeElapsed)
  local inCombat = UnitAffectingCombat("player")
  if inCombat then 
    combatTime = combatTime + timeElapsed

    for k, v in pairs(DOD.trackedUptime) do
      if (BuffPresent(v)) then
        if (uptime[v])
          then
            uptime[v] = uptime[v] + timeElapsed
          else
            uptime[v] = timeElapsed
          end
      end
    end
  end
end

function DOD.OnCombatLogEvent(...)
  local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ... 
  if sourceGUID ~= playerGUID then return end
  if destGUID ~= playerGUID then return end

  if starts_with(subevent, "SWING") or starts_with(subevent, "ENVIROMENTAL") then return end
  if not contains(eventsOfInterest, subevent) then return end
  local spellId, spellName = select(12, ...)

  -- add tracked proc
  if contains(DOD.trackedProcs, spellName) then increment(spellName) end

  --  if ends_with(subevent, "ENERGIZE") or ends_with(subevent, "AURA_APPLIED") then
  --    local amount, overEnergize = select(15, ...)
  --  end
  --  end
end

function BuffPresent(buffName)
  local name = AuraUtil.FindAuraByName(buffName, 'player')
  if(name) then
    return true;
  end

  return false
end
