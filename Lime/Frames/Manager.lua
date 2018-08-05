
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local _G = _G
local lime = _G[...]
local texturePath = "Interface\\AddOns\\Lime\\Shared\\Texture\\"
local onPetBattle = false

-- 와우 기본 공격대 프레임 및 설정창 숨기기
CompactRaidFrameManager:UnregisterAllEvents()
CompactRaidFrameManager:SetAlpha(0)
CompactRaidFrameManager:SetScale(0.00001)
CompactRaidFrameManagerToggleButton:EnableMouse(nil)
PartyMemberFrame1:ClearAllPoints()
PartyMemberFrame1:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 18, -160)
CompactUnitFrameProfiles:UnregisterAllEvents()

for _, button in pairs(InterfaceOptionsFrameCategories.buttons) do
	if button.element and button.element.name == CompactUnitFrameProfiles.name then
		button:SetScale(0.00001)
		button:SetAlpha(0)
	end
end

-- 위치 표시기 단축키
local btn, newPoint
local function preClick(self)
	newPoint = self:GetID() == 0
end
for i = 0, 9 do
	btn = CreateFrame("Button", "limeWorldMarker"..i, nil, "SecureActionButtonTemplate")
	btn:SetID(i)
	if i == 0 then
		L_UIDropDownMenu_GetCurrentDropDown().displayMode = nil
		btn:SetScript("PreClick", preClick)
		btn:SetAttribute("*type*", "macro")
		btn:SetAttribute("*macrotext*", "/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton")
	elseif i == 9 then
		btn:SetAttribute("*type*", "worldmarker")
		btn:SetAttribute("*action*", "clear")
	else
		btn:SetAttribute("*type*", "worldmarker")
		btn:SetAttribute("*action*", "toggle")
		btn:SetAttribute("*marker*", i)
	end
end
_G["BINDING_NAME_CLICK limeWorldMarker0:LeftButton"] = L["Lime_Marker"]
for i = 1, 8 do
	_G["BINDING_NAME_CLICK limeWorldMarker"..i..":LeftButton"] = _G["WORLD_MARKER"..i]:gsub("\124T.+\124t", ""):gsub("\124r", ""):gsub("\124c[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]", ""):trim()
end
_G["BINDING_NAME_CLICK limeWorldMarker9:LeftButton"] = WORLD_MARKER:gsub("%%d", ""):trim().." "..REMOVE_WORLD_MARKERS

-- 공격대 관리자
lime.manager = limeManager

-- 공격대 관리자 유형 함수 (솔플/파티/공격대)
local function checkMode()
	if IsInRaid() then
		if lime.manager.mode ~= "raid" then
			lime.manager.mode = "raid"
			return true
		end
	elseif IsInGroup() then
		if lime.manager.mode ~= "party" then
			lime.manager.mode = "party"
			return true
		end
	elseif lime.manager.mode ~= "solo" then
		lime.manager.mode = "solo"
		return true
	end
	return nil
end

-- 파티원이나 공격대원이 참여할 시 인원을 업데이트합니다.
local function updateCount()
	CRF_CountStuff()
	if IsInGroup() then
		lime.manager.content.label:SetFormattedText("%s%d %s%d %s%d %s%d", "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:32:48:0:16|t", RaidInfoCounts.totalRoleTANK, "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:48:64:0:16|t", RaidInfoCounts.totalRoleHEALER, "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:16:32:0:16|t", RaidInfoCounts.totalRoleDAMAGER, "|TInterface\\RaidFrame\\ReadyCheck-NotReady:14:14:0:0|t", RaidInfoCounts.totalRoleNONE)
	else
		lime.manager.content.label:SetText(L["Lime_Manager"])
	end
	lime.manager.content.memberCountLabel:SetFormattedText("%d/%d", RaidInfoCounts.totalAlive, RaidInfoCounts.totalCount)
end

