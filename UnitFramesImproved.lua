-- Create the addon main instance (Ace-3.0)
UnitFramesImproved = LibStub("AceAddon-3.0"):NewAddon("UnitFramesImproved", "AceConsole-3.0", "AceEvent-3.0")
UnitFramesImproved:SetDefaultModuleLibraries("AceConsole-3.0", "AceEvent-3.0")
UnitFramesImproved:SetDefaultModuleState(false)

-- Initialization of the addon, compatible with Ace-3.0
function UnitFramesImproved:OnInitialize()
  DebugPrint("OK", "INFO", 2, "Initializing...")

  -- Register event handlers
  self:RegisterEvent('PLAYER_TARGET_CHANGED', 'PLAYER_TARGET_CHANGED')
  self:RegisterEvent('PLAYER_FOCUS_CHANGED', 'PLAYER_FOCUS_CHANGED')
  self:RegisterEvent('UNIT_TARGET', "UNIT_TARGET")

  -- Register chat slash-commands
  self:RegisterChatCommand("ufi", "SlashCommand_Main")
  self:RegisterChatCommand("unitframesimproved", "SlashCommand_Main")

  DebugPrint("OK", "INFO", 2, "Initialized.")
end

function UnitFramesImproved:LoadConfig()
  DebugPrint("OK", "INFO", 2, "Loading config...")

  -- Set up default stylings
  UnitFramesImproved:Style_PlayerFrame()
  UnitFramesImproved:Style_TargetFrame(TargetFrame)
  UnitFramesImproved:Style_TargetFrame(FocusFrame)
  UnitFramesImproved:Style_ToTFrame(TargetFrameToT)
  UnitFramesImproved:Style_ToTFrame(FocusFrameToT)

  DebugPrint("OK", "INFO", 2, "Config loaded.")
end

-- Slash-command Handlers
function UnitFramesImproved:SlashCommand_Main()
  -- For now just output some info that settings for scale have been removed from previous major versions
  dout("Welcome to UnitFramesImproved. Settings have been removed as this is part of standard UI.")
end

-- Stylers
function UnitFramesImproved:Style_PlayerFrame()
  if not InCombatLockdown() then
    local healthBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea.ManaBar

    -- Fix statusbar fill coloring
    healthBar:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOff-Bar-Health-Status", TextureKitConstants.UseAtlasSize)
    healthBar:SetStatusBarDesaturated(true)

    -- Status text hook
    hooksecurefunc(healthBar, "UpdateTextStringWithValues", UnitFramesImproved_UpdateTextStringWithValues);
    hooksecurefunc(manaBar, "UpdateTextStringWithValues", UnitFramesImproved_UpdateTextStringWithValues);

    -- Force an update as at least on my install, it isn't updating on load
    healthBar:UpdateTextString();

    -- Force update of the status bar coloring
    UnitFramesImproved:UpdateStatusBarColor(PlayerFrame)
  end
end

function UnitFramesImproved:Style_TargetFrame(frame)
  if not InCombatLockdown() then
    local healthBar = frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer.HealthBar
    local manaBar = frame.TargetFrameContent.TargetFrameContentMain.ManaBar

    -- Fix statusbar fill coloring
    healthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Status", TextureKitConstants.UseAtlasSize)
    healthBar:SetStatusBarDesaturated(true)

    -- Status text hook
    hooksecurefunc(healthBar, "UpdateTextStringWithValues", UnitFramesImproved_UpdateTextStringWithValues);
    hooksecurefunc(manaBar, "UpdateTextStringWithValues", UnitFramesImproved_UpdateTextStringWithValues);

    -- Force update of the status bar coloring
    UnitFramesImproved:UpdateStatusBarColor(frame)
  end
end

function UnitFramesImproved:Style_ToTFrame(frame)
  if not InCombatLockdown() then
    local healthBar = frame.HealthBar

    -- Fix statusbar fill coloring
    healthBar:SetStatusBarTexture("UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-Health-Status", TextureKitConstants.UseAtlasSize)
    healthBar:SetStatusBarDesaturated(true)

    -- Force update of the status bar coloring
    UnitFramesImproved:UpdateStatusBarColor(frame)
  end
end

-- Event Handlers
function UnitFramesImproved:PLAYER_TARGET_CHANGED()
  UnitFramesImproved:UpdateStatusBarColor(TargetFrame)
end

function UnitFramesImproved:PLAYER_FOCUS_CHANGED()
  UnitFramesImproved:UpdateStatusBarColor(FocusFrame)
end

