local _G = _G
local next = _G.next
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local tinsert = _G.table.insert
local wipe = _G.wipe
local GetSpellInfo = _G.GetSpellInfo
local IsSpellKnown = _G.IsSpellKnown
local UnitIsPlayer = _G.UnitIsPlayer
local UnitInVehicle = _G.UnitInVehicle
local lime = _G[...]

lime.raidBuffData = {}

function limeMember_UpdateBuffs()

end

function lime:SetupClassBuff()
	self.SetupClassBuff = nil
	limeCharDB.classBuff, limeCharDB.classBuff2 = nil, type(limeCharDB.classBuff2) == "table" and limeCharDB.classBuff2 or {}
end

local playerClass = select(2, UnitClass("player"))

local classRaidBuffs = ({
	WARRIOR = {
		[6673] = { 1 },		-- [전사] 전투의 외침 (Legit 8.0)
	},
	ROGUE = {
	},
	PRIEST = {
		[21562] = { 2 },	-- 신의 권능: 인내 (Legit 8.0)
	},
	MAGE = {
		[1459] = { 3 },		-- 신비한 총명함 (Legit 8.0)
	},
	WARLOCK = {
	},
	HUNTER = {
	},
	DRUID = {
	},
	SHAMAN = {
	},
	PALADIN = {
	},
	DEATHKNIGHT = {
	},
	MONK = {
	},
	DEMONHUNTER = {
	},
})[playerClass]

if not classRaidBuffs then return end

local raidBuffs = {
	-- 전투력
	[1] = {
		6673,		-- [전사] 전투의 외침 (Legit 8.0)
	},
	-- 체력
	[2] = {
		21562,		-- [사제] 신의 권능: 인내 (Legit 8.0)
	},
	-- 지능
	[3] = {
		1459,		-- [마법사] 신비한 총명함 (Legit 8.0)
	},
}

local sameBuffs = {
	--[1459] = 61316,	-- 신비한 총명함 = 달라란의 총명함
}

lime.raidBuffData = {
	same = sameBuffs,
	link = {
		--[469] = 6673,		-- 지휘의 외침 = 전투의 외침
		--[20217] = 19740,	-- 왕의 축복 = 힘의 축복
	},
}

local linkRaidBuffs = {}

local raidBuffInfo = {}