-- 이벤트 발생 시 스크립트 실행
lime.manager:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		checkMode()
		lime:SetManagerMode()
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		lime:SetManagerPosition()
	elseif event == "GROUP_ROSTER_UPDATE" then
		if checkMode() then
			--if self.run then	(r35 bug fixed)
				lime:SetManagerMode()
			--end
		elseif self.run and self.isExpand then
			updateCount()
		end
	elseif event == "RAID_TARGET_UPDATE" or event == "PLAYER_TARGET_CHANGED" then
		if self.run and self.isExpand then
			CompactRaidFrameManager_UpdateRaidIcons()
		end
	elseif event == "PET_BATTLE_OPENING_START" then
		onPetBattle = true
		lime:SetManagerMode()
	elseif event == "PET_BATTLE_CLOSE" then
		onPetBattle = false
		lime:SetManagerMode()
	elseif self.run and self.isExpand then
		-- PARTY_LEADER_CHANGED, PLAYER_REGEN_ENABLED, PLAYER_REGEN_DISABLED
		lime:SetManagerMode()
	end
end)

-- ToggleButton 스크립트 
lime.manager.toggleButton:RegisterForClicks("LeftButtonUp")
lime.manager.toggleButton:SetScript("OnClick", function(self)
	self = self:GetParent()
	self.isExpand = not self.isExpand
	lime:SetManagerMode()
end)

-- 잠금 버튼 스크립트 
lime.manager.content.lockButton:SetScript("OnClick", function(self)
	lime.db.lock = not lime.db.lock
	self:SetText(lime.db.lock and UNLOCK or LOCK)
	if lime.optionFrame.lockMenu and lime.optionFrame.lockMenu:IsVisible() then
		lime.optionFrame.lockMenu:Update()
	end
end)

-- 공격대 창 ON/OFF 버튼 스크립트 
lime.manager.content.hideButton:SetScript("OnClick", function(self)
	lime:SetAttribute("run", not lime.db.run)
	LimeOverlord:GetScript("PostClick")(LimeOverlord)
end)

-- 다음 이벤트가 발생하면 공격대 관리자를 로딩
function lime:ToggleManager()
	if self.db.useManager then
		self.manager:RegisterEvent("PLAYER_ENTERING_WORLD")
		self.manager:RegisterEvent("DISPLAY_SIZE_CHANGED")
		self.manager:RegisterEvent("UI_SCALE_CHANGED")
		self.manager:RegisterEvent("GROUP_ROSTER_UPDATE")
		self.manager:RegisterEvent("PARTY_LEADER_CHANGED")
		self.manager:RegisterEvent("RAID_TARGET_UPDATE")
		self.manager:RegisterEvent("PLAYER_TARGET_CHANGED")
		self.manager:RegisterEvent("PLAYER_REGEN_ENABLED")
		self.manager:RegisterEvent("PLAYER_REGEN_DISABLED")
		self.manager:RegisterEvent("PLAYER_REGEN_ENABLED")
		self.manager:RegisterEvent("PET_BATTLE_OPENING_START")
		self.manager:RegisterEvent("PET_BATTLE_CLOSE")
		checkMode()
		self:SetManagerMode()
	else
		self.manager.run, self.manager.mode, self.manager.isExpand = nil
		self.manager:UnregisterAllEvents()
		self.manager:Hide()
	end
end

local inCombat

