local frame
local text

function DOD.CreateFrame()
  local settings = DOD_settings

  frame = CreateFrame("Frame", nil, UIParent, "UIPanelDialogTemplate")

  frame:SetPoint("TOPLEFT")
  frame:SetSize(300, 100)

  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")

  local function OnFrameMoveStop()
    local p, rel, rp, x, y = frame:GetPoint()
    settings.position = {x, y} --frame:GetPoint()
    frame:StopMovingOrSizing()
  end

  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", OnFrameMoveStop)

  text = frame:CreateFontString(nil, "OVERLAY");
  text:SetFont("Fonts\\FRIZQT___CYR.TTF", 16, "OUTLINE");
  text:SetPoint("LEFT", 25, 0);

  text:SetJustifyH("LEFT");
  text:SetTextColor(.75, .75, 1)

  return frame;
end

function DOD.SetFramePosition(x, y)
  frame:SetPoint("TOPLEFT", x, y)
end

function DOD.SetFrameText(text)
  text:SetText(text)
end
