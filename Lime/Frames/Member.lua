
-- 전역 변수 및 지역 변수 초기화
local _G = _G
local lime, noOption = ...
local pairs = _G.pairs
local ipairs = _G.ipairs
local unpack = _G.unpack
local select = _G.select
local tinsert = _G.table.insert
local max = _G.math.max
local min = _G.math.min
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitPowerType = _G.UnitPowerType
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local UnitInRange = _G.UnitInRange
local UnitIsGhost = _G.UnitIsGhost
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsAFK = _G.UnitIsAFK
local UnitIsUnit = _G.UnitIsUnit
local UnitCanAttack = _G.UnitCanAttack
local UnitIsConnected = _G.UnitIsConnected
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitGetIncomingHeals = _G.UnitGetIncomingHeals
local UnitGetTotalAbsorbs = _G.UnitGetTotalAbsorbs
local UnitIsPlayer = _G.UnitIsPlayer
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitClass = _G.UnitClass
local UnitDistanceSquared = _G.UnitDistanceSquared
local UnitInOtherParty = _G.UnitInOtherParty
local UnitHasIncomingResurrection = _G.UnitHasIncomingResurrection
local UnitInPhase = _G.UnitInPhase
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local InCombatLockdown = _G.InCombatLockdown
local GetTime = _G.GetTime
local SM = LibStub("LibSharedMedia-3.0")
local eventHandler = {}
lime = _G[lime]
lime.visibleMembers = {}

function lime:SetupAll(update)
	for _, header in pairs(self.headers) do
		for _, member in pairs(header.members) do
			member:Setup()
		end
	end
end

local statusBarTexture = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill"

local function setupMemberTexture(self)
	statusBarTexture = SM:Fetch("statusbar", lime.db.units.texture)
	self.powerBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", -1)
	self.healthBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", -1)
	self.myHealPredictionBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", -2)
	self.myHealPredictionBar:SetStatusBarColor(lime.db.units.myHealPredictionColor[1], lime.db.units.myHealPredictionColor[2], lime.db.units.myHealPredictionColor[3], lime.db.units.healPredictionAlpha)
	self.otherHealPredictionBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", -3)
	self.otherHealPredictionBar:SetStatusBarColor(lime.db.units.otherHealPredictionColor[1], lime.db.units.otherHealPredictionColor[2], lime.db.units.otherHealPredictionColor[3], lime.db.units.healPredictionAlpha)
	self.absorbPredictionBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", -4)
	self.absorbPredictionBar:SetStatusBarColor(lime.db.units.AbsorbPredictionColor[1], lime.db.units.AbsorbPredictionColor[2], lime.db.units.AbsorbPredictionColor[3], lime.db.units.healPredictionAlpha)
	self.overAbsorbGlow:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	self.overAbsorbGlow:SetDrawLayer("OVERLAY", 2)
	self.overAbsorbGlow:SetBlendMode("ADD")
	self.overAbsorbGlow:ClearAllPoints()
	self.overAbsorbGlow:SetPoint("BOTTOMRIGHT", self.healthBar, "BOTTOMRIGHT", 7, 0)
	self.overAbsorbGlow:SetPoint("TOPRIGHT", self.healthBar, "TOPRIGHT", 7, 0)
	self.overAbsorbGlow:SetWidth(16)
	self.overAbsorbGlow:SetAlpha(0.4)
	if self.castingBar then
		self.castingBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", 4)
		self.castingBar:SetStatusBarColor(lime.db.units.castingBarColor[1], lime.db.units.castingBarColor[2], lime.db.units.castingBarColor[3])
	end
	if self.powerBarAlt then
		self.powerBarAlt:SetStatusBarTexture(statusBarTexture, "OVERLAY", 1)
		self.powerBarAlt:SetStatusBarColor(self.powerBarAlt.r or 1, self.powerBarAlt.g or 1, self.powerBarAlt.b or 1)
	end
	if self.resurrectionBar then
		self.resurrectionBar:SetStatusBarTexture(statusBarTexture, "OVERLAY", 5)
		self.resurrectionBar:SetStatusBarColor(lime.db.units.resurrectionBarColor[1], lime.db.units.resurrectionBarColor[2], lime.db.units.resurrectionBarColor[3])
	end
	if self.bossAura then
		self.bossAura:SetAlpha(lime.db.units.bossAuraAlpha)
	end
	if self.centerStatusIcon then
		self.centerStatusIcon:ClearAllPoints()
		self.centerStatusIcon:SetPoint("CENTER", self, "BOTTOM", 0, lime.db.height / 3 + 2)
		self.centerStatusIcon:SetSize(18, 18)
	end
end

local function setHorizontal(bar)
	bar:SetOrientation("HORIZONTAL")
	bar:ClearAllPoints()
	bar:SetPoint("TOPLEFT", bar:GetParent(), "TOPLEFT", 0, 0)
	bar:GetParent().orientation = 1
end

local function setVertical(bar, parent)
	bar:SetOrientation("VERTICAL")
	bar:ClearAllPoints()
	bar:SetPoint("BOTTOMLEFT", bar:GetParent(), "BOTTOMLEFT", 0, 0)
	bar:GetParent().orientation = 2
end

local function setupMemberBarOrientation(self)
	if lime.db.units.orientation == 1 then
		self.healthBar:SetOrientation("HORIZONTAL")
		setHorizontal(self.myHealPredictionBar)
		setHorizontal(self.otherHealPredictionBar)
		setHorizontal(self.absorbPredictionBar)
	else
		self.healthBar:SetOrientation("VERTICAL")
		setVertical(self.myHealPredictionBar)
		setVertical(self.otherHealPredictionBar)
		setVertical(self.absorbPredictionBar)
	end
end