-- 공격대 관리자 유형 스크립트
function lime:SetManagerMode()
	if ((self.db.use == 1) or (self.db.use == 2 and self.manager.mode ~= "solo") or (self.db.use == 3 and self.manager.mode == "raid")) and not onPetBattle then
		self.manager.run = true
		self.manager:Show()
		self:SetManagerPosition()
		if self.manager.isExpand then
			inCombat = InCombatLockdown() or UnitAffectingCombat("player")
			self.manager.content:Show()
			updateCount()
			CompactRaidFrameManager_UpdateRaidIcons()
			if self:IsLeader() then
				self.manager.content.readyCheckButton:Enable()
				self.manager.content.readyCheckButton:SetAlpha(1)
				if HasLFGRestrictions() then
					self.manager.content.rolePollButton:Disable()
					self.manager.content.rolePollButton:SetAlpha(0.5)
					self.manager.content.everyoneIsAssistButton:Disable()
					self.manager.content.everyoneIsAssistButton:SetAlpha(0.5)
				else
					self.manager.content.rolePollButton:Enable()
					self.manager.content.rolePollButton:SetAlpha(1)
					self.manager.content.everyoneIsAssistButton:Enable()
					self.manager.content.everyoneIsAssistButton:SetAlpha(1)
				end
			else
				self.manager.content.readyCheckButton:Disable()
				self.manager.content.readyCheckButton:SetAlpha(0.5)
				self.manager.content.rolePollButton:Disable()
				self.manager.content.rolePollButton:SetAlpha(0.5)
				self.manager.content.everyoneIsAssistButton:Disable()
				self.manager.content.everyoneIsAssistButton:SetAlpha(0.5)
			end
			if self:IsLeader2() then
				self.manager.content.markerButton:Enable()
				self.manager.content.markerButton:SetAlpha(1)
			else
				self.manager.content.markerButton:Disable()
				self.manager.content.markerButton:SetAlpha(0.5)
			end
			self.manager.content.lockButton:SetText(self.db.lock and UNLOCK or LOCK)
			self.manager.content.hideButton:SetText(self.db.run and HIDE or SHOW)
			if inCombat then
				self.manager.content.hideButton:Disable()
				self.manager.content.hideButton:SetAlpha(0.5)
			else
				self.manager.content.hideButton:Enable()
				self.manager.content.hideButton:SetAlpha(1)
			end
			self:UpdateManagerGroupFilter()
		else
			self.manager.content:Hide()
		end
	else
		self.manager.run, self.manager.isExpand = nil
		self.manager:Hide()
	end
end

