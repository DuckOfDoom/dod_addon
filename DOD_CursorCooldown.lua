--[[
TODO: 
- Make convenient anchoring
- Research global cooldown tracking
- SETTINGS
]]--

local eventFrame = CreateFrame("Frame")
local GetCursorPosition = _G.GetCursorPosition
local IsMouselooking = _G.IsMouselooking

local movableFrame = nil; 
local contentFrame = nil;
local text, texture = nil, nil;

function DOD.CursorCooldownInit()
  -- Create and hook a frame for events
  eventFrame = CreateFrame("Frame");
  eventFrame:SetScript("OnUpdate", OnUpdate);

  eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED");
  eventFrame:SetScript("OnEvent", OnEvent);

  -- Creating frame to show our info
  movableFrame = CreateFrame(
  "Frame",
  nil,
  UIParent
  -- , "GlowBoxTemplate"
  -- , "BaseBasicFrameTemplate"
  );

  local size = 25;

  movableFrame:SetMovable(true)
  movableFrame:SetFrameStrata("TOOLTIP");
  movableFrame:EnableMouse(false);
  movableFrame:EnableKeyboard(false);

  movableFrame:SetSize(size, size);

  -- TODO: Make another frame to anchor content 

  contentFrame = CreateFrame(
  "Frame",
  nil,
  movableFrame
  --    , "GlowBoxTemplate"
  );

  contentFrame:SetPoint("TOPLEFT", movableFrame, "BOTTOMRIGHT", 10, -10);
  contentFrame:SetSize(100, 50);

  texture = contentFrame:CreateTexture(nil, "BACKGROUND");
  --    texture:SetPoint("TOPLEFT", movableFrame, "BOTTOMRIGHT");

  texture:SetPoint("LEFT");
  texture:SetSize(size, size);

  text = contentFrame:CreateFontString(nil, "OVERLAY");
  text:SetFont("Fonts\\FRIZQT___CYR.TTF", 24, "OUTLINE");
  text:SetPoint("LEFT", 25, 0);
  --    text:SetPoint("TOPLEFT", movableFrame, "BOTTOMRIGHT", 0, 0, size, 0);

  text:SetJustifyH("LEFT");
  text:SetTextColor(1,0,0);

  movableFrame:Show()
end

local activeUntil = 0;
local failedSpellId = nil;
local failedSpellIcon = nil;

function DOD.ShowCursorCooldown(spellId)
  local _, _, icon = GetSpellInfo(spellId);
  failedSpellId = spellId;
  failedSpellIcon = icon;
  activeUntil = GetTime() + 3;
end

function OnUpdate(self, elapsedSeconds) 
  local scale = UIParent:GetEffectiveScale();
  local cursorX, cursorY = GetCursorPosition();
  cursorX = cursorX / scale;
  cursorY = cursorY / scale;

  movableFrame:SetPoint("BOTTOMLEFT", cursorX, cursorY);

  local time = GetTime();

  if (activeUntil > time) then
    local start, duration, enable = GetSpellCooldown(failedSpellId);
    local cooldownRemaining = duration - (time - start);

    if (cooldownRemaining > 0) then

      texture:SetTexture(failedSpellIcon);
      text:SetText(FormatCooldown(cooldownRemaining, 1));

      movableFrame:Show();
    else
      activeUntil = 0;
      movableFrame:Hide();
    end
  else
    movableFrame:Hide();
  end
end

function FormatCooldown(num, numDecimalPlaces)
  if (math.floor(num) == num) then
    return string.format(num .. ".0");
  else
    return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
  end
end

function OnEvent(self, event, ...)
  if (event == "UNIT_SPELLCAST_FAILED") then
  end
end