local function setupMemberPowerBar(self)
	self.healthBar:ClearAllPoints()
	self.powerBar:ClearAllPoints()
	if lime.db.units.nameEndl then
		self.name:SetPoint("CENTER", self.healthBar, 0, 5)
		self.losttext:SetPoint("TOP", self.name, "BOTTOM", 0, -2)
	else
		self.name:SetPoint("CENTER", self.healthBar, 0, 0)
		self.losttext:SetPoint("TOP", self.name, "BOTTOM", 0, -2)--no use
	end
	if lime.db.units.powerBarPos == 1 or lime.db.units.powerBarPos == 2 then
		self.powerBar:SetWidth(0)
		self.powerBar:SetOrientation("HORIZONTAL")
		if lime.db.units.powerBarHeight > 0 then
			self.powerBar:SetHeight(lime.db.height * lime.db.units.powerBarHeight)
		else
			self.powerBar:SetHeight(0.001)
		end
		if lime.db.units.powerBarPos == 1 then
			self.healthBar:SetPoint("TOPLEFT", self.powerBar, "BOTTOMLEFT", 0, 0)
			self.healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
			self.powerBar:SetPoint("TOPLEFT", 0, 0)
			self.powerBar:SetPoint("TOPRIGHT", 0, 0)
		else
			self.healthBar:SetPoint("TOPLEFT", 0, 0)
			self.healthBar:SetPoint("BOTTOMRIGHT", self.powerBar, "TOPRIGHT", 0, 0)
			self.powerBar:SetPoint("BOTTOMLEFT", 0, 0)
			self.powerBar:SetPoint("BOTTOMRIGHT", 0, 0)
		end
	else
		self.powerBar:SetHeight(0)
		self.powerBar:SetOrientation("VERTICAL")
		if lime.db.units.powerBarHeight > 0 then
			self.powerBar:SetWidth(lime.db.width * lime.db.units.powerBarHeight)
		else
			self.powerBar:SetWidth(0.001)
		end
		if lime.db.units.powerBarPos == 3 then
			self.healthBar:SetPoint("TOPLEFT", self.powerBar, "TOPRIGHT", 0, 0)
			self.healthBar:SetPoint("BOTTOMRIGHT", 0, 0)
			self.powerBar:SetPoint("TOPLEFT", 0, 0)
			self.powerBar:SetPoint("BOTTOMLEFT", 0, 0)
		else
			self.healthBar:SetPoint("TOPLEFT", 0, 0)
			self.healthBar:SetPoint("BOTTOMRIGHT", self.powerBar, "BOTTOMLEFT", 0, 0)
			self.powerBar:SetPoint("TOPRIGHT", 0, 0)
			self.powerBar:SetPoint("BOTTOMRIGHT", 0, 0)
		end
	end
end

local function checkMouseOver(self)
	if not UnitIsUnit(self:GetParent().displayedUnit, "mouseover") then
		self:Hide()
	end
end

local function setupMemberOutline(self)
	self.outline:SetScript("OnUpdate", nil)
	self.outline:SetScale(self.optionTable.outline.scale)
	self.outline:SetAlpha(self.optionTable.outline.alpha)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
	if self.optionTable.outline.type == 2 then
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self.outline:SetBackdropBorderColor(self.optionTable.outline.targetColor[1], self.optionTable.outline.targetColor[2], self.optionTable.outline.targetColor[3])
	elseif self.optionTable.outline.type == 3 then
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		self.outline:SetBackdropBorderColor(self.optionTable.outline.mouseoverColor[1], self.optionTable.outline.mouseoverColor[2], self.optionTable.outline.mouseoverColor[3])
		self.outline:SetScript("OnUpdate", checkMouseOver)
	elseif self.optionTable.outline.type == 4 then
		self.outline:SetBackdropBorderColor(self.optionTable.outline.lowHealthColor[1], self.optionTable.outline.lowHealthColor[2], self.optionTable.outline.lowHealthColor[3])
	elseif self.optionTable.outline.type == 5 then
		self.outline:SetBackdropBorderColor(self.optionTable.outline.aggroColor[1], self.optionTable.outline.aggroColor[2], self.optionTable.outline.aggroColor[3])
	elseif self.optionTable.outline.type == 6 then
		self.outline:SetBackdropBorderColor(self.optionTable.outline.raidIconColor[1], self.optionTable.outline.raidIconColor[2], self.optionTable.outline.raidIconColor[3])
	elseif self.optionTable.outline.type == 7 then
		self.outline:SetBackdropBorderColor(self.optionTable.outline.lowHealthColor2[1], self.optionTable.outline.lowHealthColor2[2], self.optionTable.outline.lowHealthColor2[3])
	else
		self.outline:Hide()
	end
end

local function setupMemberDebuffIcon(self)
	if self.optionTable.debuffIconType == 1 then
		for i = 1, 5 do
			self["debuffIcon"..i].color:ClearAllPoints()
			self["debuffIcon"..i].color:SetAllPoints()
			self["debuffIcon"..i].color:Show()
			self["debuffIcon"..i].icon:ClearAllPoints()
			self["debuffIcon"..i].icon:SetPoint("TOPLEFT", 1, -1)
			self["debuffIcon"..i].icon:SetPoint("BOTTOMRIGHT", -1, 1)
			self["debuffIcon"..i].icon:Show()
		end
	elseif self.optionTable.debuffIconType == 2 then
		for i = 1, 5 do
			self["debuffIcon"..i].color:Hide()
			self["debuffIcon"..i].icon:ClearAllPoints()
			self["debuffIcon"..i].icon:SetPoint("TOPLEFT", 1, -1)
			self["debuffIcon"..i].icon:SetPoint("BOTTOMRIGHT", -1, 1)
			self["debuffIcon"..i].icon:Show()
		end
	else
		for i = 1, 5 do
			self["debuffIcon"..i].color:ClearAllPoints()
			self["debuffIcon"..i].color:SetPoint("TOPLEFT", 1, -1)
			self["debuffIcon"..i].color:SetPoint("BOTTOMRIGHT", -1, 1)
			self["debuffIcon"..i].color:Show()
			self["debuffIcon"..i].icon:Hide()
		end
	end
end

