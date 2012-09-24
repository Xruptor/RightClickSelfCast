--This mod makes every actionbutton of the blizzard actionbars right-click to be self-casting regardless of target.

local bars = {
"MainMenuBarArtFrame",
"MultiBarBottomLeft",
"MultiBarBottomRight",
"MultiBarRight",
"MultiBarLeft",
--"BonusActionBarFrame",
--"ShapeshiftBarFrame",
"PossessBarFrame",
}

local f = CreateFrame("frame","RightClickSelfCast",UIParent)
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function f:PLAYER_REGEN_ENABLED()
	self:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self.PLAYER_REGEN_ENABLED = nil
end

function f:PLAYER_LOGIN()

	-- if we load/reload in combat don't try to set secure attributes or we get action_blocked errors
	if InCombatLockdown() or UnitAffectingCombat("player") then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	
	-- Blizzard bars
	for i, v in ipairs(bars) do
		local bar = _G[v]
		if bar ~= nil then
			bar:SetAttribute("unit2", "player")
		end
	end
	
	-- this is for the mod ExtraBar (Author: Cowmonster)
	-- http://www.wowinterface.com/downloads/info14492-ExtraBar.html
	for id=1, 12 do
		local button = _G["ExtraBarButton"..id]
		if button ~= nil then
			button:SetAttribute("unit2", "player")
		end
	end

	-- this is for the mod ExtraBars (Author: Alternator)
	-- http://www.wowinterface.com/downloads/info13335-ExtraBars.html
	for id=1, 4 do
		local frame = _G["ExtraBar"..id]
		if frame ~= nil then
			frame:SetAttribute("unit2", "player")
			for bid=1, 12 do
				local button = _G["ExtraBar"..id.."Button"..bid]
				if button ~= nil then
					button:SetAttribute("unit2", "player")
				end
			end
		end
	end
	
	-- ElvUI 3.05+ (Author: Elv22, TukUI fork)
	-- http://www.wowinterface.com/downloads/info17749-ElvUI.html
	local barID = 1
	while _G["ElvUI_Bar"..barID] do
		for	_,button in next,_G["ElvUI_Bar"..barID].buttons,nil do
			button:SetAttribute("unit2", "player")
		end
		barID = barID+1
	end
	
	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil

end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
