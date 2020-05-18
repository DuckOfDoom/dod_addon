SLASH_DOD1 = "/dodshow"

DOD = { }

local initFrame = nil

SlashCmdList["DOD"] = function(msg)
  DOD.Init()
end

function DOD.Init()
  initFrame = CreateFrame("Frame", nil, UIParent)
  initFrame:RegisterEvent("ADDON_LOADED")
  initFrame:RegisterEvent("PLAYER_XP_UPDATE")
  initFrame:RegisterEvent("UNIT_AURA")
  initFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  initFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
  initFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  initFrame:SetScript("OnEvent", function (_,e, ...) DOD[e](...) end)
end

function DOD.ADDON_LOADED(...)

  DOD_settings = DOD_SETTINGS

  if (DOD_settings == nil) then
    DOD_settings = {}
    DOD_settings.position = {0, 0}

    DOD_SETTINGS = DOD_settings
  end

  DOD.CursorCooldownInit()

  DOD.CreateFrame()
  local p = DOD_settings.position 
  DOD.SetFramePosition(p[1], p[2])

  initFrame:UnregisterEvent("ADDON_LOADED")
end

function DOD.PLAYER_XP_UPDATE(arg1, ...)
  if (arg1 ~= "player") then
    return
  end

  DOD.SetFrameText(ExpPercentageCounter.CalculateExpPercentage())
end

function DOD.UNIT_AURA(unit, ...)
  DOD.OnUnitAura(unit)
end

-- https://wow.gamepedia.com/COMBAT_LOG_EVENT
function DOD.COMBAT_LOG_EVENT_UNFILTERED(...)
  DOD.OnCombatLogEvent(...)
end

function DOD.UNIT_SPELLCAST_SUCCEEDED(caster, _, spellId)
  DOD.OnSpellcastSucceeded(caster, spellId)
end

function DOD.UNIT_SPELLCAST_FAILED(caster, _, spellId)
  if (caster ~= "player") then
    return
  end

  DOD.ShowCursorCooldown(spellId)
end

DOD.Init();