-- 공격대 관리자 위치
-- 공격대 관리자의 크기를 고려하여, 스크린에서 일정 범위를 벗어나면 위치를 이동합니다.
-- 공격대 관리자를 펼칠 경우에, 계산 방식을 다르게 합니다.
function lime:SetManagerPosition()
	if not self.manager.run then return end
	self.manager:ClearAllPoints()
	self.manager.toggleButton:ClearAllPoints()
	if self.db.managerPos < 45 or self.db.managerPos > 315 then  
		self.manager.pos = "LEFT"
		self.manager:SetSize(186, self.manager.mode == "raid" and 221 or 147)
		self.manager.toggleButton:SetSize(15, 64)
		self.manager.toggleButton:SetPoint("RIGHT", -2, 0)
		self.manager.toggleButton:SetHitRectInsets(5, 0, 6, 6)
		self.manager.toggleButton.normal:SetTexture("Interface\\RaidFrame\\RaidPanel-Toggle")
		if self.manager.isExpand then  
			self.manager:SetPoint("LEFT", UIParent, -5, -(self.manager:GetHeight() / 2 - select(2, UIParent:GetCenter())) * ((self.db.managerPos - (self.db.managerPos >= 315 and 360 or 0)) / 44))
			self.manager.toggleButton.normal:SetTexCoord(0.53125, 1, 0, 1)
			self.manager.content:ClearAllPoints()
			self.manager.content:SetPoint("TOP", self.manager.bg, 0, 0)
			self.manager.content:SetPoint("LEFT", UIParent, 2, 0)
			self.manager.content:SetPoint("BOTTOMRIGHT", self.manager.bg, -8, 3)
		else
			self.manager:SetPoint("RIGHT", UIParent, "LEFT", 12, -(self.manager:GetHeight() / 2 - select(2, UIParent:GetCenter())) * ((self.db.managerPos - (self.db.managerPos >= 315 and 360 or 0)) / 44))
			self.manager.toggleButton.normal:SetTexCoord(0, 0.46875, 0, 1)
		end
	elseif self.db.managerPos > 135 and self.db.managerPos < 225 then
		self.manager.pos = "RIGHT"
		self.manager:SetSize(186, self.manager.mode == "raid" and 221 or 147)
		self.manager.toggleButton:SetSize(15, 64)
		self.manager.toggleButton:SetPoint("LEFT", 2, 0)
		self.manager.toggleButton:SetHitRectInsets(0, 5, 6, 6)
		self.manager.toggleButton.normal:SetTexture("Interface\\RaidFrame\\RaidPanel-Toggle")
		if self.manager.isExpand then
			self.manager:SetPoint("RIGHT", UIParent, 5, (self.manager:GetHeight() / 2 - select(2, UIParent:GetCenter())) * ((self.db.managerPos - 180) / 44))
			self.manager.toggleButton.normal:SetTexCoord(1, 0.53125, 0, 1)
			self.manager.content:ClearAllPoints()
			self.manager.content:SetPoint("TOP", self.manager.bg, 0, 0)
			self.manager.content:SetPoint("RIGHT", UIParent, -2, 0)
			self.manager.content:SetPoint("BOTTOMLEFT", self.manager.bg, 8, 3)
		else
			self.manager:SetPoint("LEFT", UIParent, "RIGHT", -12, (self.manager:GetHeight() / 2 - select(2, UIParent:GetCenter())) * ((self.db.managerPos - 180) / 44))
			self.manager.toggleButton.normal:SetTexCoord(0.46875, 0, 0, 1)
		end
	elseif self.db.managerPos >= 45 and self.db.managerPos <= 135 then
		self.manager.pos = "TOP"
		self.manager:SetSize(184, self.manager.mode == "raid" and 231 or 156)
		self.manager.toggleButton:SetSize(64, 15)
		self.manager.toggleButton:SetPoint("BOTTOM", 0, 3)
		self.manager.toggleButton:SetHitRectInsets(6, 6, 5, 0)
		self.manager.toggleButton.normal:SetTexture(texturePath.."ManagerToggleHoriz")
		if self.manager.isExpand then
			self.manager:SetPoint("TOP", UIParent, -(self.manager:GetWidth() - UIParent:GetCenter() * 2) * ((self.db.managerPos - 90) / 90), 5)
			self.manager.toggleButton.normal:SetTexCoord(0, 1, 0.53125, 1)
			self.manager.content:ClearAllPoints()
			self.manager.content:SetPoint("TOP", UIParent, 0, 0)
			self.manager.content:SetPoint("LEFT", self.manager.bg, 2, 0)
			self.manager.content:SetPoint("BOTTOMRIGHT", self.manager.bg, -2, 12)
		else
			self.manager:SetPoint("BOTTOM", UIParent, "TOP", -(self.manager:GetWidth() - UIParent:GetCenter() * 2) * ((self.db.managerPos - 90) / 90), -13)
			self.manager.toggleButton.normal:SetTexCoord(0, 1, 0, 0.46875)
		end
	else
		self.manager.pos = "BOTTOM"
		self.manager:SetSize(184, self.manager.mode == "raid" and 223 or 148)
		self.manager.toggleButton:SetSize(64, 15)
		self.manager.toggleButton:SetPoint("TOP", 0, -4)
		self.manager.toggleButton:SetHitRectInsets(6, 6, 0, 5)
		self.manager.toggleButton.normal:SetTexture(texturePath.."ManagerToggleHoriz")
		if self.manager.isExpand then
			self.manager:SetPoint("BOTTOM", UIParent, -(self.manager:GetWidth() - UIParent:GetCenter() * 2) * ((270 - self.db.managerPos) / 90), -5)
			self.manager.toggleButton.normal:SetTexCoord(0, 1, 1, 0.53125)
			self.manager.content:ClearAllPoints()
			self.manager.content:SetPoint("TOPLEFT", self.manager.bg, 2, 0)
			self.manager.content:SetPoint("TOPRIGHT", self.manager.bg, -2, 0)
			self.manager.content:SetPoint("BOTTOM", UIParent, 0, 3)
		else
			self.manager:SetPoint("TOP", UIParent, "BOTTOM", -(self.manager:GetWidth() - UIParent:GetCenter() * 2) * ((270 - self.db.managerPos) / 90), 13)
			self.manager.toggleButton.normal:SetTexCoord(0, 1, 0.46875, 0)
		end
	end
end


-- 공격대 관리자 파티 조정
-- 테이블 설정
local partyGroupPosTable = {
	{ "TOPLEFT", 1, 0 },
	{ "TOP", -21, 0 },
	{ "TOP", 21, 0 },
	{ "TOPRIGHT", -1, 0 },
	{ "BOTTOMLEFT", 1, 0 },
	{ "BOTTOM", -21, 0 },
	{ "BOTTOM", 21, 0 },
	{ "BOTTOMRIGHT", -1, 0 },
}

