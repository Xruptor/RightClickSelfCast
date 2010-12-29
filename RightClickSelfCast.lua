--This mod makes every actionbutton of the blizzard actionbars right-click to be self-casting regardless of target.

local bars = {
"MainMenuBarArtFrame",
"MultiBarBottomLeft",
"MultiBarBottomRight",
"MultiBarRight",
"MultiBarLeft",
"BonusActionBarFrame",
"ShapeshiftBarFrame",
"PossessBarFrame",
}

for i, v in ipairs(bars) do
	local bar = getglobal(v)
	bar:SetAttribute("unit2", "player")
end

local f = CreateFrame("frame","RightClickSelfCast",UIParent)
f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function f:PLAYER_LOGIN()

	--this is for the mod ExtraBar (Author: Cowmonster)
	--http://www.wowinterface.com/downloads/info14492-ExtraBar.html
	for id=1, 12 do
		local button = getglobal("ExtraBarButton"..id)
		if button ~= nil then
			button:SetAttribute("unit2", "player")
		end
	end

	--this is for the mod ExtraBars (Author: Alternator)
	--http://www.wowinterface.com/downloads/info13335-ExtraBars.html
	for id=1, 4 do
		local frame = getglobal("ExtraBar"..id)
		if frame ~= nil then
			frame:SetAttribute("unit2", "player")
			for bid=1, 12 do
				local button = getglobal("ExtraBar"..id.."Button"..bid)
				if button ~= nil then
					button:SetAttribute("unit2", "player")
				end
			end
		end
	end

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil

end

if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end