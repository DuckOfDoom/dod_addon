SLASH_DOD1 = "/dodshow"

DOD = { }
DOD.settings = { } 
DOD.savedVars = { } 

SlashCmdList["DOD"] = function(msg)
  DOD.ShowFrame()
end

-- 0 - combat procs
-- 1 - voidform tracking
-- 2 - exp tracking
local mode = 0

local function SwitchMode()
  mode = mode + 1 
  if mode > 2 then
    mode = 0
  end

  -- skip voidform mode for non shadow priest
  if mode == 1 and not DOD.isShadowPriest then
    mode = 2
  end

  -- skip exp mode for max level characters
  if mode == 2 and UnitLevel("player") == 120 then
    mode = 0
  end

end

function DOD.Init()
  local initFrame = CreateFrame("Frame", nil, UIParent)
  initFrame:RegisterEvent("ADDON_LOADED")
  initFrame:RegisterEvent("PLAYER_XP_UPDATE")
  initFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
  initFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  initFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

  initFrame:SetScript("OnEvent", function (_,e, ...) DOD[e](...) end)
  initFrame:SetScript("OnUpdate", DOD.Update)
end

function DOD.OnUpdate(self, elapsedSeconds) 
  DOD.CombatProcessorUpdate(elapsedSeconds)

  if mode == 0 then
    DOD.SetFrameText(DOD.CombatProcessorGetProcsInfo())
  elseif mode == 1 then
    DOD.SetFrameText(DOD.CombatProcessorGetVoidFormInfo())
  elseif mode == 3 then
    DOD.SetFrameText(DOD.GetExpPercentageInfo())
  end
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

  DOD.CreateFrame(table.getn(DOD.spellsOfInterest), DOD.CombatProcessorClear, SwitchMode)
  DOD.SetFramePosition(DOD.settings.position [1], DOD.settings.position [2])

  DOD.CursorCooldownInit()
  DOD.CombatProcessorInit()
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