local function setupMemberAll(self)
	limeMember_SetOptionTable(self, lime.db.units)
	self.background:SetColorTexture(lime.db.units.backgroundColor[1], lime.db.units.backgroundColor[2], lime.db.units.backgroundColor[3], lime.db.units.backgroundColor[4])
	setupMemberTexture(self)
	setupMemberPowerBar(self)
	setupMemberBarOrientation(self)
	setupMemberOutline(self)
	setupMemberDebuffIcon(self)
	limeMember_SetupPowerBarAltPos(self)
	limeMember_SetupCastingBarPos(self)
	limeMember_SetupIconPos(self)
	limeMember_SetAuraFont(self)

	self.name:SetFont(SM:Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
	self.name:SetShadowColor(0, 0, 0)
	if lime.db.font.shadow then
		self.name:SetShadowOffset(1, -1)
	else
		self.name:SetShadowOffset(0, 0)
	end
	self.losttext:SetFont(SM:Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
	self.losttext:SetShadowColor(0, 0, 0)
	if lime.db.font.shadow then
		self.losttext:SetShadowOffset(1, -1)
	else
		self.losttext:SetShadowOffset(0, 0)
	end
	limeMember_UpdateAll(self)
end

local function updateHealPredictionBarSize(self)
	self = self:GetParent()
	self.myHealPredictionBar:SetWidth(self.healthBar:GetWidth())
	self.myHealPredictionBar:SetHeight(self.healthBar:GetHeight())
	self.otherHealPredictionBar:SetWidth(self.healthBar:GetWidth())
	self.otherHealPredictionBar:SetHeight(self.healthBar:GetHeight())
	self.absorbPredictionBar:SetWidth(self.healthBar:GetWidth())
	self.absorbPredictionBar:SetHeight(self.healthBar:GetHeight())
end

local function getUnitPetOrOwner(unit)
	if unit then
		if unit == "player" then
			return "pet"
		elseif unit == "vehicle" or unit == "pet" then
			return "player"
		elseif unit:find("pet") then
			return (unit:gsub("pet", ""))
		else
			return (unit:gsub("(%d+)", "pet%1"))
		end
	end
	return nil
end

local function baseOnAttributeChanged(self, key, value)
	if key == "unit" then
		if value then
			key = getUnitPetOrOwner(value)
			self:RegisterUnitEvent("UNIT_NAME_UPDATE", value, key)
			self:RegisterUnitEvent("UNIT_CONNECTION", value, key)
			self:RegisterUnitEvent("UNIT_HEALTH", value, key)
			self:RegisterUnitEvent("UNIT_MAXHEALTH", value, key)
			self:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", value, key)
			self:RegisterUnitEvent("UNIT_HEAL_PREDICTION", value, key)
			self:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", value, key)
			self:RegisterUnitEvent("UNIT_POWER_UPDATE", value, key)
			self:RegisterUnitEvent("UNIT_MAXPOWER", value, key)
			self:RegisterUnitEvent("UNIT_DISPLAYPOWER", value, key)
			self:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", value, key)
			self:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", value, key)
			self:RegisterUnitEvent("UNIT_AURA", value, key)
		else
			self:UnregisterEvent("UNIT_NAME_UPDATE")
			self:UnregisterEvent("UNIT_CONNECTION")
			self:UnregisterEvent("UNIT_HEALTH")
			self:UnregisterEvent("UNIT_MAXHEALTH")
			self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
			self:UnregisterEvent("UNIT_HEAL_PREDICTION")
			self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
			self:UnregisterEvent("UNIT_POWER_UPDATE")
			self:UnregisterEvent("UNIT_MAXPOWER")
			self:UnregisterEvent("UNIT_DISPLAYPOWER")
			self:UnregisterEvent("UNIT_POWER_BAR_SHOW")
			self:UnregisterEvent("UNIT_POWER_BAR_HIDE")
			self:UnregisterEvent("UNIT_AURA")
		end
	end
end

function limeMember_SetOptionTable(self, optionTable)
	self.optionTable = optionTable
end

function limeBase_OnLoad(self)
	self:RegisterForClicks("AnyUp")
	self:RegisterForDrag("LeftButton", "RightButton")
	self.timer, self.health, self.maxHealth, self.lostHealth, self.overAbsorb = 0, 0, 1, 0, 0
	limeMember_SetOptionTable(self, noOption)
	self.healthBar:SetScript("OnSizeChanged", updateHealPredictionBarSize)
	setHorizontal(self.myHealPredictionBar)
	setHorizontal(self.otherHealPredictionBar)
	setHorizontal(self.absorbPredictionBar)
	self:SetFrameStrata("MEDIUM")
	self:SetFrameLevel(self:GetParent():GetFrameLevel())
	self:HookScript("OnAttributeChanged", baseOnAttributeChanged)
	--RegisterUnitWatch(self)
end

local function memberOnAttributeChanged(self, key, value)
	if key == "unit" then
		if value then
			key = getUnitPetOrOwner(value)
			self:RegisterUnitEvent("READY_CHECK_CONFIRM", value, key)
			self:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", value, key)
			self:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", value, key)
			self:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", value, key)
			self:RegisterUnitEvent("UNIT_EXITED_VEHICLE", value, key)
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", value, key)
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", value, key)
			self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", value, key)
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", value, key)
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", value, key)
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", value, key)
			self:RegisterUnitEvent("UNIT_FLAGS", value, key)
		else
			self:UnregisterEvent("READY_CHECK_CONFIRM")
			self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE")
			self:UnregisterEvent("UNIT_THREAT_LIST_UPDATE")
			self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
			self:UnregisterEvent("UNIT_EXITED_VEHICLE")
			self:UnregisterEvent("UNIT_SPELLCAST_START")
			self:UnregisterEvent("UNIT_SPELLCAST_STOP")
			self:UnregisterEvent("UNIT_SPELLCAST_DELAYED")
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START")
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
			self:UnregisterEvent("UNIT_FLAGS")
		end
	end
end


function limeMember_OnLoad(self)
	limeBase_OnLoad(self)
	self.UpdateAll = limeMember_UpdateAll
	self.Setup = setupMemberAll
	self.SetupTexture = setupMemberTexture
	self.SetupPowerBar = setupMemberPowerBar
	self.SetupBarOrientation = setupMemberBarOrientation
	self.SetupPowerBarAltPos = limeMember_SetupPowerBarAltPos
	self.SetupCastingBarPos = limeMember_SetupCastingBarPos
	self.SetupIconPos = limeMember_SetupIconPos
	self.SetupOutline = setupMemberOutline
	self.SetupDebuffIcon = setupMemberDebuffIcon
	self:SetID(tonumber(self:GetName():match("UnitButton(%d+)$")))
	self:GetParent().members[self:GetID()] = self
	--tinsert(UnitPopupFrames, self.dropDown:GetName())
	self.nameTable = {}
	self.name:SetDrawLayer("OVERLAY", 2)
	self.name:Show()
	self.losttext:SetDrawLayer("OVERLAY", 2)
	self.losttext:Show()
	self.readyCheckIcon:SetParent(self.topLevel)
	self.readyCheckIcon:SetDrawLayer("OVERLAY", 6)
	self.readyCheckIcon:ClearAllPoints()
	self.readyCheckIcon:SetPoint("CENTER", 0, 0)
	self.readyCheckIcon:SetSize(24, 24)
	self.roleIcon:SetSize(0.001, 0.001)
	self.roleIcon:SetDrawLayer("OVERLAY", 1)
	self.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	self.leaderIcon:SetSize(0.001, 0.001)
	self.leaderIcon:SetDrawLayer("OVERLAY", 1)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("RAID_TARGET_UPDATE")
	self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
	self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED")
	self:RegisterEvent("UNIT_PHASE")
	if self:GetParent().index == 0 and self:GetID() == 1 then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	else
		self:RegisterEvent("GROUP_ROSTER_UPDATE")
	end
	self:HookScript("OnAttributeChanged", memberOnAttributeChanged)
end

function limeMember_OnShow(self)
	if lime.db then
	self:SetScript("OnEvent", limeMember_OnEvent)
		if not self.ticker then
			self.ticker = C_Timer.NewTicker(0.5, function() limeMember_OnUpdate(self) end) --전역 타이머 설정
		end
		self:GetParent().visible = self:GetParent().visible + 1
		limeMember_UpdateAll(self)
		lime:BorderUpdate()
	end

	lime.visibleMembers[self] = true
end

function limeMember_OnHide(self)
	if lime.db then
		self:SetScript("OnEvent", nil)
		if self.ticker then  -- 레이드 프레임이 보이지 않을 때 타이머 변수 삭제
			self.ticker:Cancel()
			self.ticker = nil
		end
		if self.survivalticker then -- 플레이어가 보이지 않을 때 타이머 변수 삭제
			self.survivalticker:Cancel()
			self.survivalticker = nil
		end
		if self.castingBar.ticker then  --캐스팅 바 타이머 작동 중 파탈 또는 파티 해체 시 타이머 변수 삭제
			self.castingBar.ticker:Cancel()
			self.castingBar.ticker = nil
		end
		if self.bossAura.ticker then --  대상 플레이어가 보이지 않을 때 효과 타이머 삭제
			self.bossAura.ticker:Cancel()
			self.bossAura.ticker = nil
		end
		if self.spellticker then
			self.spellticker:Cancel()
			self.spellticker = nil
		end
		self:GetParent().visible = self:GetParent().visible - 1
		limeMember_OnDragStop(self)
		lime:BorderUpdate()
		table.wipe(self.nameTable)
		self.lostHealth, self.overAbsorb, self.hasAggro, self.isOffline, self.isAFK, self.color, self.class = 0, 0, nil, nil, nil, nil
		self.unit, self.displayedUnit = nil, nil
	end
	lime.visibleMembers[self] = nil
	lime:CallbackClearObject(self)
end

-- 파티 탈퇴 또는 파티 해체 시 각 플레이어에게 할당된 주문 타이머 삭제
-- 전투 중에 파티 탈퇴 시 CPU 사용량을 낭비하는 문제 수정
function limeMember_OnSpellTimerHide(self)
	if self.spellticker then
			self.spellticker:Cancel()
			self.spellticker = nil
	end
end

function limeMember_OnEnter(self)
	lime.onEnter = self
	self.highlight:SetAlpha(lime.db.highlightAlpha)
	self.highlight:Show()
	if lime.db.cflag == true or lime.db.cpass == true then
		if self.displayedUnit and lime.tootipState then
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip:SetUnit(self.displayedUnit)
			GameTooltipTextLeft1:SetTextColor(GameTooltip_UnitColor(self.displayedUnit))
		else
			GameTooltip:Hide()
		end
	end
end

function limeMember_OnLeave(self)
	lime.onEnter = nil
	self.highlight:Hide()
	if lime.db.cflag == true or lime.db.cpass == true then
		GameTooltip:Hide()
	end
end

function limeMember_OnDragStart(self)
	if not lime.db.lock then
		lime.dragging = self
		lime:StartMoving()
	elseif lime.db.lock and lime.db.lockmasterkey and IsAltKeyDown() then
		lime.dragging = self
		lime:StartMoving()
	end
end

function limeMember_OnDragStop(self)
	if lime.dragging then
		lime.dragging = nil
		lime:SetUserPlaced(nil)
		lime:StopMovingOrSizing()
		lime:SavePosition()
	end
end

function limeMember_UpdateHealth(self)
	local health = UnitHealth(self.displayedUnit)
	local maxhealth = UnitHealthMax(self.displayedUnit)
	self.healthBar:SetValue(health)
	self.health = health
	self.maxHealth = maxhealth
	self.lostHealth = maxhealth - health
	self.healthBar:SetMinMaxValues(0, maxhealth)
	self.myHealPredictionBar:SetMinMaxValues(0, maxhealth)
	self.otherHealPredictionBar:SetMinMaxValues(0, maxhealth)
	self.absorbPredictionBar:SetMinMaxValues(0, maxhealth)
end

local function limeMember_GetDisplayedPowerID(self)
	local barType, minPower, startInset, endInset, smooth, hideFromOthers, showOnRaid, opaqueSpark, opaqueFlash, powerName, powerTooltip = UnitAlternatePowerInfo(self.displayedUnit)
	if ( showOnRaid and (UnitInParty(self.unit) or UnitInRaid(self.unit)) ) then
		return ALTERNATE_POWER_INDEX
	else
		return (UnitPowerType(self.displayedUnit))
	end
end

function limeMember_UpdateMaxPower(self)
	self.powerBar:SetMinMaxValues(0, UnitPowerMax(self.displayedUnit, limeMember_GetDisplayedPowerID(self)))
end

function limeMember_UpdatePower(self)
	self.powerBar:SetValue(UnitPower(self.displayedUnit, limeMember_GetDisplayedPowerID(self)))
end

function limeMember_UpdateHealPrediction(self)
	if self.optionTable.displayHealPrediction and not UnitIsDeadOrGhost(self.displayedUnit) then
		local myIncomingHeal = UnitGetIncomingHeals(self.displayedUnit, "player") or 0
		local allIncomingHeal = UnitGetIncomingHeals(self.displayedUnit) or 0
		local otherIncomingHeal = allIncomingHeal - myIncomingHeal
		local totalAbsorb = UnitGetTotalAbsorbs(self.displayedUnit) or 0
		local totalPrediction = allIncomingHeal + totalAbsorb
		local health = self.health
		local maxhealth = self.maxHealth
		local lost = self.lostHealth
		if self.healIcon then
			if self.optionTable.healIcon and myIncomingHeal > 0 then
				self.healIcon:SetVertexColor(self.optionTable.myHealPredictionColor[1], self.optionTable.myHealPredictionColor[2], self.optionTable.myHealPredictionColor[3])
				self.healIcon:SetSize(self.optionTable.healIconSize, self.optionTable.healIconSize)
				self.healIcon:Show()
			elseif self.optionTable.healIconOther and otherIncomingHeal > 0 then
				self.healIcon:SetVertexColor(self.optionTable.otherHealPredictionColor[1], self.optionTable.otherHealPredictionColor[2], self.optionTable.otherHealPredictionColor[3])
				self.healIcon:SetSize(self.optionTable.healIconSize, self.optionTable.healIconSize)
				self.healIcon:Show()
			elseif self.healIcon and self.healIcon:IsShown() then
				self.healIcon:SetSize(0.001, 0.001)
				self.healIcon:Hide()
			end
		end
		if lost > 0 then
			if myIncomingHeal > 0 then
				local value = min(maxhealth, health + myIncomingHeal)
				self.myHealPredictionBar:SetValue(value)
				self.myHealPredictionBar:Show()
			else
				self.myHealPredictionBar:Hide()
			end
			if otherIncomingHeal > 0 then
				local value = min(maxhealth, health + allIncomingHeal)
				self.otherHealPredictionBar:SetValue(value)
				self.otherHealPredictionBar:Show()
			else
				self.otherHealPredictionBar:Hide()
			end
			if totalAbsorb > 0 then
				local value = min(maxhealth, health + totalPrediction)
				self.absorbPredictionBar:SetValue(value)
				self.absorbPredictionBar:Show()
			else
				self.absorbPredictionBar:Hide()
			end
			self.overAbsorbGlow:Hide()
		else
			if totalAbsorb > 0 and totalPrediction >= lost then
				self.overAbsorbGlow:Show()
				self.overAbsorb = totalAbsorb
			else
				self.overAbsorbGlow:Hide()
				self.overAbsorb = 0
			end
			self.myHealPredictionBar:Hide()
			self.otherHealPredictionBar:Hide()
			self.absorbPredictionBar:Hide()
		end
	else
		if self.healIcon and self.healIcon:IsShown() then
			self.healIcon:SetSize(0.001, 0.001)
			self.healIcon:Hide()
		end
		self.overAbsorbGlow:Hide()
		self.myHealPredictionBar:Hide()
		self.otherHealPredictionBar:Hide()
		self.absorbPredictionBar:Hide()
	end
end

local colorR, colorG, colorB

function limeMember_UpdateState(self)
	_, self.class = UnitClass(self.displayedUnit)
	if UnitIsConnected(self.unit) then
		self.isOffline = nil
		if UnitIsGhost(self.displayedUnit) then
			self.isGhost = true
		elseif UnitIsDead(self.displayedUnit) then
			self.isDead = true
		elseif UnitIsAFK(self.unit) then
			self.isAFK = true
		else
			self.isGhost, self.isOffline, self.isDead, self.isAFK = nil, nil, nil, nil
		end
		if self.isGhost or self.isDead then
			colorR, colorG, colorB = lime.db.colors.offline[1], lime.db.colors.offline[2], lime.db.colors.offline[3]
		elseif self.optionTable.useHarm and UnitCanAttack(self.displayedUnit, "player") then
			colorR, colorG, colorB = lime.db.colors.harm[1], lime.db.colors.harm[2], lime.db.colors.harm[3]
		elseif self.dispelType and lime.db.colors[self.dispelType] and self.optionTable.useDispelColor then
			colorR, colorG, colorB = lime.db.colors[self.dispelType][1], lime.db.colors[self.dispelType][2], lime.db.colors[self.dispelType][3]
		elseif self.displayedUnit:find("pet") then
			colorR, colorG, colorB = lime.db.colors.vehicle[1], lime.db.colors.vehicle[2], lime.db.colors.vehicle[3]
		elseif lime.db.units.fadeOutColorFlag then	
			-- 거리 측정 로직
			local prevRange = self.outRange
			if self.isOffline then
				self.outRange = false
			else
				local inRange, checkedRange = UnitInRange(self.displayedUnit)
				self.outRange = checkedRange and not inRange
			end
			-- 거리 측정을 해보니 거리가 바뀌었다면
			if prevRange ~= self.outRange or self.outRange then
				colorR, colorG, colorB = lime.db.units.fadeOutColor[1], lime.db.units.fadeOutColor[2], lime.db.units.fadeOutColor[3]
			elseif self.optionTable.useClassColors and lime.db.colors[self.class] then
				colorR, colorG, colorB = lime.db.colors[self.class][1], lime.db.colors[self.class][2], lime.db.colors[self.class][3]
			else
				colorR, colorG, colorB = lime.db.colors.help[1], lime.db.colors.help[2], lime.db.colors.help[3]
			end
		elseif self.optionTable.useClassColors and lime.db.colors[self.class] then
			colorR, colorG, colorB = lime.db.colors[self.class][1], lime.db.colors[self.class][2], lime.db.colors[self.class][3]
		else
			colorR, colorG, colorB = lime.db.colors.help[1], lime.db.colors.help[2], lime.db.colors.help[3]
		end	
	else
		self.isOffline, self.isGhost, self.isDead, self.isAFK = true, nil, nil, nil
		colorR, colorG, colorB = lime.db.colors.offline[1], lime.db.colors.offline[2], lime.db.colors.offline[3]
	end
	self.healthBar:SetStatusBarColor(colorR, colorG, colorB)
	colorR, colorG, colorB = nil
end

local altR, altG, altB

function limeMember_UpdatePowerColor(self)
	if self.isOffline then
		colorR, colorG, colorB = lime.db.colors.offline[1], lime.db.colors.offline[2], lime.db.colors.offline[3]
	elseif select(7, UnitAlternatePowerInfo(self.displayedUnit)) then
		colorR, colorG, colorB = 0.7, 0.7, 0.6
	else
		colorR, colorG, altR, altG, altB = UnitPowerType(self.displayedUnit)
		if lime.db.colors[colorG] then
			colorR, colorG, colorB = lime.db.colors[colorG][1], lime.db.colors[colorG][2], lime.db.colors[colorG][3]
		elseif PowerBarColor[colorR] then
			colorR, colorG, colorB = PowerBarColor[colorR].r, PowerBarColor[colorR].g, PowerBarColor[colorR].b
		elseif altR then
			colorR, colorG, colorB = altR, altG, altB
		else
			colorR, colorG, colorB = PowerBarColor[0].r, PowerBarColor[0].g, PowerBarColor[0].b
		end
	end
	self.powerBar:SetStatusBarColor(colorR, colorG, colorB)
	colorR, colorG, colorB, altR, altG, altB = nil
end

local roleType

function limeMember_UpdateRoleIcon(self)
	if self.optionTable.displayRaidRoleIcon then
		roleType = UnitGroupRolesAssigned(self.unit)
		if roleType ~= "NONE" then
			if self.optionTable.roleIcontype == 1 then
				if roleType == "DAMAGER" then
					self.roleIcon:SetTexture("Interface\\AddOns\\Lime\\Shared\\Texture\\dps")
					self.roleIcon:SetTexCoord(0, 1, 0, 1)
				else
					self.roleIcon:SetTexture("Interface\\AddOns\\Lime\\Shared\\Texture\\RoleIcon_MiirGui")
					self.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(roleType))
				end
			else
				self.roleIcon:SetTexture("Interface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES")
				self.roleIcon:SetTexCoord(GetTexCoordsForRoleSmallCircle(roleType))
			end
			self.roleIcon:SetSize(self.optionTable.roleIconSize, self.optionTable.roleIconSize)
			return self.roleIcon:Show()
		end
	end
	self.roleIcon:SetSize(0.001, 0.001)
	self.roleIcon:Hide()
end

local LeaderFlag

function limeMember_UpdateLeaderIcon(self)
	if self.optionTable.useLeaderIcon then
		LeaderFlag = UnitIsGroupLeader(self.unit)
		if LeaderFlag then
			self.leaderIcon:SetTexCoord(0, 1, 0, 1)
			self.leaderIcon:SetSize(self.optionTable.leaderIconSize, self.optionTable.leaderIconSize)
			return self.leaderIcon:Show()
		end
	end
	self.leaderIcon:SetSize(0.001, 0.001)
	self.leaderIcon:Hide()
end

--copied from bliz source.
function limeMember_UpdateCenterStatusIcon(self)
	if not self.centerStatusIcon then return end
	if self.optionTable.centerStatusIcon and UnitInOtherParty(self.unit) then
		self.centerStatusIcon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
		self.centerStatusIcon.texture:SetTexCoord(0.125, 0.25, 0.25, 0.5)
		self.centerStatusIcon.border:SetTexture("Interface\\Common\\RingBorder")
		self.centerStatusIcon.border:Show()
		self.centerStatusIcon.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
		self.centerStatusIcon:Show()
	elseif self.optionTable.centerStatusIcon and UnitHasIncomingResurrection(self.unit) then
		self.centerStatusIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
		self.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1)
		self.centerStatusIcon.border:Hide()
		self.centerStatusIcon.tooltip = nil
		self.centerStatusIcon:Show()
		self.resurrectStart = GetTime() * 1000
	elseif self.optionTable.centerStatusIcon and self.inDistance and not UnitInPhase(self.unit) then
		self.centerStatusIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
		self.centerStatusIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
		self.centerStatusIcon.border:Hide()
		self.centerStatusIcon.tooltip = PARTY_PHASED_MESSAGE
		self.centerStatusIcon:Show()
	else
		self.centerStatusIcon:Hide()
	end
	limeMember_UpdateResurrection(self)
