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

-------------------------------------------------------
-- Core logic
-------------------------------------------------------
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
        local ver = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "1.0"
        DEFAULT_CHAT_FRAME:AddMessage(
            string.format("|cFF99CC33%s|r [v|cFF20ff20%s|r] loaded", ADDON_NAME, ver)
        )
    end
end)
