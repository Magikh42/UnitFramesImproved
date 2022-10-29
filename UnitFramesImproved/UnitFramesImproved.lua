-- Create the addon main instance
local UnitFramesImproved = CreateFrame('Button', 'UnitFramesImproved');

-- Event listener to make sure we enable the addon at the right time
function UnitFramesImproved:PLAYER_ENTERING_WORLD()
  DebugPrintf("Initializing")
	EnableUnitFramesImproved();
  DebugPrintf("Initialized")
end

function EnableUnitFramesImproved()
	-- Generic status text hook
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", UnitFramesImproved_TextStatusBar_UpdateTextStringWithValues);
	
	-- Hook TargetFrame functions
	hooksecurefunc(TargetFrame, "CheckDead", UnitFramesImproved_TargetFrame_Update);
	hooksecurefunc(TargetFrame, "Update", UnitFramesImproved_TargetFrame_Update);
	hooksecurefunc(TargetFrame, "CheckClassification", UnitFramesImproved_TargetFrame_CheckClassification);

	-- Hook FocusFrame functions
	if (FocusFrame) then -- Support WoW Classic by checking for FocusFrame
    hooksecurefunc(FocusFrame, "Update", UnitFramesImproved_TargetFrame_Update);
    hooksecurefunc(FocusFrame, "CheckClassification", UnitFramesImproved_TargetFrame_CheckClassification);
  end

	-- Hook TargetFrameToT functions
	hooksecurefunc(TargetFrameToT, "Update", UnitFramesImproved_TargetFrame_Update);

	-- Hook FocusFrameToT functions
  hooksecurefunc(FocusFrameToT, "Update", UnitFramesImproved_TargetFrame_Update);
	
	-- Set up some stylings
	UnitFramesImproved_Style_PlayerFrame();
	UnitFramesImproved_Style_TargetFrame(TargetFrame);
	UnitFramesImproved_Style_ToT(TargetFrameToT);
	if (FocusFrame) then -- Support WoW Classic by checking for FocusFrame
		UnitFramesImproved_Style_TargetFrame(FocusFrame);
		UnitFramesImproved_Style_ToT(FocusFrameToT);
	end
	
	-- Update some values
	TextStatusBar_UpdateTextString(PlayerFrame.healthbar);
	TextStatusBar_UpdateTextString(PlayerFrame.manabar);
end

function CreateStatusBarText(name, parentName, parent, point, x, y)
	local fontString = parent:CreateFontString(parentName..name, nil, "TextStatusBarText")
	fontString:SetPoint(point, parent, point, x, y)
	
	return fontString
end

function UnitFramesImproved_Style_PlayerFrame()
	if not InCombatLockdown() then 
		PlayerFrameHealthBar.lockColor = true;
		PlayerFrameHealthBar.capNumericDisplay = true;
    PlayerFrameHealthBar:SetStatusBarTexture("UI-HUD-UnitFrame-Player-PortraitOff-Bar-Health-Status", TextureKitConstants.UseAtlasSize);
	end
	
	PlayerFrameHealthBar:SetStatusBarColor(UnitColor("player"));
end

function UnitFramesImproved_Style_TargetFrame(self)
	self.healthbar.lockColor = true;
end

function UnitFramesImproved_TargetFrame_CheckClassification(self)
  local healthBar = self.TargetFrameContent.TargetFrameContentMain.HealthBar;
  healthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Status", TextureKitConstants.UseAtlasSize);
end

function UnitFramesImproved_Style_ToT(self)
  local healthBar = self.HealthBar;
  healthBar:SetStatusBarTexture("UI-HUD-UnitFrame-TargetofTarget-PortraitOn-Bar-Health-Status", TextureKitConstants.UseAtlasSize);
end

-- Slashcommand stuff
SLASH_UNITFRAMESIMPROVED1 = "/unitframesimproved";
SLASH_UNITFRAMESIMPROVED2 = "/ufi";
SlashCmdList["UNITFRAMESIMPROVED"] = function(msg, editBox)
  dout("Welcome to UnitFramesImproved. Settings have been removed as this is part of standard UI.")
  dout("");
end

