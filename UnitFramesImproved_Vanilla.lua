-- Stylers
function UnitFramesImproved:Style_PlayerFrame()
	PlayerFrameHealthBar.healthbar = PlayerFrameHealthBar

  local healthBar = PlayerFrameHealthBar
  local manaBar = PlayerFrameManaBar
  if not InCombatLockdown() then 
		healthBar.lockColor = true
		healthBar.capNumericDisplay = true
		healthBar:SetWidth(119)
		healthBar:SetHeight(29)
		healthBar:SetPoint("TOPLEFT",106,-22)

    -- Adjust fontstring anchors
		healthBar.TextString:SetPoint("CENTER",50,6)
		healthBar.LeftText:SetPoint("LEFT",110,6)
		healthBar.RightText:SetPoint("RIGHT",-8,6)

    -- Set fonts sizes for PlayerFrameManabar
    UnitFramesImproved:SetFontSize(manaBar.TextString, 12)
    UnitFramesImproved:SetFontSize(manaBar.LeftText, 12)
    UnitFramesImproved:SetFontSize(manaBar.RightText, 12)
	end
	
  -- Set the player frame textures
	PlayerFrameTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame")
	PlayerStatusTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-Player-Status")

  -- Ensure that numeric display is capped
  healthBar.breakUpLargeNumbers = true
  healthBar.capNumericDisplay = true
  manaBar.breakUpLargeNumbers = true
  manaBar.capNumericDisplay = true

  -- Status text hook (used by all the statusbars!)
  hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", UnitFramesImproved_UpdateTextStringWithValues)

  -- Update the statusbar color to trigger it to show at load
	UnitFramesImproved:UpdateStatusBarColor(healthBar)
end

function UnitFramesImproved:Style_TargetFrame(frame)
  if (not frame) then
    return
  end

  local healthBar = frame.healthbar
  local manaBar = frame.manabar
	if not InCombatLockdown() then
    -- Create healthbar and manabar status texts
    if (healthBar and not healthBar.LeftText and not healthBar.TextString and not healthBar.RightText) then
      healthBar.TextString = UnitFramesImproved:CreateStatusBarText("Text", frame:GetName().."HealthBar", frame.textureFrame, "CENTER", -50, 6)
      healthBar.LeftText = UnitFramesImproved:CreateStatusBarText("TextLeft", frame:GetName().."HealthBar", frame.textureFrame, "LEFT", 8, 6)
      healthBar.RightText = UnitFramesImproved:CreateStatusBarText("TextRight", frame:GetName().."HealthBar", frame.textureFrame, "RIGHT", -110, 6)
		end

    if (manaBar and not manaBar.LeftText and not manaBar.TextString and not manaBar.RightText) then
      manaBar.TextString = UnitFramesImproved:CreateStatusBarText("Text", frame:GetName().."ManaBar", frame.textureFrame, "CENTER", -50, -8)
      manaBar.LeftText = UnitFramesImproved:CreateStatusBarText("TextLeft", frame:GetName().."ManaBar", frame.textureFrame, "LEFT", 8, -8)
      manaBar.RightText = UnitFramesImproved:CreateStatusBarText("TextRight", frame:GetName().."ManaBar", frame.textureFrame, "RIGHT", -110, -8)

      -- Style the manabar fontstrings
      UnitFramesImproved:SetFontSize(manaBar.TextString, 12)
      UnitFramesImproved:SetFontSize(manaBar.LeftText, 12)
      UnitFramesImproved:SetFontSize(manaBar.RightText, 12)
    end
    
    -- Style healthbar
		local classification = UnitClassification(frame.unit)
		if (classification == "minus") then
			healthBar:SetHeight(12)
			healthBar:SetPoint("TOPLEFT",7,-41)
			if (healthBar.TextString) then
				healthBar.TextString:SetPoint("CENTER",-50,4)
			end
			frame.deadText:SetPoint("CENTER",-50,4)
			frame.Background:SetPoint("TOPLEFT",7,-41)
		else
			healthBar:SetHeight(29);
			healthBar:SetPoint("TOPLEFT",7,-22)
			if (healthBar.TextString) then
				healthBar.TextString:SetPoint("CENTER",-50,6)
			end
			frame.deadText:SetPoint("CENTER",-50,6)
			frame.nameBackground:Hide()
			frame.Background:SetPoint("TOPLEFT",7,-22)
		end
		
		healthBar:SetWidth(119)
		healthBar.lockColor = true

    -- Style frame based on
    local texture;
    if ( classification == "worldboss" or classification == "elite" ) then
      texture = "Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Elite";
    elseif ( classification == "rareelite" ) then
      texture = "Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Rare-Elite";
    elseif ( classification == "rare" ) then
      texture = "Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame-Rare";
    end
    if ( texture ) then
      frame.borderTexture:SetTexture(texture);
    else
      if ( not (classification == "minus") ) then
        frame.borderTexture:SetTexture("Interface\\Addons\\UnitFramesImproved\\Textures\\UI-TargetingFrame");
      end
    end
    
    frame.nameBackground:Hide();

    -- Style frame based on faction
    local factionGroup = UnitFactionGroup(frame.unit);
    if ( UnitIsPVPFreeForAll(frame.unit) ) then
      frame.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
      frame.pvpIcon:Show();
    elseif ( factionGroup and UnitIsPVP(frame.unit) and UnitIsEnemy("player", frame.unit) ) then
      frame.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
      frame.pvpIcon:Show();
    elseif ( factionGroup == "Alliance" or factionGroup == "Horde" ) then
      frame.pvpIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..factionGroup);
      frame.pvpIcon:Show();
    else
      frame.pvpIcon:Hide();
    end

    -- Ensure that numeric display is capped
    healthBar.breakUpLargeNumbers = true
    healthBar.capNumericDisplay = true
    manaBar.breakUpLargeNumbers = true
    manaBar.capNumericDisplay = true
  end
end

function UnitFramesImproved:Style_ToTFrame(frame)
end
