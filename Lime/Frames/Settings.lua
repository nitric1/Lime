--[[
 * * * * * * * 경고! * * * * * * *
환경 변수를 임의로 수정하면 치명적인 오류가 발생합니다.
애드온에 대해 잘 아는 사람만 아래 환경 변수를 수정하시기 바랍니다.
]]

local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local lime = _G[...]
local wipe = _G.table.wipe
local LBDB = LibStub("LibLimeDB-1.1")
local version = 4

lime.classes = { "WARRIOR", "DRUID", "PALADIN", "DEATHKNIGHT", "PRIEST", "SHAMAN", "ROGUE", "MAGE", "WARLOCK", "HUNTER", "MONK", "DEMONHUNTER" }
local function newTable() return {} end
local defaultProfile = "Default"
local colorWhite = { 1, 1, 1 }
local colorRed = { 1, 0, 0 }
local colorGreen = { 0, 1, 0 }
local colorYellow = { 1, 1, 0 }

-- 기본 환경 변수 세팅
local default = {
	run = true,
	use = 1,	-- 1:항상 2:파티 및 공격대 3:공격대
	lock = false, scale = 1, lockmasterkey = false,
	-- vflag: 탑승물 추적, cflag: 호환성 플래그, cwarning = 호환성 오류 메시지 출력 여부
	vflag = false, cflag = true, cwarning = true, cpass = false, LimeAuraSoName = false, LimeTooltipSpellID = false,
	-- globaltimer = Lime의 반응 속도
	-- 반응 속도를 1.0초 이상 설정하면 레이드 프레임이 너무 느리게 정보가 반영되며, 반응 속도를 0.25초 이하로 하면 CPU 사용량이 폭증합니다.
	globaltimer = 0.5,
	-- 환경 설정
	anchor = "TOPLEFT", dir = 1, width = 80, height = 50, offset = 1, highlightAlpha = 0.5,
	border = true, borderBackdrop = { 0, 0, 0, 0 }, borderBackdropBorder = { 0.58, 0.58, 0.58, 1 },
	partyTag = true, partyTagParty = { 0.7, 0.28, 0.28, 0.8 }, partyTagRaid = { 0, 0, 0, 0.8 },
	anchor = "TOPLEFT",
	groupby = "GROUP",	-- GROUP:파티별 CLASS:직업별
	sortName = false,
	column = 8,
	grouporder = { 1, 2, 3, 4, 5, 6, 7, 8 },
	groupshown = { true, true, true, true, true, true, true, true },
	classorder = lime.classes,
	classshown = { WARRIOR = true, DRUID = true, PALADIN = true, DEATHKNIGHT = true, PRIEST = true, SHAMAN = true, ROGUE = true, MAGE = true, WARLOCK = true, HUNTER = true, MONK = true, DEMONHUNTER = true },
	useManager = true, managerPos = 25,
	castingSent = 0,	-- 0:사용 안함 1: 항상 표시 2: 마우스 오버시 표시
	units = {
		backgroundColor = { 0.10, 0.10, 0.10, 0.55 },
		orientation = 1,
		displayPowerBar = true, powerBarHeight = 0.10, powerBarPos = 2,
		displayHealPrediction = true, healPredictionAlpha = 0.35, myHealPredictionColor = colorGreen, otherHealPredictionColor = colorYellow, AbsorbPredictionColor = { 0, 0.7, 1 },
		healIcon = true, healIconOther = true, healIconPos = "BOTTOMLEFT", healIconSize = 10,
		displayRaidRoleIcon = true, roleIconPos = "TOPLEFT", roleIconSize = 12, centerStatusIcon = true, roleIcontype = 0,
		useRaidIcon = true, raidIconPos = "TOPLEFT", raidIconSize = 12, raidIconSelf = true, raidIconTarget = false, raidIconFilter = { true, true, true, true, true, true, true, true },
		useClassColors = true, className = false, outRangeName = true, offlineName = true, deathName = true,
		useBossAura = true, bossAuraSize = 18, bossAuraPos = "CENTER", bossAuraAlpha = 0.75, bossAuraTimer = true,
		bossAuraOpt = 1,	-- 1:남은 시간 2:경과 시간 0:시간 표시 안함
		useSurvivalSkill = true, showSurvivalSkillTimer = true, showSurvivalSkillSub = false, showSurvivalSkillPotion = true,
		fadeOutOfRangeHealth = true, fadeOutOfRangePower = true, fadeOutAlpha = 0.35, fadeOutColorFlag = false, fadeOutColor = { 0.2, 0.2, 0.2 },
		texture = "Smooth",
		tooltip = 2,		-- 1:항상 2:비전투중에만 3:전투중에만 0:표시안함
		healthRange = 1,	-- 1:항상 2:사정거리 안 3:사정거리 밖
		healthType = 0,	-- 1:손실생명력 2:손실생명력% 3:남은생명력 4:남은생명력% 0:표시안함
		nameEndl = false, shortLostHealth = false, healthRed = false, showAbsorbHealth = false, 
		useCastingBar = true, castingBarColor = { 0.2, 0.8, 0.2 }, castingBarHeight = 3, castingBarPos = 2, -- 1:TOP 2:BOTTOM 3:LEFT 4:RIGHT
		usePowerBarAlt = true, powerBarAltHeight = 3, powerBarAltPos = 1, -- 1:TOP 2:BOTTOM 3:LEFT 4:RIGHT
		useResurrectionBar = true, resurrectionBarColor = { 0, 0.75, 1 },
		dispelSound = "None", dispelSoundDelay = 5, useHarm = true,
		outline = {
			type = 1,	-- 1:해제 가능한 디버프 2:대상 3:마우스 오버 4:체력 낮음 5:어그로 6:전술목표 아이콘 0:사용 안함
			scale = 0.75 , alpha = 1,
			lowHealth = 0.7, lowHealthColor = colorRed,
			lowHealth2 = 10000, lowHealthColor2 = colorRed,
			raidIcon = { true, true, true, true, true, true, true, true }, raidIconColor = colorWhite,
			targetColor = colorYellow, mouseoverColor = colorYellow, aggroColor = colorRed,
		},
		targetColor = colorYellow, mouseoverColor = colorYellow, aggroColor = colorRed,
		debuffIcon = 5, debuffIconSize = 10, debuffIconPos = "TOPRIGHT", debuffIconType = 1,	-- 1:Icon+Color 2:Icon 3:Color
		debuffIconFilter = { Magic = true, Curse = true, Disease = true, Poison = true, none = true },
		buffIconSize = 12, buffIconPos = "LEFT",
		useAggroArrow = true, aggroType = 1, -- 1:사용 안함 2:항상 3:파티/공격대 4:공격대
		aggroGain = "None", aggroLost = "None",
		useDispelColor = false,
		useLeaderIcon=false, leaderIconSize=12, leaderIconPos = "TOPLEFT",
	},
	font = {
		file = "기본 글꼴", size = 12, attribute = "", shadow = true,
	},
	colors = {
		name = { 1, 1, 1 },
		help = colorGreen,
		harm = { 0.5, 0, 0 },
		vehicle = { 0, 0.4, 0 },
		offline = { 0.25, 0.25, 0.25 },
		WARRIOR = { RAID_CLASS_COLORS.WARRIOR.r, RAID_CLASS_COLORS.WARRIOR.g, RAID_CLASS_COLORS.WARRIOR.b },
		PRIEST = { RAID_CLASS_COLORS.PRIEST.r, RAID_CLASS_COLORS.PRIEST.g, RAID_CLASS_COLORS.PRIEST.b },
		ROGUE = { RAID_CLASS_COLORS.ROGUE.r, RAID_CLASS_COLORS.ROGUE.g, RAID_CLASS_COLORS.ROGUE.b },
		MAGE = { RAID_CLASS_COLORS.MAGE.r, RAID_CLASS_COLORS.MAGE.g, RAID_CLASS_COLORS.MAGE.b },
		WARLOCK = { RAID_CLASS_COLORS.WARLOCK.r, RAID_CLASS_COLORS.WARLOCK.g, RAID_CLASS_COLORS.WARLOCK.b },
		HUNTER = { RAID_CLASS_COLORS.HUNTER.r, RAID_CLASS_COLORS.HUNTER.g, RAID_CLASS_COLORS.HUNTER.b },
		DRUID = { RAID_CLASS_COLORS.DRUID.r, RAID_CLASS_COLORS.DRUID.g, RAID_CLASS_COLORS.DRUID.b },
		SHAMAN = { RAID_CLASS_COLORS.SHAMAN.r, RAID_CLASS_COLORS.SHAMAN.g, RAID_CLASS_COLORS.SHAMAN.b },
		PALADIN = { RAID_CLASS_COLORS.PALADIN.r, RAID_CLASS_COLORS.PALADIN.g, RAID_CLASS_COLORS.PALADIN.b },
		DEATHKNIGHT = { RAID_CLASS_COLORS.DEATHKNIGHT.r, RAID_CLASS_COLORS.DEATHKNIGHT.g, RAID_CLASS_COLORS.DEATHKNIGHT.b },
		MONK = { RAID_CLASS_COLORS.MONK.r, RAID_CLASS_COLORS.MONK.g, RAID_CLASS_COLORS.MONK.b },
		DEMONHUNTER = { RAID_CLASS_COLORS.DEMONHUNTER.r, RAID_CLASS_COLORS.DEMONHUNTER.g, RAID_CLASS_COLORS.DEMONHUNTER.b },
		--- Character Resources
		MANA = { PowerBarColor.MANA.r, PowerBarColor.MANA.g, PowerBarColor.MANA.b },
		RAGE = { PowerBarColor.RAGE.r, PowerBarColor.RAGE.g, PowerBarColor.RAGE.b },
		FOCUS = { PowerBarColor.FOCUS.r, PowerBarColor.FOCUS.g, PowerBarColor.FOCUS.b },
		ENERGY = { PowerBarColor.ENERGY.r, PowerBarColor.ENERGY.g, PowerBarColor.ENERGY.b },
		RUNIC_POWER = { PowerBarColor.RUNIC_POWER.r, PowerBarColor.RUNIC_POWER.g, PowerBarColor.RUNIC_POWER.b },
		LUNAR_POWER = { PowerBarColor.LUNAR_POWER.r, PowerBarColor.LUNAR_POWER.g, PowerBarColor.LUNAR_POWER.b }, --- Balance Druid
		INSANITY = { PowerBarColor.INSANITY.r, PowerBarColor.INSANITY.g, PowerBarColor.INSANITY.b }, ---Shadow Priest
		FURY = { PowerBarColor.FURY.r, PowerBarColor.FURY.g, PowerBarColor.FURY.b }, --- Demon Hunter
		PAIN = { PowerBarColor.PAIN.r, PowerBarColor.PAIN.g, PowerBarColor.PAIN.b }, --- Demon Hunter
		MAELSTROM = { PowerBarColor.MAELSTROM.r, PowerBarColor.MAELSTROM.g, PowerBarColor.MAELSTROM.b }, --- Enhancement Shaman
		--- Debuff/buffs color
		Magic = { DebuffTypeColor.Magic.r, DebuffTypeColor.Magic.g, DebuffTypeColor.Magic.b },
		Curse = { DebuffTypeColor.Curse.r, DebuffTypeColor.Curse.g, DebuffTypeColor.Curse.b },
		Disease = { DebuffTypeColor.Disease.r, DebuffTypeColor.Disease.g, DebuffTypeColor.Disease.b },
		Poison = { DebuffTypeColor.Poison.r, DebuffTypeColor.Poison.g, DebuffTypeColor.Poison.b },
		none = { DebuffTypeColor.none.r, DebuffTypeColor.none.g, DebuffTypeColor.none.b },
	},
	ignoreAura = {}, userAura = {},
}