function UnitFramesImproved_TextStatusBar_UpdateTextStringWithValues(statusFrame, textString, value, valueMin, valueMax)
  if( statusFrame.LeftText and statusFrame.RightText ) then
		statusFrame.LeftText:SetText("");
		statusFrame.RightText:SetText("");
		statusFrame.LeftText:Hide();
		statusFrame.RightText:Hide();
		textString:Show();
	end
	
	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( statusFrame.pauseUpdates ) ) then
		local valueDisplay = value;
		local valueMaxDisplay = valueMax;
		if ( statusFrame.capNumericDisplay ) then
			valueDisplay = UnitFramesImproved_AbbreviateLargeNumbers(value);
			valueMaxDisplay = UnitFramesImproved_AbbreviateLargeNumbers(valueMax);
		else
			valueDisplay = BreakUpLargeNumbers(value);
			valueMaxDisplay = BreakUpLargeNumbers(valueMax);
		end

		local textDisplay = GetCVar("statusTextDisplay")
		if (textDisplay == "NONE") then return end
		
		if ( value and valueMax > 0 and ( textDisplay ~= "NUMERIC" or statusFrame.showPercentage ) and not statusFrame.showNumeric) then
			local percent = math.ceil((value / valueMax) * 100) .. "%";
			if ( textDisplay == "BOTH" and not statusFrame.showPercentage) then
				valueDisplay = valueDisplay .. " (" .. percent .. ")";
				textString:SetText(valueDisplay);
			else
				valueDisplay = percent;
				if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
					textString:SetText(statusFrame.prefix .. " " .. valueDisplay);
				else
					textString:SetText(valueDisplay);
				end
			end
		elseif ( value == 0 and statusFrame.zeroText ) then
			return;
		else
			statusFrame.isZero = nil;
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				textString:SetText(statusFrame.prefix.." "..valueDisplay.."/"..valueMaxDisplay);
			else
				textString:SetText(valueDisplay.."/"..valueMaxDisplay);
			end
		end
	end
end

function UnitFramesImproved_TargetFrame_Update(self)
	-- Set back color of health bar
	if ( not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit) ) then
		-- Gray if npc is tapped by other player
		self.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
	else
		-- Standard by class etc if not
	  local r, g, b = UnitColor(self.healthbar.unit)
		self.healthbar:SetStatusBarColor(r, g, b);
	end
	
	if ((UnitHealth(self.unit) <= 0) and UnitIsConnected(self.unit)) then
		if (not UnitIsUnconscious(self.unit)) then
			if (self.healthbar.TextString) then
				self.healthbar.TextString:Hide()
				self.healthbar.forceHideText = true
			end
		end
	end
end

-- Utility functions
function UnitColor(unit)
	local r, g, b;
	if ( ( not UnitIsPlayer(unit) ) and ( ( not UnitIsConnected(unit) ) or ( UnitIsDeadOrGhost(unit) ) ) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	elseif ( UnitIsPlayer(unit) ) then
		--Try to color it by class.
		local localizedClass, englishClass = UnitClass(unit);
		local classColor = RAID_CLASS_COLORS[englishClass];
		if ( classColor ) then
			r, g, b = classColor.r, classColor.g, classColor.b;
		else
			if ( UnitIsFriend("player", unit) ) then
				r, g, b = 0.0, 1.0, 0.0;
			else
				r, g, b = 1.0, 0.0, 0.0;
			end
		end
	else
		r, g, b = UnitSelectionColor(unit);
	end
	
	return r, g, b;
end

function UnitFramesImproved_AbbreviateLargeNumbers(value)
	local strLen = strlen(value);
	local retString = value;
	
	if ( strLen >= 10 ) then
		retString = string.sub(value, 1, -10).."."..string.sub(value, -9, -8).."G";
	elseif ( strLen >= 7 ) then
		retString = string.sub(value, 1, -7).."."..string.sub(value, -6, -5).."M";
	elseif ( strLen >= 4 ) then
		retString = string.sub(value, 1, -4).."."..string.sub(value, -3, -3).."k";
	end
	
	return retString;
end

-- Bootstrap
function UnitFramesImproved_StartUp(self)
	self:SetScript('OnEvent', function(self, event) self[event](self) end);
	self:RegisterEvent('PLAYER_ENTERING_WORLD');
end

UnitFramesImproved_StartUp(UnitFramesImproved);

-- Additional debug info can be found on http://www.wowwiki.com/Blizzard_DebugTools
-- /framestack [showhidden]
--		showhidden - if "true" then will also display information about hidden frames
-- /eventtrace [command]
-- 		start - enables event capturing to the EventTrace frame
--		stop - disables event capturing
--		number - captures the provided number of events and then stops
--		If no command is given the EventTrace frame visibility is toggled. The first time the frame is displayed, event tracing is automatically started.
-- /dump expression
--		expression can be any valid lua expression that results in a value. So variable names, function calls, frames or tables can all be dumped.

-- Adds message to the chatbox (only visible to the loacl player)
function dout(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg);
end

-- Debug print
function DebugPrintf(...)
  local status, res = pcall(format, ...)
  if status then
    if DLAPI then DLAPI.DebugLog("UnitFramesImproved", res) end
  end
end

-- Table Dump Functions -- http://lua-users.org/wiki/TableSerialization
function print_r (t, indent, done)
  done = done or {}
  indent = indent or ''
  local nextIndent -- Storage for next indentation value
  for key, value in pairs (t) do
    if type (value) == "table" and not done [value] then
      nextIndent = nextIndent or
          (indent .. string.rep(' ',string.len(tostring (key))+2))
          -- Shortcut conditional allocation
      done [value] = true
      print (indent .. "[" .. tostring (key) .. "] => Table {");
      print  (nextIndent .. "{");
      print_r (value, nextIndent .. string.rep(' ',2), done)
      print  (nextIndent .. "}");
    else
      print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
    end
  end
end