local function addRaidBuff(tbl, spellId, isClassBuff)
	local spellName, _, spellIcon, _, _, _, spellId = GetSpellInfo(spellId)
	if spellName then
		if isClassBuff then
			for _, v in ipairs(tbl) do
				if v.id == spellId then
					return true
				end
			end
		end
		tinsert(tbl, {
			id = spellId,
			name = spellName,
			icon = spellIcon,
			passive = IsPassiveSpell(spellId)
		})
		raidBuffInfo[spellId] = tbl[#tbl]
		return true
	end
	return nil
end

for i, spellIds in pairs(raidBuffs) do
	local n = {}
	for _, spellId in ipairs(spellIds) do
		addRaidBuff(n, spellId)
	end
	raidBuffs[i] = n
end

for spellId, mask in pairs(classRaidBuffs) do
	for _, i in ipairs(mask) do
		if #raidBuffs[i] > 0 and addRaidBuff(raidBuffs[i], spellId, true) and not raidBuffInfo[spellId].passive then
			if sameBuffs[spellId] then
				addRaidBuff(raidBuffs[i], sameBuffs[spellId], true)
			end
		else
			classRaidBuffs[spellId] = nil
			sameBuffs[spellId] = nil
			break
		end
	end
end

if not next(classRaidBuffs) then return end

local currentRaidBuffs, checkMask, buffCnt, buff, buff2 = {}, {}, 0

local function showBuffIcon(icon, texture)
	icon:SetSize(lime.db.units.buffIconSize, lime.db.units.buffIconSize)
	icon:SetTexture(texture)
	icon:Show()
end

local function hideBuffIcon(icon)
	icon:SetSize(0.001, 0.001)
	icon:Hide()
end

local function getBuff(unit, spellId)
	if UnitBuff(unit, raidBuffInfo[spellId].name) then
		for _, i in ipairs(classRaidBuffs[spellId]) do
			checkMask[i] = raidBuffInfo[spellId]
		end
	elseif sameBuffs[spellId] and UnitBuff(unit, raidBuffInfo[sameBuffs[spellId]].name) then
		for _, i in ipairs(classRaidBuffs[spellId]) do
			checkMask[i] = raidBuffInfo[sameBuffs[spellId]]
		end
	else
		for _, i in ipairs(classRaidBuffs[spellId]) do
			if checkMask[i] == nil then
				checkMask[i] = false
				for _, v in ipairs(raidBuffs[i]) do
					if UnitBuff(unit, v.name) then
						checkMask[i] = v
						break
					end
				end
				if checkMask[i] == false then
					spellId = nil
					break
				end
			elseif checkMask[i] == false then
				spellId = nil
				break
			end
		end
	end
	return spellId
end

limeMember_UpdateBuffs = function(self)
	if not UnitIsPlayer(self.displayedUnit) or UnitInVehicle(self.displayedUnit) then 
		hideBuffIcon(self["buffIcon1"])
		hideBuffIcon(self["buffIcon2"])
		return 
	end
	wipe(checkMask)
	buffCnt = 0
	for spellId in pairs(currentRaidBuffs) do
		buff = getBuff(self.displayedUnit, spellId)
		if limeCharDB.classBuff2[spellId] == 1 then
			-- 버프가 없을 때 표시
			if not buff then
				buffCnt = buffCnt + 1
				showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[spellId].icon)
			end
		elseif limeCharDB.classBuff2[spellId] == 2 then
			-- 버프가 있을 때 표시
			if buff then
				buffCnt = buffCnt + 1
				showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[spellId].icon)
			end
		end
		if buffCnt == 2 then return end
	end
	for a, b in pairs(linkRaidBuffs) do
		buff = UnitBuff(self.displayedUnit, raidBuffInfo[a].name, "PLAYER")
		buff2 = not buff and UnitBuff(self.displayedUnit, raidBuffInfo[b].name, "PLAYER") or nil
		if limeCharDB.classBuff2[b] == 1 then
			-- 버프가 없을 때 표시
			if not buff and not buff2 then
				buff = getBuff(self.displayedUnit, a)
				buff2 = getBuff(self.displayedUnit, b)
				if not buff and not buff2 then
					buffCnt = buffCnt + 1
					showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[a].icon)
					if buffCnt == 1 then
						buffCnt = buffCnt + 1
						showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[b].icon)
						return
					end
				elseif not buff then
					buffCnt = buffCnt + 1
					showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[a].icon)
				elseif not buff2 then
					buffCnt = buffCnt + 1
					showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[b].icon)
				end
			end
		elseif limeCharDB.classBuff2[b] == 2 then
			-- 버프가 있을 때 표시
			if buff then
				buffCnt = buffCnt + 1
				showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[a].icon)
			elseif buff2 then
				buffCnt = buffCnt + 1
				showBuffIcon(self["buffIcon"..buffCnt], raidBuffInfo[b].icon)
			end
		end
		if buffCnt == 2 then return end
	end
	for i = buffCnt + 1, 2 do
		hideBuffIcon(self["buffIcon"..i])
	end
end

local function updateClassBuff()
	wipe(currentRaidBuffs)
	wipe(linkRaidBuffs)
	for spellId, mask in pairs(classRaidBuffs) do
		if IsSpellKnown(spellId) then
			currentRaidBuffs[spellId] = mask
		end
	end
	for a, b in pairs(lime.raidBuffData.link) do
		if currentRaidBuffs[a] and currentRaidBuffs[b] then
			linkRaidBuffs[a] = b
			currentRaidBuffs[a] = nil
			currentRaidBuffs[b] = nil
		end
	end
	if not lime.SetupClassBuff then
		for _, header in pairs(lime.headers) do
			for _, member in pairs(header.members) do
				if member:IsVisible() then
					limeMember_UpdateBuffs(member)
				end
			end
		end
	end
end

local handler = CreateFrame("Frame")
handler:SetScript("OnEvent", updateClassBuff)
handler:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
handler:RegisterEvent("PLAYER_TALENT_UPDATE")
handler:RegisterEvent("PLAYER_ENTERING_WORLD")
handler:RegisterEvent("LEARNED_SPELL_IN_TAB")

function lime:SetupClassBuff()
	self.SetupClassBuff = nil
	limeCharDB.classBuff = nil
	limeCharDB.classBuff2 = type(limeCharDB.classBuff2) == "table" and limeCharDB.classBuff2 or {}
	for spellId in pairs(limeCharDB.classBuff2) do
		if not classRaidBuffs[spellId] then
			limeCharDB.classBuff2[spellId] = nil
		end
	end
	for spellId in pairs(classRaidBuffs) do
		if raidBuffInfo[spellId].passive then
			limeCharDB.classBuff2[spellId] = nil
		elseif limeCharDB.classBuff2[spellId] ~= 0 and limeCharDB.classBuff2[spellId] ~= 1 and limeCharDB.classBuff2[spellId] ~= 2 then
			limeCharDB.classBuff2[spellId] = 1
		end
	end
	updateClassBuff()
end