function UnitFramesImproved:UNIT_TARGET(self, unitTarget)
  if unitTarget == "target" then
    UnitFramesImproved:UpdateStatusBarColor(TargetFrameToT)
  end
  if unitTarget == "focus" then
    UnitFramesImproved:UpdateStatusBarColor(FocusFrameToT)
  end
end

-- Common Functions
function UnitFramesImproved_UpdateTextStringWithValues(self, textString, value, valueMin, valueMax)
  if (self.LeftText and self.RightText) then
    --if not InCombatLockdown() then
      self.LeftText:SetText("")
      self.RightText:SetText("")
      self.LeftText:Hide()
      self.RightText:Hide()
      if (textString) then
        textString:Show()
      end
    --end
  end

  if ((tonumber(valueMax) ~= valueMax or valueMax > 0) and not (self.pauseUpdates)) then
    local valueDisplay = value;
    local valueMaxDisplay = valueMax;
    if (self.capNumericDisplay) then
      valueDisplay = UnitFramesImproved:AbbreviateLargeNumbers(value);
      valueMaxDisplay = UnitFramesImproved:AbbreviateLargeNumbers(valueMax);
    else
      valueDisplay = BreakUpLargeNumbers(value);
      valueMaxDisplay = BreakUpLargeNumbers(valueMax);
    end

    local textDisplay = GetCVar("statusTextDisplay")
    if (textDisplay == "NONE") then return end

    if (value and valueMax > 0 and (textDisplay ~= "NUMERIC" or self.showPercentage) and not self.showNumeric) then
      local percent = math.ceil((value / valueMax) * 100) .. "%";
      if (textDisplay == "BOTH" and not self.showPercentage) then
        valueDisplay = valueDisplay .. " (" .. percent .. ")";
        textString:SetText(valueDisplay);
      else
        valueDisplay = percent;
        if (self.prefix and (self.alwaysPrefix or not (self.cvar and GetCVar(self.cvar) == "1" and self.textLockable))) then
          textString:SetText(self.prefix .. " " .. valueDisplay);
        else
          textString:SetText(valueDisplay);
        end
      end
    elseif (value == 0 and self.zeroText) then
      return;
    else
      self.isZero = nil;
      if (self.prefix and (self.alwaysPrefix or not (self.cvar and GetCVar(self.cvar) == "1" and self.textLockable))) then
        textString:SetText(self.prefix .. " " .. valueDisplay .. "/" .. valueMaxDisplay);
      else
        textString:SetText(valueDisplay .. "/" .. valueMaxDisplay);
      end
    end
  end
end

function UnitFramesImproved:UpdateStatusBarColor(frame)
  -- Set back color of health bar
  if (not UnitPlayerControlled(frame.unit) and UnitIsTapDenied(frame.unit)) then
    -- Gray if npc is tapped by other player
    frame.healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
  else
    -- Standard by class etc if not
    local r, g, b = UnitFramesImproved:UnitColor(frame.healthbar.unit)
    frame.healthbar:SetStatusBarColor(r, g, b)
  end
end

-- Utility functions
function UnitFramesImproved:UnitColor(unit)
  local r, g, b
  if ((not UnitIsPlayer(unit)) and ((not UnitIsConnected(unit)) or (UnitIsDeadOrGhost(unit)))) then
    --Color it gray
    r, g, b = 0.5, 0.5, 0.5
  elseif (UnitIsPlayer(unit)) then
    --Try to color it by class.
    local localizedClass, englishClass = UnitClass(unit)
    local classColor = RAID_CLASS_COLORS[englishClass]
    if (classColor) then
      r, g, b = classColor.r, classColor.g, classColor.b
    else
      if (UnitIsFriend("player", unit)) then
        r, g, b = 0.0, 1.0, 0.0
      else
        r, g, b = 1.0, 0.0, 0.0
      end
    end
  else
    r, g, b = UnitSelectionColor(unit)
  end

  return r, g, b
end

function UnitFramesImproved:AbbreviateLargeNumbers(value)
  local strLen = strlen(value)
  local retString = value

  if (strLen >= 10) then
    retString = string.sub(value, 1, -10) .. "." .. string.sub(value, -9, -8) .. "G"
  elseif (strLen >= 7) then
    retString = string.sub(value, 1, -7) .. "." .. string.sub(value, -6, -5) .. "M"
  elseif (strLen >= 4) then
    retString = string.sub(value, 1, -4) .. "." .. string.sub(value, -3, -3) .. "k"
  end

  return retString
end

-- Events
UnitFramesImproved:RegisterEvent("PLAYER_ENTERING_WORLD", "LoadConfig")