end

local tooltipUpdate = 0
function limeMember_CenterStatusIconOnUpdate(self, elapsed)
	if lime.db.cflag == true or lime.db.cpass == true then
		if not lime.tootipState then return end
		tooltipUpdate = tooltipUpdate + elapsed
		if tooltipUpdate > 0.1 then
			tooltipUpdate = 0
			if self:IsMouseOver() and self.tooltip then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
				GameTooltip:Show()
			elseif GameTooltip:IsOwned(self) then
				GameTooltip:Hide()
			end
		end
	end
end

function limeMember_CenterStatusIconOnHide(self)
	if lime.db.cflag == true or lime.db.cpass == true then
		if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
		end
	end
end

function limeMember_UpdateOutline(self)
	if self.optionTable.outline.type == 1 then
		if self.dispelType and lime.db.colors[self.dispelType] then
			self.outline:SetBackdropBorderColor(lime.db.colors[self.dispelType][1], lime.db.colors[self.dispelType][2], lime.db.colors[self.dispelType][3])
			return self.outline:Show()
		end
	elseif self.optionTable.outline.type == 2 then
		if UnitIsUnit(self.displayedUnit, "target") then
			return self.outline:Show()
		end
	elseif self.optionTable.outline.type == 3 then
		if UnitIsUnit(self.displayedUnit, "mouseover") then
			return self.outline:Show()
		end
	elseif self.optionTable.outline.type == 4 then
		if not UnitIsDeadOrGhost(self.displayedUnit) and (self.health / self.maxHealth) <= self.optionTable.outline.lowHealth then
			return self.outline:Show()
		end
	elseif self.optionTable.outline.type == 5 then
		if self.hasAggro then
			return self.outline:Show()
		end
	elseif self.optionTable.outline.type == 6 then
		if self.optionTable.outline.raidIcon[GetRaidTargetIndex(self.displayedUnit)] then
			return self.outline:Show()
		end
	elseif self.optionTable.outline.type == 7 then
		if not UnitIsDeadOrGhost(self.displayedUnit) and self.maxHealth >= self.optionTable.outline.lowHealth2 and self.health < self.optionTable.outline.lowHealth2 then
			return self.outline:Show()
		end
	end
	self.outline:Hide()
