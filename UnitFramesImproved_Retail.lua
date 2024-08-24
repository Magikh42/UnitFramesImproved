-- Set up the chunk arguments to use between each chunk of the addon
local chunkArgs = ...

-- Assign a local reference to the addon
local UnitFramesImproved = chunkArgs.addon

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
    UnitFramesImproved:UpdateStatusBarColor(healthBar)
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
    UnitFramesImproved:UpdateStatusBarColor(healthBar)
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