local function groupSetPos(self)
	self:SetUserPlaced(nil)
	self:ClearAllPoints()
	self:SetUserPlaced(nil)
	self:SetPoint(unpack(partyGroupPosTable[lime.db.grouporder[self:GetID()]]))
	self:SetUserPlaced(nil)
	self:SetFrameLevel(14)
end

-- 파티 조정 버튼의 동작을 설정
local function groupOnClick(self)
	lime.db.groupshown[self:GetID()] = not lime.db.groupshown[self:GetID()]
	if lime.db.groupshown[self:GetID()] then
		self.selectedHighlight:Show()
	else
		self.selectedHighlight:Hide()
	end
	lime:UpdateGroupFilter()
end

local function groupOnDragStart(self)
	lime.manager.group.drag = self
	self:SetFrameLevel(15)
	self:SetUserPlaced(nil)
	self:StartMoving()
end

local function groupOnHide(self)
	if lime.manager.group.drag == self then
		lime.manager.group.drag = nil
		self:StopMovingOrSizing()
		groupSetPos(self)
		return true
	end
	return nil
end

local function groupOnDragStop(self)
	if groupOnHide(self) then
		self:GetScript("OnMouseUp")(self)
		for i = 1, 8 do
			if self:GetID() ~= i and lime.manager.group[i]:IsMouseOver() then
				lime.db.grouporder[self:GetID()], lime.db.grouporder[i] = lime.db.grouporder[i], lime.db.grouporder[self:GetID()]
				groupSetPos(self)
				groupSetPos(lime.manager.group[i])
				lime:UpdateGroupFilter()
				break
			end
		end
	end
end

-- 파티 조정 버튼 생성
lime.manager.group = {}
for i = 1, 8 do
	lime.manager.group[i] = lime.manager.content.partyGroup["group"..i]
	lime.manager.group[i]:RegisterForDrag("LeftButton")
	lime.manager.group[i]:SetScript("OnClick", groupOnClick)
	lime.manager.group[i]:SetScript("OnDragStart", groupOnDragStart)
	lime.manager.group[i]:SetScript("OnDragStop", groupOnDragStop)
	lime.manager.group[i]:SetScript("OnHide", groupOnHide)
end

-- 직업별 정렬 시 파티 조정 버튼을 변경
local function classOnClick(self)
	lime.db.classshown[self.class] = not lime.db.classshown[self.class]
	if lime.db.classshown[self.class] then
		self.selectedHighlight:Show()
	else
		self.selectedHighlight:Hide()
	end
	lime:UpdateGroupFilter()
end

local function lookupTable(tbl, value)
	for i = 1, #tbl do
		if tbl[i] == value then
			return i
		end
	end
	return nil
end

-- 직업별 정렬 시 테이블 설정
local classGroupPosTable = {
	{ "TOPLEFT", 3, 0 },
	{ "TOPLEFT", 31, 0 },
	{ "TOPLEFT", 59, 0 },
	{ "TOPLEFT", 87, 0 },
	{ "TOPLEFT", 115, 0 },
	{ "TOPLEFT", 143, 0 },
	{ "BOTTOMLEFT", 3, 0 },
	{ "BOTTOMLEFT", 31, 0 },
	{ "BOTTOMLEFT", 59, 0 },
	{ "BOTTOMLEFT", 87, 0 },
	{ "BOTTOMLEFT", 115, 0 },
	{ "BOTTOMLEFT", 143, 0 },
}

local function classSetPos(self, index)
	index = index or lookupTable(lime.db.classorder, self.class)
	self:SetUserPlaced(nil)
	self:ClearAllPoints()
	self:SetUserPlaced(nil)
	self:SetPoint(unpack(classGroupPosTable[index]))
	self:SetUserPlaced(nil)
	self:SetFrameLevel(14)
end

-- 직업별 정렬 버튼의 동작을 설정
local function classOnDragStart(self)
	lime.manager.group.drag = self
	self:SetFrameLevel(15)
	self:SetUserPlaced(nil)
	self:StartMoving()
end

local function classOnHide(self)
	if lime.manager.group.drag == self then
		lime.manager.group.drag = nil
		self:StopMovingOrSizing()
		classSetPos(self)
		return true
	end
	return nil
end