end

--- 타이머에서 지속적으로 체크하는 거리 측정 함수
function limeMember_OnUpdate(self)
	-- 거리 측정 로직
	local prevRange = self.outRange
	if self.isOffline then
		self.outRange = false
	else
		local inRange, checkedRange = UnitInRange(self.displayedUnit)
		self.outRange = checkedRange and not inRange
	end
	-- 거리 측정을 해보니 거리가 바뀌었다면
	if prevRange ~= self.outRange then
		if self.outRange then  -- 시야 바깥일때는 체력바 업데이트 중지
			self.healthBar:SetAlpha(self.optionTable.fadeOutOfRangeHealth and self.optionTable.fadeOutAlpha or 1)
			self.powerBar:SetAlpha(self.optionTable.fadeOutOfRangePower and self.optionTable.fadeOutAlpha or 1)
			self.myHealPredictionBar:SetAlpha(0)
			self.otherHealPredictionBar:SetAlpha(0)
			self.absorbPredictionBar:SetAlpha(0)
		else -- 시야 안쪽일때 체력 바랑 기력 바 업데이트 시작
			self.healthBar:SetAlpha(1)
			self.powerBar:SetAlpha(1)
			self.myHealPredictionBar:SetAlpha(lime.db.units.healPredictionAlpha)
			self.otherHealPredictionBar:SetAlpha(lime.db.units.healPredictionAlpha)
			self.absorbPredictionBar:SetAlpha(lime.db.units.healPredictionAlpha)
			limeMember_UpdateHealth(self)
			limeMember_UpdateMaxPower(self)
			limeMember_UpdatePower(self)
			limeMember_UpdatePowerColor(self)
		end
		-- 위치 변경이 될때마다 업데이트 할 항목
		limeMember_UpdateAura(self)
 		limeMember_UpdateSpellTimer(self)
 		limeMember_UpdateSurvivalSkill(self)
 		--limeMember_UpdateBuffs(self)
 		limeMember_UpdateHealPrediction(self)
 		limeMember_UpdateState(self)
 		limeMember_UpdateNameColor(self)
 		limeMember_UpdateDisplayText(self)
 		limeMember_UpdateRaidIconTarget(self)
	end
	-- 거리 측정과 상관없이 타이머에서 지속적으로 갱신할 것들 (많이 추가하면 CPU 점유율 급증할 위험 있음)
	limeMember_UpdateState(self)
 	limeMember_UpdateRaidIconTarget(self)
	-- 위상 업데이트
	local distance, checkedDistance = UnitDistanceSquared(self.displayedUnit)
	if checkedDistance then
		local inDistance = distance < 250*250
		if inDistance ~= self.inDistance then
			self.inDistance = inDistance
			limeMember_UpdateCenterStatusIcon(self)
		end
	end

