local playerGUID = 0

function DOD.CoimbatProcessorInit()
  local playerGUID = UnitGUID("player")
end

function DOD.OnCombatLogEvent()
  local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  --	local spellId, spellName, spellSchool
  --	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

  --  print(subevent)
  --  print(b)
  --  print(...)
  --  print(timestamp)

  --	if subevent == "SWING_DAMAGE" then
  --		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
  --    print(amount)
  --	elseif subevent == "SPELL_DAMAGE" then
  --		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
  --	end

end

function DOD.OnSpellcastSucceeded(caster, spellId)
  if (caster ~= "player") then return end

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
