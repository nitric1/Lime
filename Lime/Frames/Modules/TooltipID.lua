local _G = _G

function Lime:FindLine(tooltip, keyword)
    local line, text
    for i = 2, tooltip:NumLines() do
        line = _G[tooltip:GetName() .. "TextLeft" .. i]
        text = line:GetText() or ""
        if (strfind(text, keyword)) then
            return line, i, _G[tooltip:GetName() .. "TextRight" .. i]
        end
    end
end

local function ParseHyperLink(link)
	local name, value = string.match(link or "", "|?H?(%a+):(%d+):")
	if (name and value) then
		return name:gsub("^([a-z])", function(s) return strupper(s) end), value
	end
end

local function ShowId(tooltip, name, value, noBlankLine)
	if (not name or not value) then return end
	local line = Lime:FindLine(tooltip, name)
	if lime.db.LimeTooltipSpellID then
		if (not line) then
			tooltip:AddLine(format("%s: %s", name, value), 0.63, 0.9, 0.36)
			tooltip:Show()
		end
	end
end

local function ShowLinkIdInfo(tooltip, link)
	ShowId(tooltip, ParseHyperLink(link or select(2,tooltip:GetItem())))
end

-- Spell
GameTooltip:HookScript("OnTooltipSetSpell", function(self) ShowId(self, "Spell", (select(3,self:GetSpell()))) end)
hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...) ShowId(self, "Spell", (select(10,UnitAura(...)))) end)
hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...) ShowId(self, "Spell", (select(10,UnitBuff(...)))) end)
hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, ...) ShowId(self, "Spell", (select(10,UnitDebuff(...)))) end)