end

--- 타이머에서 지속적으로 체크하지 않는 거리 측정 함수
function limeMember_OnUpdate2(self)
	if self.isOffline then
		self.outRange = false
	else
		local inRange, checkedRange = UnitInRange(self.displayedUnit)
		self.outRange = checkedRange and not inRange
	end
	if self.outRange then
		self.healthBar:SetAlpha(self.optionTable.fadeOutOfRangeHealth and self.optionTable.fadeOutAlpha or 1)
		self.powerBar:SetAlpha(self.optionTable.fadeOutOfRangePower and self.optionTable.fadeOutAlpha or 1)
		self.myHealPredictionBar:SetAlpha(0)
		self.otherHealPredictionBar:SetAlpha(0)
		self.absorbPredictionBar:SetAlpha(0)
	else
		self.healthBar:SetAlpha(1)
		self.powerBar:SetAlpha(1)
		self.myHealPredictionBar:SetAlpha(lime.db.units.healPredictionAlpha)
		self.otherHealPredictionBar:SetAlpha(lime.db.units.healPredictionAlpha)
		self.absorbPredictionBar:SetAlpha(lime.db.units.healPredictionAlpha)
	end
end

function limeMember_OnEvent(self, event, ...)
	eventHandler[event](self, ...)
end

-- 대부분의 인자를 즉시 업데이트 함
function limeMember_UpdateAll(self)
	if lime.db then
		limeMember_UpdateInVehicle(self)
		if UnitExists(self.displayedUnit or "") then
			limeMember_UpdateName(self)
			limeMember_UpdateState(self)
			limeMember_UpdateNameColor(self)
			limeMember_UpdateHealth(self)
			limeMember_UpdateHealPrediction(self)
			limeMember_UpdateMaxPower(self)
			limeMember_UpdatePower(self)
			limeMember_UpdatePowerColor(self)
			limeMember_UpdateCastingBar(self)
			limeMember_UpdatePowerBarAlt(self)
			limeMember_UpdateThreat(self)
			limeMember_UpdateRoleIcon(self)
			limeMember_UpdateLeaderIcon(self)
			limeMember_UpdateRaidIcon(self)
			limeMember_UpdateAura(self)
			limeMember_UpdateSpellTimer(self)
			limeMember_UpdateSurvivalSkill(self)
			limeMember_UpdateOutline(self)
			limeMember_OnUpdate2(self)
			--limeMember_UpdateBuffs(self)
			limeMember_UpdateRaidIconTarget(self)
			limeMember_UpdateDisplayText(self)
			limeMember_UpdateCenterStatusIcon(self)
		end
	end
