local _G = _G
local lime = _G[...]
local pairs = _G.pairs
local wipe = _G.table.wipe
local InCombatLockdown = _G.InCombatLockdown
local GetSpellInfo = _G.GetSpellInfo
local SpellHasRange = _G.SpellHasRange
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local talent, specId, ctype, ckey, ckey1, ckey2, spellName, wheelScript, wheelCount, prev_wheelCount
local modifilters = { [""] = true, ["alt-"] = true, ["ctrl-"] = true, ["shift-"] = true, ["alt-ctrl-"] = true, ["alt-shift-"] = true, ["ctrl-shift-"] = true }
lime.numMouseButtons = 15
local startWheelButton = 31
local clearWheelBinding = "self:ClearBindings()"
local state = {}


lime.overrideClickCastingSpells = {
	ROGUE = {
	},
	DRUID = {
	},
	MAGE = {
	},
	HUNTER = {
	},
	PRIEST = {
	},
	PALADIN = {
	},
	MONK = {
	},
	WARRIOR = {
	},
	SHAMAN = {
	},
	DEATHKNIGHT = {
	},
	WARLOCK = {
	},
	DEMONHUNTER = {
	},
}

do
	local overrideSpells = {}
	for c, spells in pairs(lime.overrideClickCastingSpells) do
		for p, v in pairs(spells) do
			if p and v and p ~= v then
				 overrideSpells[c] = overrideSpells[c] or {}
				 overrideSpells[c][p] = v
			end
		end
	end
	for c, spells in pairs(overrideSpells) do
		for p, v in pairs(spells) do
			lime.overrideClickCastingSpells[c][p] = v
		end
	end
end

function lime:GetClickCasting(modifilter, button)
	ckey = lime.ccdb[modifilter..button]
	if ckey == "togglemenu" then
		ckey = "togglemenu"
		lime.ccdb[modifilter..button] = ckey
	end
	if ckey then
		ctype, ckey1 = ckey:match("(.+)__(.+)")
		if ctype == "macrotext" then
			return "macro", ctype, ckey1
		elseif ctype == "spell" then
			if not SpellHasRange(ckey1) then
				if self.overrideClickCastingSpells[self.playerClass] then
					spellName = self.overrideClickCastingSpells[self.playerClass][ckey1]
				elseif self.overrideClickCastingSpells[self.specId] then
					spellName = self.overrideClickCastingSpells[self.specId][ckey1]
				else
					spellName = nil
				end
				if spellName and SpellHasRange(spellName) then
					ckey1 = spellName
				end
			end
			return ctype, ctype, ckey1
		elseif ctype then
			return ctype, ctype, ckey1
		else
			return ckey
		end
	end
	return nil
end


local function reset(member, modifilter, button, ctype)
	member:SetAttribute(modifilter.."type"..button, ctype)
	member:SetAttribute(modifilter.."spell"..button, nil)
	member:SetAttribute(modifilter.."item"..button, nil)
	member:SetAttribute(modifilter.."macro"..button, nil)
	member:SetAttribute(modifilter.."macrotext"..button, nil)
end


local function setupMembers(func, ...)
	for _, header in pairs(lime.headers) do
		for _, member in pairs(header.members) do
			func(member, ...)
		end
	end
end

local function setClickCasting(member, modifilter, button, ctype, ckey1, ckey2)
	reset(member, modifilter, button, ctype)
	if ckey1 then
		member:SetAttribute(modifilter..ckey1..button, ckey2)
	end
end

function lime:SetClickCasting(modifilter, button)
	ctype, ckey1, ckey2 = self:GetClickCasting(modifilter, button)
	setupMembers(setClickCasting, modifilter, button, ctype, ckey1, ckey2)
end

local function setClickCastingWheel(modifilter, wheel, button)
	ctype, ckey1, ckey2 = lime:GetClickCasting(modifilter, wheel)
	if ckey1 == "macro" then
		wheelScript = wheelScript.." self:SetBindingMacro(1, '"..modifilter.."MOUSE"..wheel.."', '"..ckey2.."')"
	elseif ctype then
		for i = startWheelButton, button + 1, -1 do
			if lime.headers[1].members[1]:GetAttribute("type"..i) == ctype and lime.headers[1].members[1]:GetAttribute(ckey1..i) == ckey2 then
				wheelScript = wheelScript.." self:SetBindingClick(1, '"..modifilter.."MOUSE"..wheel.."', self, 'Button"..i.."')"
				return button
			end
		end
		wheelScript = wheelScript.." self:SetBindingClick(1, '"..modifilter.."MOUSE"..wheel.."', self, 'Button"..button.."')"
		setupMembers(setClickCasting, "", button, ctype, ckey1, ckey2)
		return button - 1
	end
	return button
end

local dummyWheel = function() end

local function overrideWheel(member, has)
	lime:UnwrapScript(member, "OnEnter")
	lime:UnwrapScript(member, "OnLeave")
	lime:UnwrapScript(member, "OnHide")
	lime:WrapScript(member, "OnEnter", wheelScript)
	lime:WrapScript(member, "OnLeave", clearWheelBinding)
	lime:WrapScript(member, "OnHide", clearWheelBinding)
end

function lime:SetClickCastingMouseWheel()
	wheelScript, wheelCount = clearWheelBinding, startWheelButton
	for modifilter in pairs(modifilters) do
		wheelCount = setClickCastingWheel(modifilter, "WHEELUP", wheelCount)
		wheelCount = setClickCastingWheel(modifilter, "WHEELDOWN", wheelCount)
	end
	setupMembers(overrideWheel)
	if prev_wheelCount then
		for i = prev_wheelCount, wheelCount do
			setupMembers(setClickCasting, "", i)
		end
	end
	prev_wheelCount, wheelScript, wheelCount = wheelCount + 1
end

function lime:SelectClickCastingDB()
	if InCombatLockdown() or not limeCharDB then return end
	limeCharDB.clickCasting = limeCharDB.clickCasting or { {}, {}, {}, {} }
	--for i = 1, 4 do
	--	limeCharDB.clickCasting[i] = limeCharDB.clickCasting[i] or {}
	--end
	lime.playerClass = lime.playerClass or select(2, UnitClass("player"))
	lime.specId, specId = GetSpecializationInfo(GetSpecialization(false, false, 0) or 0), lime.specId--현재 사용 안함. 추후 사용을 위해 남겨둠.
	lime.talent, talent = GetSpecialization() or 1, lime.talent

	if lime.specId ~= specId or lime.talent ~= talent then
		lime.ccdb = limeCharDB.clickCasting[lime.talent]
		for modifilter in pairs(modifilters) do
			for button = 1, lime.numMouseButtons do
				lime:SetClickCasting(modifilter, button)
			end
		end
		lime:SetClickCastingMouseWheel()
		if lime.optionFrame.UpdateClickCasting then
			lime.optionFrame:UpdateClickCasting()
		end
	end
end

local handler = CreateFrame("Frame")
handler:SetScript("OnEvent", lime.SelectClickCastingDB)
handler:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
handler:RegisterEvent("PLAYER_TALENT_UPDATE")
handler:RegisterEvent("PLAYER_LOGIN")
handler:RegisterEvent("PLAYER_ENTERING_WORLD")
handler:RegisterEvent("PLAYER_REGEN_ENABLED")
handler:RegisterEvent("LEARNED_SPELL_IN_TAB")