function lime:InitDB()
	self.InitDB = nil
	if not limeDB or not limeDB.version or limeDB.version ~= version then
		limeDB = {
			version = version,
			profileKeys = {},
			profiles = {},
			minimapButton = { hide = true, radius = 80, angle = 19, dragable = true, rounding = 10 },
		}
		lime:Message(L["Lime_reset"])
	end

	for name, key in pairs(limeDB.profileKeys) do
		if not(type(name) == "string" and type(key) == "string" and limeDB.profiles[key]) then
			limeDB.profileKeys[name] = nil
		end
	end

	for _, db in pairs(limeDB.profiles) do
		LBDB:UnregisterDB(db, default)
		-- 중요 효과 체크
		if db.ignoreAura then
			for aura in pairs(self.ignoreAura) do
				if db.ignoreAura[aura] then
					db.ignoreAura[aura] = nil
				end
			end
			for aura, v in pairs(db.ignoreAura) do
				if v == false and not self.ignoreAura[aura] then
					db.ignoreAura[aura] = nil
				end
			end
		end
		if db.userAura then
			for aura in pairs(self.bossAura) do
				if db.userAura[aura] then
					db.userAura[aura] = nil
				end
			end
		end
	end
	self.profileName = UnitName("player").." - "..GetRealmName()
	self:SetProfile(limeDB.profileKeys[self.profileName])
	if limeCharDB and limeCharDB.class ~= self.playerClass then
		wipe(limeCharDB)
		limeCharDB = nil
	end
	if not limeCharDB then
		limeCharDB = { class = self.playerClass }
	end
	--self:SetupClassBuff()
	self:SetupSpellTimer()