end

function limeMember_UpdateInVehicle(self)
	self.unit = SecureButton_GetUnit(self)
	self.displayedUnit = self.unit and (SecureButton_GetModifiedUnit(self) or self.unit) or nil
	if lime.onEnter == self then
		limeMember_OnEnter(self)
	end
end

function limeMember_OnAttributeChanged(self, name, value)
	if name == "unit" then
		limeMember_UpdateAll(self)
	end
end

-- 이벤트가 발생하면 해당 함수를 실행하도록 함
eventHandler.PLAYER_ENTERING_WORLD = limeMember_UpdateAll
eventHandler.GROUP_ROSTER_UPDATE = limeMember_UpdateAll
eventHandler.PLAYER_ROLES_ASSIGNED = limeMember_UpdateRoleIcon
eventHandler.PARTY_LEADER_CHANGED = limeMember_UpdateLeaderIcon
eventHandler.RAID_TARGET_UPDATE = function(self)
	limeMember_UpdateRaidIcon(self)
	if self.optionTable.outline[1].type == 6 or self.optionTable.outline[2].type == 6 or self.optionTable.outline[3].type == 6 then
		limeMember_UpdateOutline(self)
	end
end
eventHandler.UNIT_NAME_UPDATE = function(self, unit)
	if (unit == self.unit or unit == self.displayedUnit) then
		limeMember_UpdateName(self)
		limeMember_UpdateNameColor(self)
		limeMember_UpdateDisplayText(self)
	end
