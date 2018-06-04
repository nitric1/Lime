local _G = _G
local UnitExists = _G.UnitExists
local UnitIsUnit = _G.UnitIsUnit
local GetCursorPosition = _G.GetCursorPosition
local lime = _G[...]

local cx, cy, uiScale

local function showPing(member, cursor)
	lime.ping:ClearAllPoints()
	if cursor then
		cx, cy = GetCursorPosition()
		uiScale = UIParent:GetEffectiveScale()
		lime.ping:SetPoint("CENTER", nil, "BOTTOMLEFT", cx / uiScale, cy / uiScale)
		cx, cy, uiScale = nil
	else
		lime.ping:SetPoint("CENTER", member, 0, 0)
	end
	lime.ping:Show()
end

function lime:UNIT_SPELLCAST_SENT(unit, spell, _, target)
	if target and UnitExists(target) then
		if self.db.castingSent ~= 0 then
			if self.onEnter and self.onEnter.displayedUnit and UnitIsUnit(self.onEnter.displayedUnit, target) then
				showPing(self.onEnter, true)
			elseif self.db.castingSent == 1 then
				for member in pairs(self.visibleMembers) do
					if member.displayedUnit and UnitIsUnit(member.displayedUnit, target) then
						showPing(member)
						break
					end
				end
			end
		end
	end
end

lime:RegisterEvent("UNIT_SPELLCAST_SENT")
