SLASH_DOD1 = "/dodshow"

DOD = { }
DOD.settings = { }
DOD.savedVars = { }

SlashCmdList["DOD"] = function(msg)
  DOD.ShowFrame()
end

function DOD.Init()
  local initFrame = CreateFrame("Frame", nil, UIParent)
  initFrame:RegisterEvent("ADDON_LOADED")
  initFrame:RegisterEvent("PLAYER_XP_UPDATE")
  initFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
  initFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  initFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

  initFrame:SetScript("OnEvent", function (_,e, ...) DOD[e](...) end)
  initFrame:SetScript("OnUpdate", DOD.OnUpdate)
end

function DOD.OnUpdate(self, elapsedSeconds)
  DOD.CombatProcessorUpdate(elapsedSeconds)

  expInfo = DOD.GetExpPercentageInfo()
  combatProcessorInfo = DOD.CombatProcessorGetProcsInfo()
  DOD.SetFrameText(expInfo .. "\n" .. combatProcessorInfo)
end

function DOD.ADDON_LOADED(addonName, ...)
  if addonName ~= "DOD" then return end

  if (DOD_SETTINGS == nil) then
    DOD_SETTINGS = {}
    DOD_SETTINGS.position = {0, 0}
  end

  if (DOD_SAVED_VARS == nil) then
    DOD_SAVED_VARS = {}
    DOD_SAVED_VARS.combatProcs = {}
  end

  DOD.settings = DOD_SETTINGS
  DOD.savedVars = DOD_SAVED_VARS

  DOD.CreateFrame(
    table.getn(DOD.trackedUptime) + table.getn(DOD.trackedProcs),
    DOD.CombatProcessorClear,
    DOD.DetailsDump
  )

  DOD.SetFramePosition(DOD.settings.position [1], DOD.settings.position [2])

  DOD.CursorCooldownInit()
  DOD.CombatProcessorInit()
  DOD.DetailsInit()
end

function DOD.PLAYER_XP_UPDATE(arg1, ...)
  if (arg1 ~= "player") then return end
  DOD.RefreshExpPercentageInfo()
end

-- https://wow.gamepedia.com/COMBAT_LOG_EVENT
function DOD.COMBAT_LOG_EVENT_UNFILTERED(...)
  DOD.OnCombatLogEvent(CombatLogGetCurrentEventInfo())
end

function DOD.UNIT_SPELLCAST_FAILED(caster, _, spellId)
  if (caster ~= "player") then return end
  DOD.ShowCursorCooldown(spellId)
end

function DOD.PLAYER_SPECIALIZATION_CHANGED(...)
  -- Reinit when spec changes
  DOD.CombatProcessorInit()
end

DOD.Init()
