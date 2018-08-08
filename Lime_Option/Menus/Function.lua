
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local lime = lime
local Option = lime.optionFrame
local LBO = LibStub("LibLimeOption-1.0")

local pairs = _G.pairs

function Option:CreateAggroMenu(menu, parent)
	local function update(member)
		if member:IsVisible() and member.hasAggro then
			limeMember_UpdateDisplayText(member)
		end
	end
	menu.arrow = LBO:CreateWidget("CheckBox", parent, L["lime_func_1"], L["lime_func_desc_1"], nil, nil, true,
		function()
			return lime.db.units.useAggroArrow
		end,
		function(v)
			lime.db.units.useAggroArrow = v
			Option:UpdateMember(update)
		end
	)
	menu.arrow:SetPoint("TOPLEFT", 5, 5)
	local useList = { L["사용 안함"], L["항상"], L["파티 및 공격대"], L["공격대"] }
	menu.use = LBO:CreateWidget("DropDown", parent, L["lime_func_2"], L["lime_func_desc_2"], nil, nil, true,
		function() return lime.db.units.aggroType, useList end,
		function(v)
			lime.db.units.aggroType = v
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOP", menu.arrow, "BOTTOM", 0, -10)
	local function disable()
		return lime.db.units.aggroType == 1
	end
	menu.gain = LBO:CreateWidget("Media", parent, L["lime_func_3"], L["lime_func_desc_3"], nil, disable, true,
		function()
			return lime.db.units.aggroGain, "sound"
		end,
		function(v)
			lime.db.units.aggroGain = v
		end
	)
	menu.gain:SetPoint("TOP", menu.use, "BOTTOM", 0, -10)
	menu.lost = LBO:CreateWidget("Media", parent, L["lime_func_4"], L["lime_func_desc_4"], nil, disable, true,
		function()
			return lime.db.units.aggroLost, "sound"
		end,
		function(v)
			lime.db.units.aggroLost = v
		end
	)
	menu.lost:SetPoint("TOP", menu.gain, "TOP", 0, 0)
	menu.lost:SetPoint("RIGHT", -5, 0)
end

function Option:CreateOutlineMenu(menu, parent)
	local function update(member)
		member:SetupOutline()
		if member:IsVisible() then
			limeMember_UpdateOutline(member)
		end
	end
	local outlineList = { L["lime_func_button_1"], L["lime_func_button_2"], L["lime_func_button_3"], L["lime_func_button_4"], L["lime_func_button_5"], L["lime_func_button_6"], L["lime_func_button_7"], L["lime_func_button_8"] }
	menu.use = LBO:CreateWidget("DropDown", parent, L["lime_func_5"], L["lime_func_desc_5"], nil, nil, true,
		function()
			return lime.db.units.outline.type + 1, outlineList
		end,
		function(v)
			lime.db.units.outline.type = v - 1
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return lime.db.units.outline.type == 0
	end
	menu.scale = LBO:CreateWidget("Slider", parent, L["lime_func_6"], L["lime_func_desc_6"], nil, disable, true,
		function() return lime.db.units.outline.scale * 100, 50, 150, 1, "%" end,
		function(v)
			lime.db.units.outline.scale = v / 100
			Option:UpdateMember(update)
		end
	)
	menu.scale:SetPoint("TOP", menu.use, "BOTTOM", 0, -10)
	menu.alpha = LBO:CreateWidget("Slider", parent, L["lime_func_7"], L["lime_func_desc_7"], nil, disable, true,
		function() return lime.db.units.outline.alpha * 100, 10, 100, 1, "%" end,
		function(v)
			lime.db.units.outline.alpha = v / 100
			Option:UpdateMember(update)
		end
	)
	menu.alpha:SetPoint("TOP", menu.scale, "TOP", 0, 0)
	menu.alpha:SetPoint("RIGHT", -5, 0)
	local function getColor(key)
		return lime.db.units.outline[key][1], lime.db.units.outline[key][2], lime.db.units.outline[key][3]
	end
	local function setColor(r, g, b, key)
		lime.db.units.outline[key][1], lime.db.units.outline[key][2], lime.db.units.outline[key][3] = r, g, b
		Option:UpdateMember(update)
	end
	menu.targetColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func_8"], L["lime_func_desc_8"], function() return lime.db.units.outline.type ~= 2 end, nil, true, getColor, setColor, "targetColor")
	menu.targetColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.mouseoverColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func_8"], L["lime_func_desc_9"], function() return lime.db.units.outline.type ~= 3 end, nil, true, getColor, setColor, "mouseoverColor")
	menu.mouseoverColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.aggroColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func_8"], L["lime_func_desc_10"], function() return lime.db.units.outline.type ~= 5 end, nil, true, getColor, setColor, "aggroColor")
	menu.aggroColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	local function isLowHealth()
		return lime.db.units.outline.type ~= 4
	end
	menu.lowHealthColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func_8"], L["lime_func_desc_11"], isLowHealth, nil, true, getColor, setColor, "lowHealthColor")
	menu.lowHealthColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.lowHealth = LBO:CreateWidget("Slider", parent, L["lime_func_9"], L["lime_func_desc_12"], isLowHealth, nil, true,
		function() return lime.db.units.outline.lowHealth * 100, 1, 99, 1, "%" end,
		function(v)
			lime.db.units.outline.lowHealth = v / 100
			Option:UpdateMember(update)
		end
	)
	menu.lowHealth:SetPoint("TOP", menu.alpha, "BOTTOM", 0, -10)
	local function isRaidIcon()
		return lime.db.units.outline.type ~= 6
	end
	menu.raidIconColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func_8"], L["lime_func_desc_13"], isRaidIcon, nil, true, getColor, setColor, "raidIconColor")
	menu.raidIconColor:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	local function getRaidIcon(icon)
		return lime.db.units.outline.raidIcon[icon]
	end
	local function setRaidIcon(v, icon)
		lime.db.units.outline.raidIcon[icon] = v
		Option:UpdateMember(update)
	end
	for i, text in ipairs(Option.dropdownTable["징표"]) do
		menu["raidIcon"..i] = LBO:CreateWidget("CheckBox", parent, text, text..L["lime_func_desc_14"], isRaidIcon, nil, true, getRaidIcon, setRaidIcon, i)
		if i == 1 then
			menu["raidIcon"..i]:SetPoint("TOP", menu.raidIconColor, "BOTTOM", 0, 0)
		elseif i == 2 then
			menu["raidIcon"..i]:SetPoint("TOP", menu.raidIcon1, 0, 0)
			menu["raidIcon"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["raidIcon"..i]:SetPoint("TOP", menu["raidIcon"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
	local function isLowHealth2()
		return lime.db.units.outline.type ~= 7
	end
	menu.lowHealthColor2 = LBO:CreateWidget("ColorPicker", parent, L["lime_func_8"], L["lime_func_desc_15"], isLowHealth2, nil, true, getColor, setColor, "lowHealthColor2")
	menu.lowHealthColor2:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.lowHealth2 = LBO:CreateWidget("Slider", parent, L["lime_func_9"], L["lime_func_desc_16"], isLowHealth2, nil, true,
		function() return lime.db.units.outline.lowHealth2, 1, 5000000, 1, "" end,
		function(v)
			lime.db.units.outline.lowHealth2 = v
			Option:UpdateMember(update)
		end
	)
	menu.lowHealth2:SetPoint("TOP", menu.alpha, "BOTTOM", 0, -10)
end

function Option:CreateRangeMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_OnUpdate2(member)
		end
	end
	menu.outrange = LBO:CreateWidget("Slider", parent, L["lime_func_16"], L["lime_func_desc_17"], nil, nil, true,
		function()
			return lime.db.units.fadeOutAlpha * 100, 0, 100, 1, "%"
		end,
		function(v)
			lime.db.units.fadeOutAlpha = v / 100
			Option:UpdateMember(update)
		end
	)
	menu.outrange:SetPoint("TOPLEFT", 5, -10)

	menu.outRangeName = LBO:CreateWidget("CheckBox", parent, L["lime_layout_19"], L["lime_layout_desc_19"], nil, nil, true,
		function()
			return lime.db.units.outRangeName
		end,
		function(v)
			lime.db.units.outRangeName = v
			Option:UpdateMember(update)
		end
	)
	menu.outRangeName:SetPoint("TOP", menu.outrange, "BOTTOM", 0, -5)
	menu.mana = LBO:CreateWidget("CheckBox", parent, L["lime_func_17"], L["lime_func_desc_18"], nil, nil, true,
		function()
			return lime.db.units.fadeOutOfRangePower
		end,
		function(v)
			lime.db.units.fadeOutOfRangePower = v
			Option:UpdateMember(update)
		end
	)
	menu.mana:SetPoint("TOP", menu.outRangeName, "BOTTOM", 0, 0)

	menu.fadeOutColorFlag = LBO:CreateWidget("CheckBox", parent, L["lime_outRangeColorFlag_1"], L["lime_outRangeColorFlag_2"], nil, nil, true,
		function()
			return lime.db.units.fadeOutColorFlag
		end,
		function(v)
			lime.db.units.fadeOutColorFlag = v
			Option:UpdateMember(update)
		end
	)
	menu.fadeOutColorFlag:SetPoint("TOP", menu.mana, "BOTTOM", 0, 0)

	menu.fadeOutColor = LBO:CreateWidget("ColorPicker", parent, L["색상"], L["lime_outRangeColorFlag_3"], nil, nil, true,
		function()
			return lime.db.units.fadeOutColor[1], lime.db.units.fadeOutColor[2], lime.db.units.fadeOutColor[3]
		end,
		function(r, g, b)
			lime.db.units.fadeOutColor[1], lime.db.units.fadeOutColor[2], lime.db.units.fadeOutColor[3] = r, g, b
			Option:UpdateMember(update)
		end
	)
	menu.fadeOutColor:SetPoint("TOP", menu.fadeOutColorFlag, "BOTTOM", 0, 0)
end

function Option:CreateLostHealthMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateDisplayText(member)
		end
	end
	local typeList = { L["lime_func_button_10"], L["lime_func_button_11"], L["lime_func_button_12"], L["lime_func_button_13"], L["lime_func_button_14"] }
	menu.type = LBO:CreateWidget("DropDown", parent, L["lime_func_10"], L["lime_func_desc_19"], nil, nil, true,
		function()
			return lime.db.units.healthType + 1, typeList
		end,
		function(v)
			lime.db.units.healthType = v - 1
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.type:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return lime.db.units.healthType == 0
	end
	local rangeList = { L["항상"], L["lime_func_button_15"], L["lime_func_button_16"] }
	menu.range = LBO:CreateWidget("DropDown", parent, L["lime_func_11"], L["lime_func_desc_20"], nil, disable, true,
		function()
			return lime.db.units.healthRange, rangeList
		end,
		function(v)
			lime.db.units.healthRange = v
			Option:UpdateMember(update)
		end
	)
	menu.range:SetPoint("TOPRIGHT", -5, -5)
	menu.short = LBO:CreateWidget("CheckBox", parent, L["lime_func_12"], L["lime_func_desc_21"], nil, disable, true,
		function()
			return lime.db.units.shortLostHealth
		end,
		function(v)
			lime.db.units.shortLostHealth = v
			Option:UpdateMember(update)
		end
	)
	menu.short:SetPoint("TOP", menu.type, "BOTTOM", 0, -5)
	menu.nameEndl = LBO:CreateWidget("CheckBox", parent, L["lime_func_13"], L["lime_func_desc_22"], nil, nil, true,
		function()
			return lime.db.units.nameEndl
		end,
		function(v)
			lime.db.units.nameEndl = v
			Option:UpdateMember(lime.headers[0].members[1].SetupPowerBar)
			Option:UpdateMember(update)
			Option:UpdatePreview()
		end
	)
	menu.nameEndl:SetPoint("TOP", menu.range, "BOTTOM", 0, -5)
	menu.healthRed = LBO:CreateWidget("CheckBox", parent, L["lime_func_14"], L["lime_func_desc_23"], nil, disable, true,
		function()
			return lime.db.units.healthRed
		end,
		function(v)
			lime.db.units.healthRed = v
			Option:UpdateMember(update)
		end
	)
	menu.healthRed:SetPoint("TOP", menu.short, "BOTTOM", 0, -5)
	menu.showAbsorb = LBO:CreateWidget("CheckBox", parent, L["lime_func_15"], L["lime_func_desc_24"], nil, disable, true,
		function()
			return lime.db.units.showAbsorbHealth
		end,
		function(v)
			lime.db.units.showAbsorbHealth = v
			Option:UpdateMember(update)
		end
	)
	menu.showAbsorb:SetPoint("TOP", menu.healthRed, "BOTTOM", 0, -5)
end

function Option:UpdateIconPos()
	Option:UpdateMember(limeMember_SetupIconPos)
end

function Option:CreateBuffCheckMenu(menu, parent)
	--[[local raidBuffs = {}
	for spellId in pairs(limeCharDB.classBuff2) do
		if type(spellId) == "number" and spellId > 0 and spellId == floor(spellId) and GetSpellInfo(spellId) and not IsPassiveSpell(spellId) then
			if not (lime.raidBuffData.link and lime.raidBuffData.link[spellId]) then
				table.insert(raidBuffs, spellId)
			end
		end
	end

	if #raidBuffs == 0 then]]
		menu.text = parent:GetParent():CreateFontString(nil, "OVERLAY", "GameFontNormal")
		menu.text:SetPoint("CENTER", 0, 0)
		menu.text:SetText("The function is currently unavailable.")
		--[[return
	else
		table.sort(raidBuffs, function(a, b)
			local A, B = GetSpellInfo(a), GetSpellInfo(b)
			if A == B then
				return a < b
			else
				return A < B
			end
		end)
	end

	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_buff_2"], nil, nil, nil,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.buffIconPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.buffIconPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOPLEFT", 5, -10)
	local function updateSize(member)
		if member:IsVisible() then
			if member.buffIcon1:IsVisible() then
				member.buffIcon1:SetSize(lime.db.units.buffIconSize, lime.db.units.buffIconSize)
			end
			if member.buffIcon2:IsVisible() then
				member.buffIcon2:SetSize(lime.db.units.buffIconSize, lime.db.units.buffIconSize)
			end
		end
	end
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_buff_3"], nil, nil, nil,
		function()
			return lime.db.units.buffIconSize, 8, 20, 1, "px"
		end,
		function(v)
			lime.db.units.buffIconSize = v
			Option:UpdateMember(updateSize)
		end
	)
	menu.size:SetPoint("TOPRIGHT", -5, -10)
	]]
	--[==[
	local printedSpell = {}
	if lime.playerClass == "PALADIN" and lime.castableBuffs[1] and lime.castableBuffs[8] then
		printedSpell[lime.castableBuffs[1][1]] = 8
		printedSpell[lime.castableBuffs[8][1]] = true
	end
	]==]
	--[[
	local buffTypeList = { L["lime_func_buff_4"], L["lime_func_buff_5"], L["lime_func_buff_6"] }

	local function getBuff(spellId)
		return (limeCharDB.classBuff2[spellId] or 0) + 1, buffTypeList
	end

	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateBuffs(member)
		end
	end
	
	local function setBuff(v, spellId)
		limeCharDB.classBuff2[spellId] = v - 1
		if lime.raidBuffData.link and lime.raidBuffData.link[spellId] then ]]
--			limeCharDB.classBuff2[lime.raidBuffData.link[spellId]] = v - 1
--[[		end
		Option:UpdateMember(update)
	end

	local _, spellName, spellIcon, text

	for i, spellId in ipairs(raidBuffs) do
		spellName, _, spellIcon = GetSpellInfo(spellId)
		text = ("|T%s:0:0:0:-1|t %s"):format(spellIcon, spellName)
		if lime.raidBuffData.link then
			for p, v in pairs(lime.raidBuffData.link) do
				if v == spellId then
					spellName, _, spellIcon = GetSpellInfo(p)
					text = text..", "..("|T%s:0:0:0:-1|t %s"):format(spellIcon, spellName)
					break
				end
			end
		end
		menu["buff"..i] = LBO:CreateWidget("DropDown", parent, text, text..": "..L["lime_func_buff_7"], nil, nil, nil, getBuff, setBuff, spellId)
		if i == 1 then
			menu["buff"..i]:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
		elseif i == 2 then
			menu["buff"..i]:SetPoint("TOP", menu.size, "BOTTOM", 0, -10)
		else
			menu["buff"..i]:SetPoint("TOP", menu["buff"..(i - 2)], "BOTTOM", 0, -10)
		end
	end]]
end

function Option:CreateSpellTimerMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateSpellTimer(member)
		end
	end
	local useList = { L["lime_func_button_17"], L["lime_func_button_18"], L["lime_func_button_19"], L["lime_func_button_20"], L["lime_func_button_21"] }
	local function getUse(id)
		return limeCharDB.spellTimer[id].use + 1, useList
	end
	local function setUse(v, id)
		limeCharDB.spellTimer[id].use = v - 1
		Option:UpdateMember(update)
		LBO:Refresh(parent)
		lime:BuildSpellTimerList()
		lime:UpdateSpellTimerFont()
	end
	local function disable(id)
		return limeCharDB.spellTimer[id].use == 0
	end
	local function getPos(id)
		return Option.dropdownTable["아이콘변환"][limeCharDB.spellTimer[id].pos], Option.dropdownTable["아이콘"]
	end
	local function setPos(v, id)
		limeCharDB.spellTimer[id].pos = Option.dropdownTable["아이콘변환"][v]
		Option:UpdateIconPos()
	end
	local displayList = { L["lime_func_button_22"], L["lime_func_button_23"], L["lime_func_button_24"], L["lime_func_button_25"], L["lime_func_button_26"] }
	local function getDisplay(id)
		return limeCharDB.spellTimer[id].display, displayList
	end
	local function setDisplay(v, id)
		limeCharDB.spellTimer[id].display = v
		Option:UpdateMember(update)
		lime:BuildSpellTimerList()
		lime:UpdateSpellTimerFont()
	end
	local function getScale(id)
		return limeCharDB.spellTimer[id].scale * 100, 50, 150, 1, "%"
	end
	local function setScale(v, id)
		limeCharDB.spellTimer[id].scale = v / 100
		Option:UpdateMember(update)
		lime:BuildSpellTimerList()
		lime:UpdateSpellTimerFont()
	end
	local function getName(id)
		return limeCharDB.spellTimer[id].name or ""
	end
	local function setName(v, id)
		v = v:trim()
		limeCharDB.spellTimer[id].name = v ~= "" and v or nil
		lime:Message((L["lime_func_spelltimer_1"]):format(v))
		Option:UpdateMember(update)
		lime:BuildSpellTimerList()
		lime:UpdateSpellTimerFont()
	end
	for i, info in ipairs(limeCharDB.spellTimer) do
		menu["use"..i] = LBO:CreateWidget("DropDown", parent, L["lime_func_spelltimer_2"]..i, L["lime_func_spelltimer_2"]..i..L["lime_func_spelltimer_3"], nil, nil, true, getUse, setUse, i)
		if i == 1 then
			menu["use"..i]:SetPoint("TOP", 0, -5)
		else
			menu["use"..i]:SetPoint("TOP", menu["name"..(i - 1)], "BOTTOM", 0, -20)
		end
		menu["use"..i]:SetPoint("LEFT", 5, 0)
		menu["pos"..i] = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_spelltimer_2"]..i..L["lime_func_spelltimer_4"], nil, disable, true, getPos, setPos, i)
		menu["pos"..i]:SetPoint("TOP", menu["use"..i], "TOP", 0, 0)
		menu["pos"..i]:SetPoint("RIGHT", -5, 0)
		menu["display"..i] = LBO:CreateWidget("DropDown", parent, L["표시 방식"], L["lime_func_spelltimer_2"]..i..L["lime_func_spelltimer_5"], nil, disable, true, getDisplay, setDisplay, i)
		menu["display"..i]:SetPoint("TOP", menu["use"..i], "BOTTOM", 0, -5)
		menu["scale"..i] = LBO:CreateWidget("Slider", parent, L["lime_layout_02"], L["lime_func_spelltimer_2"]..i..L["lime_func_spelltimer_6"], nil, disable, true, getScale, setScale, i)
		menu["scale"..i]:SetPoint("TOP", menu["pos"..i], "BOTTOM", 0, -5)
		menu["name"..i] = LBO:CreateWidget("EditBox", parent, L["주문 ID"], L["lime_func_spelltimer_2"]..i..L["lime_func_spelltimer_7"], nil, disable, true, getName, setName, i)
		menu["name"..i].title:ClearAllPoints()
		menu["name"..i].title:SetPoint("TOP", 0, -3)
		menu["name"..i].box:ClearAllPoints()
		menu["name"..i].box:SetPoint("TOP", menu["name"..i].title, "BOTTOM", 0, -7)
		menu["name"..i].box:SetPoint("LEFT", 0, 0)
		menu["name"..i].box:SetPoint("RIGHT", 0, 0)
		menu["name"..i]:SetPoint("TOP", menu["display"..i], "BOTTOM", 0, -5)
		menu["name"..i]:SetPoint("LEFT", 5, 0)
		menu["name"..i]:SetPoint("RIGHT", -5, 0)
	end
end

function Option:CreateSurvivalSkillMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateSurvivalSkill(member)
			limeMember_UpdateDisplayText(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["lime_func2_1"], L["lime_func2_desc_1"], nil, nil, true,
		function()
			return lime.db.units.useSurvivalSkill
		end,
		function(v)
			lime.db.units.useSurvivalSkill = v
			LBO:Refresh(parent)
			Option:UpdateMember(update)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 0)
	menu.timer = LBO:CreateWidget("CheckBox", parent, L["lime_func2_2"], L["lime_func2_desc_2"], nil, function() return not lime.db.units.useSurvivalSkill end, true,
		function()
			return lime.db.units.showSurvivalSkillTimer
		end,
		function(v)
			lime.db.units.showSurvivalSkillTimer = v
			Option:UpdateMember(update)
		end
	)
	menu.timer:SetPoint("TOPRIGHT", -5, 0)
	menu.sub = LBO:CreateWidget("CheckBox", parent, L["lime_func2_3"], L["lime_func2_desc_3"], nil, function() return not lime.db.units.useSurvivalSkill end, true,
		function()
			return lime.db.units.showSurvivalSkillSub
		end,
		function(v)
			lime.db.units.showSurvivalSkillSub = v
			LBO:Refresh(parent)
			Option:UpdateMember(update)
		end
	)
	menu.sub:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
	menu.potion = LBO:CreateWidget("CheckBox", parent, L["lime_func2_4"], L["lime_func2_desc_4"], nil, function() return not lime.db.units.useSurvivalSkill end, true,
		function()
			return lime.db.units.showSurvivalSkillPotion
		end,
		function(v)
			lime.db.units.showSurvivalSkillPotion = v
			LBO:Refresh(parent)
			Option:UpdateMember(update)
		end
	)
	menu.potion:SetPoint("TOP", menu.timer, "BOTTOM", 0, 5)
end

function Option:CreateHealPredictionMenu(menu, parent)
	local function update(member)
		member.myHealPredictionBar:SetStatusBarColor(lime.db.units.myHealPredictionColor[1], lime.db.units.myHealPredictionColor[2], lime.db.units.myHealPredictionColor[3], lime.db.units.healPredictionAlpha)
		member.otherHealPredictionBar:SetStatusBarColor(lime.db.units.otherHealPredictionColor[1], lime.db.units.otherHealPredictionColor[2], lime.db.units.otherHealPredictionColor[3], lime.db.units.healPredictionAlpha)
		member.absorbPredictionBar:SetStatusBarColor(lime.db.units.AbsorbPredictionColor[1], lime.db.units.AbsorbPredictionColor[2], lime.db.units.AbsorbPredictionColor[3], lime.db.units.healPredictionAlpha)
		if member:IsVisible() then
			limeMember_UpdateHealPrediction(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["lime_func2_5"], L["lime_func2_desc_5"], nil, nil, true,
		function()
			return lime.db.units.displayHealPrediction
		end,
		function(v)
			lime.db.units.displayHealPrediction = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return not lime.db.units.displayHealPrediction
	end
	menu.alpha = LBO:CreateWidget("Slider", parent, L["lime_func2_6"], L["lime_func2_desc_6"], nil, disable, true,
		function() return lime.db.units.healPredictionAlpha * 100, 0, 100, 1, "%" end,
		function(v)
			lime.db.units.healPredictionAlpha = v / 100
			Option:UpdateMember(update)
		end
	)
	menu.alpha:SetPoint("TOPRIGHT", -5, -5)
	menu.myIcon = LBO:CreateWidget("CheckBox", parent, L["lime_func2_7"], L["lime_func2_desc_7"], nil, disable, true,
		function() return lime.db.units.healIcon end,
		function(v)
			lime.db.units.healIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.myIcon:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.otherIcon = LBO:CreateWidget("CheckBox", parent, L["lime_func2_8"], L["lime_func2_desc_8"], nil, disable, true,
		function() return lime.db.units.healIconOther end,
		function(v)
			lime.db.units.healIconOther = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.otherIcon:SetPoint("TOP", menu.alpha, "BOTTOM", 0, 0)
	local function disable2()
		if disable() then
			return true
		else
			return not(lime.db.units.healIcon or lime.db.units.healIconOther)
		end
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, L["lime_func2_9"], L["lime_func2_desc_9"], nil, disable2, true,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.healIconPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.healIconPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOP", menu.myIcon, "BOTTOM", 0, 0)
	menu.size = LBO:CreateWidget("Slider", parent, L["lime_func2_10"], L["lime_func2_desc_10"], nil, disable2, true,
		function()
			return lime.db.units.healIconSize, 8, 20, 1, ""
		end,
		function(v)
			lime.db.units.healIconSize = v
			Option:UpdateMember(update)
		end
	)
	menu.size:SetPoint("TOP", menu.otherIcon, "BOTTOM", 0, 0)
	menu.myColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func2_11"], L["lime_func2_desc_11"], nil, disable, true,
		function() return lime.db.units.myHealPredictionColor[1], lime.db.units.myHealPredictionColor[2], lime.db.units.myHealPredictionColor[3] end,
		function(r, g, b)
			lime.db.units.myHealPredictionColor[1], lime.db.units.myHealPredictionColor[2], lime.db.units.myHealPredictionColor[3] = r, g, b
			Option:UpdateMember(update)
		end
	)
	menu.myColor:SetPoint("TOP", menu.pos, "BOTTOM", 0, 0)
	menu.otherColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func2_12"], L["lime_func2_desc_12"], nil, disable, true,
		function() return lime.db.units.otherHealPredictionColor[1], lime.db.units.otherHealPredictionColor[2], lime.db.units.otherHealPredictionColor[3] end,
		function(r, g, b)
			lime.db.units.otherHealPredictionColor[1], lime.db.units.otherHealPredictionColor[2], lime.db.units.otherHealPredictionColor[3] = r, g, b
			Option:UpdateMember(update)
		end
	)
	menu.otherColor:SetPoint("TOP", menu.size, "BOTTOM", 0, 0)
	menu.AbsorbColor = LBO:CreateWidget("ColorPicker", parent, L["lime_func2_13"], L["lime_func2_desc_13"], nil, disable, true,
		function() return lime.db.units.AbsorbPredictionColor[1], lime.db.units.AbsorbPredictionColor[2], lime.db.units.AbsorbPredictionColor[3] end,
		function(r, g, b)
			lime.db.units.AbsorbPredictionColor[1], lime.db.units.AbsorbPredictionColor[2], lime.db.units.AbsorbPredictionColor[3] = r, g, b
			Option:UpdateMember(update)
		end
	)
	menu.AbsorbColor:SetPoint("TOP", menu.myColor, "BOTTOM", 0, 0)
end

function Option:CreateIgnoreAuraMenu(menu, parent)
	local debuffs = {}
	menu.list = LBO:CreateWidget("List", parent, L["lime_func_aura_1"], nil, nil, nil, true,
		function()
			wipe(debuffs)
			for debuff in pairs(lime.ignoreAura) do
				if lime.db.ignoreAura[debuff] ~= false then
					local text = ("%s(%d)"):format(GetSpellInfo(debuff) or "", debuff)
					tinsert(debuffs, text)
				end
			end
			for debuff, v in pairs(lime.db.ignoreAura) do
				if v == true then
					if lime.ignoreAura[debuff] then
						lime.db.ignoreAura[debuff] = nil
					else
						local text
						if type(debuff) == "number" then
							text = ("%s(%d)"):format(GetSpellInfo(debuff) or "", debuff)
						else
							text = debuff
						end
						tinsert(debuffs, text)
					end
				end
			end
			sort(debuffs)
			return debuffs, true
		end,
		function(v)
			menu.delete:Update()
		end
	)
	menu.list:SetPoint("TOPLEFT", 5, -5)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateAura(member)
		end
	end
	menu.delete = LBO:CreateWidget("Button", parent, L["lime_func_aura_2"], L["lime_func_aura_3"], nil,
		function()
			if menu.list:GetValue() then
				menu.delete.title:SetFormattedText(L["lime_func_aura_4"], debuffs[menu.list:GetValue()])
				return nil
			else
				menu.delete.title:SetText(L["lime_func_aura_2"])
				return true
			end
		end, nil,
		function()
			local name = debuffs[menu.list:GetValue()]
			lime:Message((L["lime_func_aura_5"]):format(name))
			for spellId in string.gmatch(name, "%d+") do
				name = tonumber(spellId)
			end
			if lime.ignoreAura[name] then
				lime.db.ignoreAura[name] = false
			else
				lime.db.ignoreAura[name] = nil
			end
			menu.list:Setup()
			menu.reset:Update()
			lime:BuildAuraList()
			Option:UpdateMember(update)
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.list, "BOTTOMLEFT", 0, 12)
	menu.delete:SetPoint("TOPRIGHT", menu.list, "BOTTOMRIGHT", 0, 12)
	menu.editbox = LBO:CreateEditBox(parent, nil, "ChatFontNormal", nil, true)
	menu.editbox:SetPoint("TOPLEFT", menu.delete, "BOTTOMLEFT", 2, 6)
	menu.editbox:SetPoint("TOPRIGHT", menu.delete, "BOTTOMRIGHT", -60, 6)
	menu.editbox:SetScript("OnTextChanged", function() menu.add:Update() end)
	menu.editbox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	local function add()
		local text = (menu.editbox:GetText() or ""):trim()
		local spell
		if tonumber(text) then
			spell = tonumber(text)
			text = GetSpellInfo(text) or nil
		else
			spell = text
		end
		menu.editbox:SetText("")
		menu.editbox:ClearFocus()
		if not text then
			lime:Message((L["lime_func_aura_6"]):format(spell))
		elseif lime.db.ignoreAura[spell] or lime.db.ignoreAura[text] or (lime.ignoreAura[spell] and lime.db.ignoreAura[spell] ~= false) or (lime.ignoreAura[text] and lime.db.ignoreAura[text] ~= false) then
			lime:Message((L["lime_func_aura_7"]):format(text))
		else
			lime:Message((L["lime_func_aura_8"]):format(text))
			if lime.ignoreAura[spell] then
				lime.db.ignoreAura[spell] = nil
			else
				lime.db.ignoreAura[spell] = true
			end
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			lime:BuildAuraList()
			Option:UpdateMember(update)
		end
	end
	menu.editbox:SetScript("OnEnterPressed", function(self)
		if (self:GetText() or ""):trim() ~= "" then
			add()
		else
			self:SetText("")
			self:ClearFocus()
		end
	end)
	menu.add = LBO:CreateWidget("Button", parent, L["lime_func_aura_9"], L["lime_func_aura_10"], nil, function() return (menu.editbox:GetText() or ""):trim() == "" end, true, add)
	menu.add:SetPoint("TOPLEFT", menu.editbox, "TOPRIGHT", 2, 14)
	menu.add:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
	menu.reset = LBO:CreateWidget("Button", parent, L["lime_func_aura_11"], L["lime_func_aura_12"], nil, function() return not next(lime.db.ignoreAura) end, true,
		function()
			menu.editbox:SetText("")
			menu.editbox:ClearFocus()
			wipe(lime.db.ignoreAura)
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			lime:BuildAuraList()
			Option:UpdateMember(update)
			lime:Message(L["lime_func_aura_13"])
		end
	)
	menu.reset:SetPoint("TOP", menu.add, "BOTTOM", 0, 18)
	menu.reset:SetPoint("LEFT", menu.delete, "LEFT", 0, 0)
	menu.reset:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
end

function Option:CreateDebuffIconMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateAura(member)
		end
	end
	menu.num = LBO:CreateWidget("Slider", parent, L["lime_func_aura_14"], L["lime_func_aura_15"], nil, disable, true,
		function()
			return lime.db.units.debuffIcon, 0, 5, 1, ""
		end,
		function(v)
			lime.db.units.debuffIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.num:SetPoint("TOPLEFT", 5, -5)
	local function disable()
		return lime.db.units.debuffIcon == 0
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_aura_16"], nil, disable, true,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.debuffIconPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.debuffIconPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOPRIGHT", -5, -5)
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_aura_17"], nil, disable, true,
		function()
			return lime.db.units.debuffIconSize, 4, 20, 1, ""
		end,
		function(v)
			lime.db.units.debuffIconSize = v
			Option:UpdateMember(update)
		end
	)
	menu.size:SetPoint("TOP", menu.num, "BOTTOM", 0, -10)
	local typeList = { L["lime_func_button_27"], L["lime_func_button_23"], L["색상"] }
	menu.type = LBO:CreateWidget("DropDown", parent, L["lime_func_aura_18"], L["lime_func_aura_19"], nil, disable, true,
		function()
			return lime.db.units.debuffIconType, typeList
		end,
		function(v)
			lime.db.units.debuffIconType = v
			Option:UpdateMember(lime.headers[0].members[1].SetupDebuffIcon)
		end
	)
	menu.type:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	local function getDebuff(debuff)
		return lime.db.units.debuffIconFilter[debuff]
	end
	local function setDebuff(v, debuff)
		lime.db.units.debuffIconFilter[debuff] = v
		Option:UpdateMember(update)
	end
	local colorList = { "Magic", "Curse", "Disease", "Poison", "none" }
	local colorLocale = { L["마법"], L["저주"], L["질병"], L["독"], L["무속성"] }
	for i, color in ipairs(colorList) do
		menu["color"..i] = LBO:CreateWidget("CheckBox", parent, colorLocale[i]..L["lime_func_aura_20"], colorLocale[i]..L["lime_func_aura_21"], nil, disable, true, getDebuff, setDebuff, color)
		if i == 1 then
			menu["color"..i]:SetPoint("TOP", menu.size, "BOTTOM", 0, 0)
		elseif i == 2 then
			menu["color"..i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color"..i]:SetPoint("TOP", menu["color"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
end

function Option:CreateDebuffHealthMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateState(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["lime_func_aura_22"], L["lime_func_aura_23"], nil, nil, true,
		function()
			return lime.db.units.useDispelColor
		end,
		function(v)
			lime.db.units.useDispelColor = v
			Option:UpdateMember(update)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	menu.sound = LBO:CreateWidget("Media", parent, L["lime_func_aura_24"], L["lime_func_aura_25"], nil, nil, true,
		function()
			return lime.db.units.dispelSound, "sound"
		end,
		function(v)
			lime.db.units.dispelSound = v
		end
	)
	menu.sound:SetPoint("TOPRIGHT", -5, -5)
end

function Option:CreateBossAuraMenu(menu, parent)
	local debuffs = {}
	menu.list = LBO:CreateWidget("List", parent, L["lime_func_aura_26"], nil, nil, nil, true,
		function()
			wipe(debuffs)
			for debuff in pairs(lime.bossAura) do
				if lime.db.userAura[debuff] ~= false then
					local text = ("%s(%d)"):format(GetSpellInfo(debuff) or "", debuff)
					tinsert(debuffs, text)
				end
			end
			for debuff, v in pairs(lime.db.userAura) do
				if v == true then
					if lime.bossAura[debuff] then
						lime.db.userAura[debuff] = nil
					else
						local text
						if type(debuff) == "number" then
							text = ("%s(%d)"):format(GetSpellInfo(debuff) or "", debuff)
						else
							text = debuff
						end
						tinsert(debuffs, text)
					end
				end
			end
			sort(debuffs)
			return debuffs, true
		end,
		function(v)
			menu.delete:Update()
		end
	)
	menu.list:SetPoint("TOPLEFT", 5, -5)
	local function update(member)
		if member:IsVisible() then
			limeMember_SetAuraFont(member)
			limeMember_UpdateAura(member)
		end
	end
	menu.delete = LBO:CreateWidget("Button", parent, L["lime_func_aura_2"], L["lime_func_aura_3"], nil,
		function()
			if menu.list:GetValue() then
				menu.delete.title:SetFormattedText(L["lime_func_aura_4"], debuffs[menu.list:GetValue()])
				return nil
			else
				menu.delete.title:SetText(L["lime_func_aura_2"])
				return true
			end
		end, nil,
		function()
			local name = debuffs[menu.list:GetValue()]
			lime:Message((L["lime_func_aura_27"]):format(name))
			for spellId in string.gmatch(name, "%d+") do
				name = tonumber(spellId)
			end
			lime.db.userAura[name] = false
			menu.reset:Update()
			menu.list:Setup()
			lime:BuildAuraList()
			Option:UpdateMember(update)
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.list, "BOTTOMLEFT", 0, 12)
	menu.delete:SetPoint("TOPRIGHT", menu.list, "BOTTOMRIGHT", 0, 12)
	menu.editbox = LBO:CreateEditBox(parent, nil, "ChatFontNormal", nil, true)
	menu.editbox:SetPoint("TOPLEFT", menu.delete, "BOTTOMLEFT", 2, 6)
	menu.editbox:SetPoint("TOPRIGHT", menu.delete, "BOTTOMRIGHT", -60, 6)
	menu.editbox:SetScript("OnTextChanged", function() menu.add:Update() end)
	menu.editbox:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	local function add()
		local text = (menu.editbox:GetText() or ""):trim()
		local spell
		if tonumber(text) then
			spell = tonumber(text)
			text = GetSpellInfo(text) or nil
		else
			spell = text
		end
		menu.editbox:SetText("")
		menu.editbox:ClearFocus()
		if not text then
			lime:Message((L["lime_func_aura_28"]):format(spell))
		elseif lime.db.userAura[spell] or lime.db.userAura[spell] or (lime.bossAura[spell] and lime.db.userAura[spell] ~= false) or (lime.bossAura[text] and lime.db.userAura[text] ~= false) then
			lime:Message((L["lime_func_aura_29"]):format(text))
		else
			lime:Message((L["lime_func_aura_30"]):format(text))
			if lime.bossAura[spell] then
				lime.db.userAura[spell] = nil
			else
				lime.db.userAura[spell] = true
			end
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			lime:BuildAuraList()
			Option:UpdateMember(update)
		end
	end
	menu.editbox:SetScript("OnEnterPressed", function(self)
		if (self:GetText() or ""):trim() ~= "" then
			add()
		else
			self:SetText("")
			self:ClearFocus()
		end
	end)
	menu.add = LBO:CreateWidget("Button", parent, L["lime_func_aura_9"], L["lime_func_aura_10"], nil, function() return (menu.editbox:GetText() or ""):trim() == "" end, true, add)
	menu.add:SetPoint("TOPLEFT", menu.editbox, "TOPRIGHT", 2, 14)
	menu.add:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
	menu.reset = LBO:CreateWidget("Button", parent, L["lime_func_aura_11"], L["lime_func_aura_31"], nil, function() return not next(lime.db.userAura) end, true,
		function()
			menu.editbox:SetText("")
			menu.editbox:ClearFocus()
			wipe(lime.db.userAura)
			menu.list:Setup()
			menu.reset:Update()
			menu.delete:Update()
			lime:BuildAuraList()
			Option:UpdateMember(update)
			lime:Message(L["lime_func_aura_32"])
		end
	)
	menu.reset:SetPoint("TOP", menu.add, "BOTTOM", 0, 18)
	menu.reset:SetPoint("LEFT", menu.delete, "LEFT", 0, 0)
	menu.reset:SetPoint("RIGHT", menu.delete, "RIGHT", 0, 0)
	menu.use = LBO:CreateWidget("CheckBox", parent, L["lime_func_aura_33"], L["lime_func_aura_34"], nil, nil, true,
		function() return lime.db.units.useBossAura end,
		function(v)
			lime.db.units.useBossAura = v
			Option:UpdateMember(update)
			menu.pos:Update()
			menu.size:Update()
			menu.alpha:Update()
			menu.timer:Update()
		end
	)
	menu.use:SetPoint("TOPRIGHT", -5, -5)
	local function disable()
		return not lime.db.units.useBossAura
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_aura_35"], nil, disable, true,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.bossAuraPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.bossAuraPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_aura_36"], nil, disable, true,
		function()
			return lime.db.units.bossAuraSize, 8, 60, 1, ""
		end,
		function(v)
			lime.db.units.bossAuraSize = v
			Option:UpdateMember(update)
		end
	)
	menu.size:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	local function updateAlpha(member)
		member.bossAura:SetAlpha(lime.db.units.bossAuraAlpha)
	end
	menu.alpha = LBO:CreateWidget("Slider", parent, L["lime_func_aura_37"], L["lime_func_aura_38"], nil, disable, true,
		function()
			return lime.db.units.bossAuraAlpha * 100, 0, 100, 1, "%"
		end,
		function(v)
			lime.db.units.bossAuraAlpha = v / 100
			Option:UpdateMember(updateAlpha)
		end
	)
	menu.alpha:SetPoint("TOP", menu.size, "BOTTOM", 0, -10)
	menu.timer = LBO:CreateWidget("CheckBox", parent, L["lime_func_aura_39"], L["lime_func_aura_40"], nil, disable, true,
		function()
			return lime.db.units.bossAuraTimer
		end,
		function(v)
			lime.db.units.bossAuraTimer = v
			Option:UpdateMember(update)
		end
	)
	menu.timer:SetPoint("TOP", menu.alpha, "BOTTOM", 0, -10)
	local timerTypes = { L["lime_func_buff_4"], L["lime_func_button_24"], L["lime_func_button_26"] }
	menu.timerType = LBO:CreateWidget("DropDown", parent, L["lime_func_aura_41"], L["lime_func_aura_42"], nil, disable, true,
		function()
			return lime.db.units.bossAuraOpt + 1, timerTypes
		end,
		function(v)
			lime.db.units.bossAuraOpt = v - 1
			Option:UpdateIconPos()
			Option:UpdateMember(update)
		end
	)
	menu.timerType:SetPoint("TOP", menu.timer, "BOTTOM", 0, 0)
end

function Option:CreateEnemyMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateState(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_14"], nil, nil, true,
		function() return lime.db.units.useHarm end,
		function(v)
			lime.db.units.useHarm = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	menu.color = LBO:CreateWidget("ColorPicker", parent, L["색상"], L["lime_func_other_15"], nil, function() return not lime.db.units.useHarm end, true,
		function()
			return lime.db.colors.harm[1], lime.db.colors.harm[2], lime.db.colors.harm[3]
		end,
		function(r, g, b)
			lime.db.colors.harm[1], lime.db.colors.harm[2], lime.db.colors.harm[3] = r, g, b
			Option:UpdateMember(update)
		end
	)
	menu.color:SetPoint("TOPRIGHT", -5, 5)
end

function Option:CreateRaidTargetMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateRaidIcon(member)
			limeMember_UpdateRaidIconTarget(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_16"], nil, nil, true,
		function()
			return lime.db.units.useRaidIcon
		end,
		function(v)
			lime.db.units.useRaidIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local function disable()
		return not lime.db.units.useRaidIcon
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_other_17"], nil, disable, true,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.raidIconPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.raidIconPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 10)
	menu.scale = LBO:CreateWidget("Slider", parent, L["lime_func_other_18"], L["lime_func_other_19"], nil, disable, true,
		function()
			return lime.db.units.raidIconSize, 8, 24, 1, ""
		end,
		function(v)
			lime.db.units.raidIconSize = v
			Option:UpdateMember(update)
		end
	)
	menu.scale:SetPoint("TOP", menu.pos, "TOP", 0, 0)
	menu.scale:SetPoint("RIGHT", -5, 0)
	menu.target = LBO:CreateWidget("CheckBox", parent, L["lime_func_other_20"], L["lime_func_other_21"], nil, disable, true,
		function()
			return lime.db.units.raidIconTarget
		end,
		function(v)
			lime.db.units.raidIconTarget = v
			Option:UpdateMember(update)
		end
	)
	menu.target:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)
	local function get(id)
		return lime.db.units.raidIconFilter[id]
	end
	local function set(v, id)
		lime.db.units.raidIconFilter[id] = v
		Option:UpdateMember(update)
	end
	for i, icon in ipairs(self.dropdownTable["징표"]) do
		menu["icon"..i] = LBO:CreateWidget("CheckBox", parent, icon..L["lime_func_aura_20"], icon..L["lime_func_other_22"], nil, disable, true, get, set, i)
		if i == 1 then
			menu.icon1:SetPoint("TOP", menu.target, "BOTTOM", 0, 0)
		elseif i == 2 then
			menu.icon2:SetPoint("TOP", menu.icon1, "TOP", 0, 0)
			menu.icon2:SetPoint("RIGHT", -5, 0)
		else
			menu["icon"..i]:SetPoint("TOP", menu["icon"..(i - 2)], "BOTTOM", 0, 15)
		end
	end
end

function Option:CreateCastingBarMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateCastingBar(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_23"], nil, nil, true,
		function()
			return lime.db.units.useCastingBar
		end,
		function(v)
			lime.db.units.useCastingBar = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local disable = function() return not lime.db.units.useCastingBar end
	local function updateColor(member)
		member.castingBar:SetStatusBarColor(lime.db.units.castingBarColor[1], lime.db.units.castingBarColor[2], lime.db.units.castingBarColor[3])
	end
	menu.color = LBO:CreateWidget("ColorPicker", parent, L["색상"], L["lime_func_other_24"], nil, disable, true,
		function()
			return lime.db.units.castingBarColor[1], lime.db.units.castingBarColor[2], lime.db.units.castingBarColor[3]
		end,
		function(r, g, b)
			lime.db.units.castingBarColor[1], lime.db.units.castingBarColor[2], lime.db.units.castingBarColor[3] = r, g, b
			Option:UpdateMember(updateColor)
		end
	)
	menu.color:SetPoint("TOPRIGHT", -5, 5)
	local posList = { L["상단"], L["하단"], L["좌측"], L["우측"] }
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_other_25"], nil, disable, true,
		function()
			return lime.db.units.castingBarPos, posList
		end,
		function(v)
			lime.db.units.castingBarPos = v
			Option:UpdateMember(limeMember_SetupCastingBarPos)
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_other_26"], nil, disable, true,
		function()
			return lime.db.units.castingBarHeight, 1, 5, 1, ""
		end,
		function(v)
			lime.db.units.castingBarHeight = v
			Option:UpdateMember(limeMember_SetupCastingBarPos)
		end
	)
	menu.size:SetPoint("TOP", menu.color, "BOTTOM", 0, 0)
end

function Option:CreatePowerBarAltMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdatePowerBarAlt(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_27"], nil, nil, true,
		function()
			return lime.db.units.usePowerBarAlt
		end,
		function(v)
			lime.db.units.usePowerBarAlt = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local disable = function() return not lime.db.units.usePowerBarAlt end
	local posList = { L["상단"], L["하단"], L["좌측"], L["우측"] }
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_other_28"], nil, disable, true,
		function()
			return lime.db.units.powerBarAltPos, posList
		end,
		function(v)
			lime.db.units.powerBarAltPos = v
			Option:UpdateMember(limeMember_SetupPowerBarAltPos)
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_other_29"], nil, disable, true,
		function()
			return lime.db.units.powerBarAltHeight, 1, 5, 1, ""
		end,
		function(v)
			lime.db.units.powerBarAltHeight = v
			Option:UpdateMember(limeMember_SetupPowerBarAltPos)
		end
	)
	menu.size:SetPoint("TOP", menu.pos, "TOP", 0, 0)
	menu.size:SetPoint("RIGHT", -5, 0)
end

function Option:CreateResurrectionMenu(menu, parent)
	local function update(member)
		if member:IsVisible() and (member.isDead or member.isGhost) then
			limeMember_UpdateResurrection(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_30"], nil, nil, true,
		function()
			return lime.db.units.useResurrectionBar
		end,
		function(v)
			lime.db.units.useResurrectionBar = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local function updateColor(member)
		member.resurrectionBar:SetStatusBarColor(lime.db.units.resurrectionBarColor[1], lime.db.units.resurrectionBarColor[2], lime.db.units.resurrectionBarColor[3])
	end
	menu.color = LBO:CreateWidget("ColorPicker", parent, L["색상"], L["lime_func_other_31"], nil, function() return not lime.db.units.useResurrectionBar end, true,
		function()
			return lime.db.units.resurrectionBarColor[1], lime.db.units.resurrectionBarColor[2], lime.db.units.resurrectionBarColor[3]
		end,
		function(r, g, b)
			lime.db.units.resurrectionBarColor[1], lime.db.units.resurrectionBarColor[2], lime.db.units.resurrectionBarColor[3] = r, g, b
			Option:UpdateMember(updateColor)
		end
	)
	menu.color:SetPoint("TOPRIGHT", -5, 5)
end

function Option:CreateRaidRoleMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateRoleIcon(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_32"], nil, nil, true,
		function()
			return lime.db.units.displayRaidRoleIcon
		end,
		function(v)
			lime.db.units.displayRaidRoleIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -10)
	local function disable()
		return not lime.db.units.displayRaidRoleIcon
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_other_33"], nil, disable, true,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.roleIconPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.roleIconPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
	local function updateSize(member)
		if member:IsVisible() and member.roleIcon:IsVisible() then
			member.roleIcon:SetSize(lime.db.units.roleIconSize, lime.db.units.roleIconSize)
		end
	end
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_other_34"], nil, disable, true,
		function()
			return lime.db.units.roleIconSize, 8, 20, 1, ""
		end,
		function(v)
			lime.db.units.roleIconSize = v
			Option:UpdateMember(updateSize)
		end
	)
	menu.size:SetPoint("TOP", menu.pos, "TOP", 0, 0)
	menu.size:SetPoint("RIGHT", 0, -5)

	local pack = { "Default", "MiirGui"}
	menu.pack = LBO:CreateWidget("DropDown", parent, L["lime_func_other_35"], L["lime_func_other_36"], nil, disable, true,
		function()
			return lime.db.units.roleIcontype + 1, pack
		end,
		function(v)
			lime.db.units.roleIcontype = v - 1
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.pack:SetPoint("TOP", menu.pos, "BOTTOM", 0, 5)
end

function Option:CreateCenterStatusIconMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateCenterStatusIcon(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_37"], nil, nil, true,
		function()
			return lime.db.units.centerStatusIcon
		end,
		function(v)
			lime.db.units.centerStatusIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -10)
end


function Option:CreateLeaderIconMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateLeaderIcon(member)
		end
	end
	menu.use = LBO:CreateWidget("CheckBox", parent, L["사용하기"], L["lime_func_other_38"], nil, nil, true,
		function()
			return lime.db.units.useLeaderIcon
		end,
		function(v)
			lime.db.units.useLeaderIcon = v
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -10)
	local function disable()
		return not lime.db.units.useLeaderIcon
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, L["위치"], L["lime_func_other_39"], nil, disable, true,
		function()
			return Option.dropdownTable["아이콘변환"][lime.db.units.leaderIconPos], Option.dropdownTable["아이콘"]
		end,
		function(v)
			lime.db.units.leaderIconPos = Option.dropdownTable["아이콘변환"][v]
			Option:UpdateIconPos()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
	local function updateSize(member)
		if member:IsVisible() and member.leaderIcon:IsVisible() then
			member.leaderIcon:SetSize(lime.db.units.leaderIconSize, lime.db.units.leaderIconSize)
		end
	end
	menu.size = LBO:CreateWidget("Slider", parent, L["크기"], L["lime_func_other_40"], nil, disable, true,
		function()
			return lime.db.units.leaderIconSize, 8, 20, 1, ""
		end,
		function(v)
			lime.db.units.leaderIconSize = v
			Option:UpdateMember(updateSize)
		end
	)
	menu.size:SetPoint("TOP", menu.pos, "TOP", 0, 0)
	menu.size:SetPoint("RIGHT", 0, -5)
end