end

function lime:SetProfile(profile)
	profile = profile or defaultProfile
	if type(profile) == "string" and profile ~= self.dbName then
		if self.dbName and limeDB.profiles[self.dbName] then
			LBDB:UnregisterDB(limeDB.profiles[self.dbName])
		end
		if profile == defaultProfile then
			limeDB.profileKeys[self.profileName] = nil
		else
			limeDB.profileKeys[self.profileName] = profile
		end
		if not limeDB.profiles[profile] then
			limeDB.profiles[profile] = {}
		end
		self.db = LBDB:RegisterDB(limeDB.profiles[profile], default, newTable)
		self.dbName = profile
	end
end

function lime:ApplyProfile()
	self:UpdateTooltipState()
	self:LoadPosition()
	self.nameWidth = self.db.width - 2
	self:SetAttribute("ready", nil)
	self:SetAttribute("startupdate", nil)
	self:SetAttribute("run", self.db.run)
	self:SetAttribute("use", self.db.use)
	self:SetAttribute("ready", true)
	self:UpdateGroupFilter()
	self:UpdateFont()
	self:BuildAuraList()
	self:BuildSpellTimerList()
	self:UpdateSpellTimerFont()
	if self.db.border then
		self.border:SetBackdropColor(unpack(self.db.borderBackdrop))
		self.border:SetBackdropBorderColor(unpack(self.db.borderBackdropBorder))
		self.border:Show()
		self.border.updater:Show()
	else
		self.border:Hide()
	end
	self:ToggleManager()
	self:HideBlizzardPartyFrame(self.db.hideBlizzardParty)
