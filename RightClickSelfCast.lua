-- RightClickSelfCast
-- Makes right-click on action buttons self-cast on the player

local ADDON_NAME, addon = ...
if not _G[ADDON_NAME] then
    _G[ADDON_NAME] = CreateFrame(
        "Frame",
        ADDON_NAME,
        UIParent,
        BackdropTemplateMixin and "BackdropTemplate"
    )
end
addon = _G[ADDON_NAME]

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
addon:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
addon:RegisterEvent("ACTIONBAR_UPDATE_STATE")
addon:RegisterEvent("UPDATE_MULTI_ACTIONBAR")
addon:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
addon:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
addon:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
addon:RegisterEvent("UPDATE_SHAPESHIFT_BAR")
addon:RegisterEvent("UPDATE_POSSESS_BAR")
addon:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

-------------------------------------------------------
-- Core logic
-------------------------------------------------------
local blizzardBars = {
    "MainMenuBarArtFrame",
    "MainMenuBar",
    "MultiBarBottomLeft",
    "MultiBarBottomRight",
    "MultiBarRight",
    "MultiBarLeft",
    "MultiBar5",
    "MultiBar6",
    "MultiBar7",
    "MultiBar8",
    "PossessBarFrame",
}

local function ApplyBlizzardBarFallback()
    if InCombatLockdown() or UnitAffectingCombat("player") then
        return false
    end

    for _, barName in ipairs(blizzardBars) do
        local bar = _G[barName]
        if bar and bar.GetAttribute and bar.SetAttribute then
            if bar:GetAttribute("unit2") ~= "player" then
                bar:SetAttribute("unit2", "player")
            end
        end
    end

    return true
end

local fallbackApplied = false
local lastFallbackAttempt = 0
local fallbackThrottleSeconds = 1.0

local function EnsureBlizzardFallback(self)
    if fallbackApplied then
        return
    end
    local now = GetTime and GetTime() or 0
    if now > 0 and (now - lastFallbackAttempt) < fallbackThrottleSeconds then
        return
    end
    lastFallbackAttempt = now
    if not ApplyBlizzardBarFallback() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    fallbackApplied = true
    self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
    self:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
    self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
    self:UnregisterEvent("UPDATE_MULTI_ACTIONBAR")
    self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
    self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
    self:UnregisterEvent("UPDATE_VEHICLE_ACTIONBAR")
    self:UnregisterEvent("UPDATE_SHAPESHIFT_BAR")
    self:UnregisterEvent("UPDATE_POSSESS_BAR")
    self:UnregisterEvent("UPDATE_EXTRA_ACTIONBAR")
end

local function ApplySelfCast(button)
    if not button or not button.GetAttribute or not button.SetAttribute then return end
    if button:GetAttribute("type") ~= "action" then return end

    -- Apply only if needed (safe in combat at click-time)
    if button:GetAttribute("unit2") ~= "player" then
        button:SetAttribute("unit2", "player")
    end
end

-------------------------------------------------------
-- Secure click hook (single authoritative path)
-------------------------------------------------------
if type(SecureActionButton_OnClick) == "function" then
    hooksecurefunc("SecureActionButton_OnClick", function(self, mouseButton)
        if mouseButton ~= "RightButton" then return end
        ApplySelfCast(self)
    end)
end

-------------------------------------------------------
-- Events
-------------------------------------------------------
addon:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        EnsureBlizzardFallback(self)
        local ver = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "1.0"
        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded", ADDON_NAME, ver)
        )
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        EnsureBlizzardFallback(self)
        if fallbackApplied then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end
        return
    end
    EnsureBlizzardFallback(self)
end)
