DOD.spellsOfInterest = {
  "Сны наяву",
  "Ураганные удары",
  "Шулерские игральные кости: искусность",
  "Шулерские игральные кости: скорость",
  "Шулерские игральные кости: критический удар",
  "Безудержная сила",
  "Вспарывание", 
  -- Priest
  "Shadowy Insight"
}

DOD.isShadowPriest = false

local eventsOfInterest = {
  "SPELL_DAMAGE",
  "SPELL_ENERGIZE",
  "SPELL_AURA_APPLIED",
  "SPELL_AURA_REFRESH",
  "SPELL_AURA_REMOVED",
}

local playerGUID = 0
local procs = { }
local combatTime = 0

local trackVoidForm = false
local voidFormInfo = { current = 0, currentBest = 0, allTimeBest = 0 }

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

local function seconds(t) 
  return string.format("%.1f", t)
end

local function hasAura(aura) 
  -- for i=1,40 do
  --   local n, ... = UnitAura("player",i)
  --   if n == aura then
  --    return true
  --   end
  -- end
  return false
end

------------------------------------------------------------------------------------------

function DOD.CombatProcessorInit()
  playerGUID = UnitGUID("player")
  local _, pClass = UnitClass("player")
  local pSpec = GetSpecialization()
  DOD.isShadowPriest = pClass == "PRIEST" and pSpec == 3

  if DOD.savedVars.combatProcs == nil then
    DOD.savedVars.combatProcs = { } 
  end

  procs = DOD.savedVars.combatProcs

  if DOD.savedVars.voidFormInfo == nil then
    DOD.savedVars.voidFormInfo = voidFormInfo
  end

  voidFormInfo = DOD.savedVars.voidFormInfo 
end

function DOD.CombatProcessorGetProcsInfo()
  local str = "Time in combat: ".. string.format("%.1f", combatTime) .. "\n"
  for k, v in pairs(procs) do
    local ppm = getProcsPerMinute(k)
    str = str .. string.sub(k, 0, 30)  .. " - " ..  v .. " (" .. seconds(ppm) .. "/min)" .. "\n"
  end
  print(str)
  return str
end

function DOD.CombatProcessorGetVoidFormInfo()
  if DOD.isShadowPriest then
    return "Current: " .. seconds(voidFormInfo.current) .. "\nBest: " .. seconds(voidFormInfo.currentBest) .. "\nAll Time: " .. seconds(voidFormInfo.allTimeBest) .. "\n"
  end
  return "Not a shadow priest!"
end

function DOD.CombatProcessorClear()
  combatTime = 0
  procs = { }
  voidFormInfo.current = 0 
  voidFormInfo.currentBest = 0
end

function DOD.CombatProcessorUpdate(timeElapsed)
  local inCombat = UnitAffectingCombat("player")
  if inCombat then 
    combatTime = combatTime + timeElapsed
  end

  if DOD.isShadowPriest then
    -- Dispersion stops sanity drain, so we ignore that
    if trackVoidForm and not hasAura("Dispersion") then
      voidFormInfo.current = voidFormInfo.current + timeElapsed
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

  -- voidform tracking
  if DOD.isShadowPriest and spellName == "Voidform" then
    if subevent == "SPELL_AURA_APPLIED" then
      voidFormInfo.current = 0
      trackVoidForm = true
    end

    if trackVoidForm and subevent == "SPELL_AURA_REMOVED" then
      trackVoidForm = false
      if voidFormInfo.current > voidFormInfo.currentBest then
        voidFormInfo.currentBest = voidFormInfo.current
      end
      if voidFormInfo.current > voidFormInfo.allTimeBest then
        voidFormInfo.allTimeBest = voidFormInfo.current
      end
    end
  end

  -- add tracker proc
  if contains(DOD.spellsOfInterest, spellName) then increment(spellName) end

  --  if ends_with(subevent, "ENERGIZE") or ends_with(subevent, "AURA_APPLIED") then
  --    local amount, overEnergize = select(15, ...)
  --  end
  --  end
end