end

local groupfilter

local function setPartyTag(header)
	header.partyTag:ClearAllPoints()
	if lime.db.dir == 1 then
		if lime.db.anchor:find("TOP") then
			header.partyTag:SetPoint("BOTTOMLEFT", header, "TOPLEFT", 0, 0)
			header.partyTag:SetPoint("BOTTOMRIGHT", header, "TOPRIGHT", 0, 0)
		else
			header.partyTag:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
			header.partyTag:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
		end
		header.partyTag:SetHeight(12)
		return true
	else
		if lime.db.anchor:find("LEFT") then
			header.partyTag:SetPoint("TOPRIGHT", header, "TOPLEFT", 0, 0)
			header.partyTag:SetPoint("BOTTOMRIGHT", header, "BOTTOMLEFT", 0, 0)
		else
			header.partyTag:SetPoint("TOPLEFT", header, "TOPRIGHT", 0, 0)
			header.partyTag:SetPoint("BOTTOMLEFT", header, "BOTTOMRIGHT", 0, 0)
		end
		header.partyTag:SetWidth(12)
		return nil
	end
end

function lime:UpdateGroupFilter()
	self:SetAttribute("startupdate", nil)
	groupfilter = nil
	if self.db.partyTag and self.db.groupby == "GROUP" then
		self.headers[0].partyTag:Show()
		self.headers[0].partyTag.tex:SetColorTexture(unpack(self.db.partyTagParty))
		self.headers[0].partyTag.text:SetText(setPartyTag(self.headers[0]) and L["Lime_my_partytag"] or "P")
	else
		self.headers[0].partyTag:Hide()
	end
	self:SetAttribute("grouporder0", 0)
	if self.db.groupby == "GROUP" then
		for i = 1, 8 do
			if self.db.partyTag then
				self.headers[i].partyTag:Show()
				self.headers[i].partyTag.tex:SetColorTexture(unpack(i == self.playerGroup and self.db.partyTagParty or self.db.partyTagRaid))
				self.headers[i].partyTag.text:SetFormattedText(setPartyTag(self.headers[i]) and L["Lime_partytag"] or "%d", i)
			else
				self.headers[i].partyTag:Hide()
			end
			if self.db.groupshown[i] then
				groupfilter = (groupfilter and (groupfilter..",") or "")..i
			end
			self:SetAttribute("grouporder"..i, self.db.grouporder[i])
		end
	else
		for i = 1, 8 do
			self.headers[i].partyTag:Hide()
		end
		for i = 1, #self.db.classorder do
			if self.db.classshown[self.db.classorder[i]] then
				groupfilter = (groupfilter and (groupfilter..",") or "")..self.db.classorder[i]
			end
		end
	end
	self:SetAttribute("width", self.db.width)
	self:SetAttribute("height", self.db.height)
	self:SetAttribute("offset", self.db.offset)
	self:SetAttribute("anchor", self.db.anchor)
	self:SetAttribute("sortname", self.db.sortName)
	self:SetAttribute("dir", self.db.dir)
	self:SetAttribute("column", self.db.column)
	self:SetAttribute("partytag", self.db.groupby == "GROUP" and self.db.partyTag and 12 or 0)
	self:SetAttribute("groupby", self.db.groupby)
	self:SetAttribute("groupfilter", groupfilter or "0")
	self:SetAttribute("startupdate", true)
	if self.optionFrame.preview then
		self.optionFrame:SetPreview(self.optionFrame.preview.show)
	end
	if self.optionFrame.group then
		self.optionFrame.group:Update()
	end
	if self.optionFrame.class then
		self.optionFrame.class:Update()
	end
	self:UpdateManagerGroupFilter()
end