local function classOnDragStop(self)
	if classOnHide(self) then
		self:GetScript("OnMouseUp")(self)
		for i, class in ipairs(lime.db.classorder) do
			if self.class ~= class and lime.manager.group[class]:IsMouseOver() then
				local index = lookupTable(lime.db.classorder, self.class)
				lime.db.classorder[index], lime.db.classorder[i] = lime.db.classorder[i], lime.db.classorder[index]
				classSetPos(self, i)
				classSetPos(lime.manager.group[class], index)
				lime:UpdateGroupFilter()
				break
			end
		end
	end
end

-- 직업별 정렬 버튼을 초기화
for i, class in ipairs(lime.classes) do
	lime.manager.group[class] = lime.manager.content.classGroup[class]
	lime.manager.group[class]:GetHighlightTexture():SetAlpha(0.25)
	lime.manager.group[class].class = class
	lime.manager.group[class]:SetSize(28, 24)
	lime.manager.group[class].tex = lime.manager.group[class]:CreateTexture(nil, "OVERLAY", nil, 1)
	lime.manager.group[class].tex:SetPoint("CENTER", 0, 0)
	lime.manager.group[class].tex:SetSize(18, 18)
	lime.manager.group[class].tex:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	lime.manager.group[class].tex:SetTexCoord(CLASS_ICON_TCOORDS[class][1], CLASS_ICON_TCOORDS[class][2], CLASS_ICON_TCOORDS[class][3], CLASS_ICON_TCOORDS[class][4])
	lime.manager.group[class]:RegisterForDrag("LeftButton")
	lime.manager.group[class]:SetScript("OnClick", classOnClick)
	lime.manager.group[class]:SetScript("OnDragStart", classOnDragStart)
	lime.manager.group[class]:SetScript("OnDragStop", classOnDragStop)
	lime.manager.group[class]:SetScript("OnHide", classOnHide)
end

-- 정렬 창 통합 업데이트 스크립트
function lime:UpdateManagerGroupFilter()
	if self.manager.group.drag then
		self.manager.group.drag:StopMovingOrSizing()
		self.manager.group.drag:SetUserPlaced(nil)
		self.manager.group.drag = nil
	end
	if self.manager.run and self.manager.isExpand then
		if self.manager.mode == "raid" then
			self.manager.content.everyoneIsAssistButton:Show()
			self.manager.content.groupLine:Show()
			inCombat = InCombatLockdown() or UnitAffectingCombat("player")
			if lime.db.groupby == "GROUP" then
				self.manager.content.partyGroup:Show()
				self.manager.content.classGroup:Hide()
				for i = 1, 8 do
					groupSetPos(self.manager.group[i])
					if inCombat then
						self.manager.group[i]:Disable()
						self.manager.group[i]:SetAlpha(0.5)
						self.manager.group[i].selectedHighlight:SetDesaturated(true)
					else
						self.manager.group[i]:Enable()
						self.manager.group[i]:SetAlpha(1)
						self.manager.group[i].selectedHighlight:SetDesaturated(nil)
					end
					if lime.db.groupshown[i] then
						self.manager.group[i].selectedHighlight:Show()
					else
						self.manager.group[i].selectedHighlight:Hide()
					end
				end
			else
				self.manager.content.partyGroup:Hide()
				self.manager.content.classGroup:Show()
				for i, class in ipairs(self.db.classorder) do
					classSetPos(self.manager.group[class], i)
					if inCombat then
						self.manager.group[class]:Disable()
						self.manager.group[class]:SetAlpha(0.5)
						self.manager.group[class].tex:SetDesaturated(true)
						self.manager.group[class].selectedHighlight:SetDesaturated(true)
					else
						self.manager.group[class]:Enable()
						self.manager.group[class]:SetAlpha(1)
						self.manager.group[class].selectedHighlight:SetDesaturated(nil)
						self.manager.group[class].tex:SetDesaturated(not self.db.classshown[class])
					end
					if self.db.classshown[class] then
						self.manager.group[class].selectedHighlight:Show()
					else
						self.manager.group[class].selectedHighlight:Hide()
					end
				end
			end
		else
			self.manager.content.everyoneIsAssistButton:Hide()
			self.manager.content.groupLine:Hide()
			self.manager.content.partyGroup:Hide()
			self.manager.content.classGroup:Hide()
		end
	end
end