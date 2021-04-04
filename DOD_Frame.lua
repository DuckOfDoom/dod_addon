local frame
local text

function DOD.CreateFrame(linesCount, clear, misc)
  frame = CreateFrame("Frame", nil, UIParent, "UIPanelDialogTemplate")

  frameSize = linesCount * 16

  frame:SetPoint("TOPLEFT")
  frame:SetSize(300, 125 + frameSize)

  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")

  local function OnFrameMoveStop()
    local p, rel, rp, x, y = frame:GetPoint()
    DOD.settings.position = {x, y} --frame:GetPoint()
    frame:StopMovingOrSizing()
  end

  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", OnFrameMoveStop)

  text = frame:CreateFontString(nil, "OVERLAY");
  text:SetFont("Fonts\\FRIZQT___CYR.TTF", 16, "OUTLINE");
  text:SetPoint("TOPLEFT", 25, -50);
  text:SetJustifyH("LEFT");
  text:SetTextColor(.75, .75, 1)

  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  b:SetSize(80 ,22) -- width, height
  b:SetText("Clear")
  b:SetPoint("BOTTOMLEFT", 10, 10)
  b:SetScript("OnClick", clear)

  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  b:SetSize(80 ,22) -- width, height
  b:SetText("Misc")
  b:SetPoint("BOTTOMRIGHT", -20, 10)
  b:SetScript("OnClick", misc)

--  local b = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
--  b:SetSize(80 ,22) -- width, height
--  b:SetText("Misc")
--  b:SetPoint("BOTTOMCENTER", 0, 10)
--  b:SetScript("OnClick", switchMode)

  return frame;
end

function DOD.ShowFrame()
  frame:Show()
end

function DOD.SetFramePosition(x, y)
  frame:SetPoint("TOPLEFT", x, y)
end

function DOD.SetFrameText(t)
  text:SetText(t)
end