end
eventHandler.UNIT_CONNECTION = function(self, unit)
	if (unit == self.unit or unit == self.displayedUnit) then
		limeMember_UpdateName(self)
		limeMember_UpdateNameColor(self)
		limeMember_UpdateDisplayText(self)
		limeMember_UpdatePowerColor(self)
	end
end
eventHandler.UNIT_FLAGS = function(self, unit)
	if (unit == self.unit or unit == self.displayedUnit) then
		limeMember_UpdateHealth(self)
		limeMember_UpdateLostHealth(self)
		limeMember_UpdateState(self)
		limeMember_UpdateNameColor(self)
		limeMember_UpdateDisplayText(self)
	end
end
eventHandler.PLAYER_FLAGS_CHANGED = eventHandler.UNIT_FLAGS
eventHandler.UNIT_HEALTH = function(self, unit)
	if unit == self.displayedUnit then
		limeMember_UpdateHealth(self)
		limeMember_UpdateLostHealth(self)
		limeMember_UpdateHealPrediction(self)
		limeMember_UpdateState(self)
		if self.optionTable.outline.type == 4 or self.optionTable.outline.type == 7 then
			limeMember_UpdateOutline(self)
		end
	end
end
eventHandler.UNIT_MAXHEALTH = eventHandler.UNIT_HEALTH
eventHandler.UNIT_HEALTH_FREQUENT = function(self, unit)
	if unit == self.displayedUnit then
		limeMember_UpdateHealth(self)
		limeMember_UpdateLostHealth(self)
	end
end
eventHandler.UNIT_MAXPOWER = function(self, unit, powerType)
	if unit == self.displayedUnit then
		if powerType == "ALTERNATE" then
			limeMember_UpdatePowerBarAlt(self)
		else
			limeMember_UpdateMaxPower(self)
			limeMember_UpdatePower(self)
		end
	end
end
eventHandler.UNIT_POWER_UPDATE = function(self, unit, powerType)
	if unit == self.displayedUnit then
		if powerType == "ALTERNATE" then
			limeMember_UpdatePowerBarAlt(self)
		else
			limeMember_UpdatePower(self)
		end
	end
end
eventHandler.UNIT_DISPLAYPOWER = function(self, unit)
	if unit == self.displayedUnit then
		limeMember_UpdateMaxPower(self)
		limeMember_UpdatePower(self)
		limeMember_UpdatePowerColor(self)
		limeMember_UpdatePowerBarAlt(self)
	end
end
eventHandler.UNIT_POWER_BAR_SHOW = eventHandler.UNIT_DISPLAYPOWER
eventHandler.UNIT_POWER_BAR_HIDE = eventHandler.UNIT_DISPLAYPOWER
eventHandler.UNIT_HEAL_PREDICTION = function(self, unit)
	if unit == self.displayedUnit then
		limeMember_UpdateHealth(self)
		limeMember_UpdateHealPrediction(self)
	end
end
eventHandler.UNIT_ABSORB_AMOUNT_CHANGED = eventHandler.UNIT_HEAL_PREDICTION
eventHandler.UNIT_AURA = function(self, unit)
	if (unit == self.unit or unit == self.displayedUnit) then
		limeMember_UpdateAura(self)					--- cpu impact score : 0.02 
		limeMember_UpdateSpellTimer(self) 			--- cpu impact score : 0.01
		limeMember_UpdateSurvivalSkill(self)		--- cpu impact score : 0.10
		--limeMember_UpdateBuffs(self)				--- cpu impact score : 0.04
		if self.optionTable.outline.type == 1 then
			limeMember_UpdateOutline(self)
		end
		if self.optionTable.useDispelColor then
			limeMember_UpdateState(self)
		end
	end
end
eventHandler.UNIT_THREAT_SITUATION_UPDATE = function(self, unit)
	if unit == self.displayedUnit then
		limeMember_UpdateThreat(self)
		limeMember_UpdateDisplayText(self)
		if self.optionTable.outline.type == 5 then
			limeMember_UpdateOutline(self)
		end
	end
end

eventHandler.UNIT_THREAT_LIST_UPDATE = function(self, unit)
	if unit == self.displayedUnit then
		limeMember_UpdateThreat(self)
		limeMember_UpdateDisplayText(self)
		if self.optionTable.outline.type == 5 then
			limeMember_UpdateOutline(self)
		end
	end
end

eventHandler.READY_CHECK_CONFIRM = function(self, unit)
	if unit == self.unit then
		limeMember_UpdateReadyCheck(self)
	end
end

eventHandler.UNIT_ENTERED_VEHICLE = function(self, unit)
	if unit == self.unit then
		limeMember_UpdateAll(self)
	end
end

eventHandler.UNIT_EXITED_VEHICLE = function(self, unit)
	if unit == self.unit then
		limeMember_UpdateAll(self)
		C_Timer.After(1.0, function()
			if UnitExists(self.unit) then
				limeMember_UpdateHealth(self)
				limeMember_UpdateLostHealth(self)
			end
		end)
	end
end


eventHandler.UNIT_SPELLCAST_START = function(self, unit)
	if lime.db.units.useCastingBar and unit == self.displayedUnit then
		limeMember_UpdateCastingBar(self)
	end
end
eventHandler.UNIT_SPELLCAST_STOP = eventHandler.UNIT_SPELLCAST_START
eventHandler.UNIT_SPELLCAST_DELAYED = eventHandler.UNIT_SPELLCAST_START
eventHandler.UNIT_SPELLCAST_CHANNEL_START = eventHandler.UNIT_SPELLCAST_START
eventHandler.UNIT_SPELLCAST_CHANNEL_UPDATE = eventHandler.UNIT_SPELLCAST_START
eventHandler.UNIT_SPELLCAST_CHANNEL_STOP = eventHandler.UNIT_SPELLCAST_START
eventHandler.PLAYER_TARGET_CHANGED = limeMember_UpdateOutline
eventHandler.UPDATE_MOUSEOVER_UNIT = limeMember_UpdateOutline
eventHandler.INCOMING_RESURRECT_CHANGED = function(self)
	limeMember_UpdateCenterStatusIcon(self)
end
eventHandler.UNIT_OTHER_PARTY_CHANGED = eventHandler.INCOMING_RESURRECT_CHANGED
eventHandler.UNIT_PHASE = eventHandler.INCOMING_RESURRECT_CHANGED