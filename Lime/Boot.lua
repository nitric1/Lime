
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local _G = _G
local type = _G.type
local pairs = _G.pairs
local unpack = _G.unpack
local GetSpellInfo = _G.GetSpellInfo
local LBDB = LibStub("LibLimeDB-1.1")
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- 코어 프레임 설정
local overlord = CreateFrame("Button", (...).."Overlord", UIParent, "SecureHandlerClickTemplate")
lime = CreateFrame("Frame", ..., overlord, "SecureHandlerAttributeTemplate")
lime:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
lime:RegisterEvent("PLAYER_LOGIN")
lime:SetFrameStrata("MEDIUM")
lime:SetFrameLevel(2)
lime:SetMovable(true)
lime:SetClampedToScreen(true)

-- 로그인 시 기본 이벤트 처리
function lime:PLAYER_LOGIN()
	self.PLAYER_LOGIN = nil
	self.playerClass = select(2, UnitClass("player"))
	self:InitDB()
	self.version = GetAddOnMetadata(self:GetName(), "Version")
	self:ApplyProfile()
	self:SelectClickCastingDB()
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PET_BATTLE_OPENING_START")
	self:RegisterEvent("PET_BATTLE_CLOSE")
	self.PLAYER_REGEN_ENABLED = self.UpdateTooltipState
	self.PLAYER_REGEN_DISABLED = self.UpdateTooltipState

	--- Broker 라이브러리
	local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Lime", {
	type = "data source",
	text = "",
	icon = "Interface\\AddOns\\Lime\\Shared\\Texture\\Icon.tga",
	OnClick = function(_, button) lime:OnClick(button) end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		lime:OnTooltip(tooltip)
	end,
	OnLeave = GameTooltip_Hide,
	})
	-- 맵 아이콘 라이브러리
	local icon = LibStub("LibDBIcon-1.0")
	icon:Register("Lime", LDB, limeDB.minimapButton)
	if limeDB.minimapButton.hide then
		icon:Show("Lime")
	else
		icon:Hide("Lime")
	end
	if limeDB.minimapButton.dragable then
	    icon:Unlock("Lime")
	else
	    icon:Lock("Lime")
	end
	self:SetScript("OnHide", limeMember_OnDragStop)
	
	--- 주문 해제 라이브러리
	LibStub("LibLimeDispel-1.0").RegisterCallback(self, "Update", function()
		for member in pairs(lime.visibleMembers) do
			if member:GetScript("OnEvent") and member:IsEventRegistered("UNIT_AURA") and member.displayedUnit then
				member:GetScript("OnEvent")(member, "UNIT_AURA", member.displayedUnit)
			end
		end
	end)
end

function lime:LoadPosition()
	self:SetUserPlaced(nil)
	self:SetScale(self.db.scale)
	self:ClearAllPoints()
	if self.db.px then
		self:SetPoint(self.db.anchor, UIParent, self.db.px / self.db.scale, self.db.py / self.db.scale)
	else
		self:SetPoint(self.db.anchor, UIParent, "CENTER", 0, 0)
	end
end

function lime:SavePosition()
	if self.db.anchor == "TOPLEFT" then
		self.db.px = self:GetLeft() * self.db.scale
		self.db.py = self:GetTop() * self.db.scale - UIParent:GetTop()
	elseif self.db.anchor == "TOPRIGHT" then
		self.db.px = self:GetRight() * self.db.scale - UIParent:GetRight()
		self.db.py = self:GetTop() * self.db.scale - UIParent:GetTop()
	elseif self.db.anchor == "BOTTOMLEFT" then
		self.db.px = self:GetLeft() * self.db.scale
		self.db.py = self:GetBottom() * self.db.scale
	elseif self.db.anchor == "BOTTOMRIGHT" then
		self.db.px = self:GetRight() * self.db.scale - UIParent:GetRight()
		self.db.py = self:GetBottom() * self.db.scale
	end
end

function lime:UpdateTooltipState()
	if self.db.units.tooltip == 0 then
		self.tootipState = nil
	elseif self.db.units.tooltip == 1 then
		self.tootipState = true
	elseif InCombatLockdown() or UnitAffectingCombat("player") then
		self.tootipState = self.db.units.tooltip == 3
	elseif self.db.units.tooltip == 2 then
		self.tootipState = true
	else
		self.tootipState = nil
	end
	if self.onEnter then
		limeMember_OnEnter(self.onEnter)
	end
end

function lime:BorderUpdate(fast)
	if self.db.border then
		if fast then
			self.border.updater:GetScript("OnUpdate")(self.border.updater)
		else
			self.border.updater:Show()
		end
	else
		self.border.updater:Hide()
		self.border:SetAlpha(0)
	end
end

function lime:Message(msg)
	ChatFrame1:AddMessage("|cffa2e665<Lime> |r"..msg, 1, 1, 1)
end

function lime:IsLeader()
	return IsInGroup() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player"))
end

function lime:IsLeader2()
	if IsInRaid() then
		return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
	elseif IsInGroup() then
		return true
	end
	return nil
end

local clearObjectFuncs = {}

function lime:RegisterClearObject(func)
	clearObjectFuncs[func] = true
end

function lime:CallbackClearObject(object)
	for func in pairs(clearObjectFuncs) do
		func(object)
	end
end

local function changeParent(frame, prevParent, newParent)
	if frame and frame:GetParent() == prevParent then
		frame:SetParent(newParent)
	end
end

function lime:HideBlizzardPartyFrame(hide)
	self.db.hideBlizzardParty = hide
	if hide then
		for i = 1, MAX_PARTY_MEMBERS do
			changeParent(_G["PartyMemberFrame"..i], UIParent, self.dummyParent)
		end
		changeParent(PartyMemberBackground, UIParent, self.dummyParent)
	else
		for i = 1, MAX_PARTY_MEMBERS do
			changeParent(_G["PartyMemberFrame"..i], self.dummyParent, UIParent)
		end
		changeParent(PartyMemberBackground, self.dummyParent, UIParent)
	end
end

function lime:GetHeaderHeight(member)
	if member then
		if member > 0 then
			return self.db.height * member + (self.db.offset) * (member - 1)
		else
			return 0.1
		end
	else
		return (self.db.height) * 5 + self.db.offset * 4
	end
end

function lime.GetSpellName(id)
	return GetSpellInfo(id) or ""
end

local savedStatus = true

function lime:PET_BATTLE_OPENING_START()
	savedStatus = self:GetAttribute("run") or lime.db.run
	self:SetAttribute("run", false)
end
function lime:PET_BATTLE_CLOSE()
	self:SetAttribute("run", savedStatus)
end

lime.dummyParent = CreateFrame("Frame")
lime.dummyParent:Hide()

lime.border = CreateFrame("Frame", nil, lime)
lime.border:SetFrameLevel(1)
lime.border:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\AddOns\\Lime\\Shared\\Texture\\Devil3.tga",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
lime.border.updater = CreateFrame("Frame", nil, lime.border)
lime.border.updater:Hide()

local function hasAllPoints(frame)
	return frame:GetLeft() and frame:GetRight() and frame:GetTop() and frame:GetBottom()
end

lime.border.updater:SetScript("OnUpdate", function(self)
	self:Hide()
	self = self:GetParent()
	self.headers = self:GetParent().headers
	self.count, self.left, self.right, self.top, self.bottom = 0
	for i = 0, 8 do
		if self.headers[i]:IsVisible() then
			self.count = self.count + 1
			if self.headers[i].visible > 0 then
				if hasAllPoints(self.headers[i]) then
					if not self.left or self.headers[i]:GetLeft() < self.left:GetLeft() then
						self.left = self.headers[i]
					end
					if not self.right or self.headers[i]:GetRight() > self.right:GetRight() then
						self.right = self.headers[i]
					end

					if not self.top or self.headers[i]:GetTop() > self.top:GetTop() then
						self.top = self.headers[i]
					end
					if not self.bottom or self.headers[i]:GetBottom() < self.bottom:GetBottom() then
						self.bottom = self.headers[i]
					end
				else
					self:SetAlpha(0)
					return self.updater:Show()
				end
			end
		end
	end
	if self.left then
		self:ClearAllPoints()
		if lime.db.anchor == "TOPLEFT" then
			self:SetPoint("TOPLEFT", -5, 5)
			self:SetPoint("RIGHT", self.right, 5, 0)
			self:SetPoint("BOTTOM", self.bottom, "BOTTOM", 0, -5)
		elseif lime.db.anchor == "TOPRIGHT" then
			self:SetPoint("TOPRIGHT", 5, 5)
			self:SetPoint("LEFT", self.left, -5, 0)
			self:SetPoint("BOTTOM", self.bottom, "BOTTOM", 0, -5)
		elseif lime.db.anchor == "BOTTOMLEFT" then
			self:SetPoint("BOTTOMLEFT", -5, -5)
			self:SetPoint("RIGHT", self.right, 5, 0)
			self:SetPoint("TOP", self.top, 0, 5)
		elseif lime.db.anchor == "BOTTOMRIGHT" then
			self:SetPoint("BOTTOMRIGHT", 5, -5)
			self:SetPoint("LEFT", self.left, -5, 0)
			self:SetPoint("TOP", self.top, 0, 5)
		end
		self:SetAlpha(1)
	else
		self:SetAlpha(0)
		if self.count > 0 then
			return self.updater:Show()
		end
	end
	self.headers, self.count, self.left, self.right, self.top, self.bottom, self.anchor = nil
end)

lime.optionFrame = CreateFrame("Frame", lime:GetName().."OptionFrame", InterfaceOptionsFramePanelContainer)
lime.optionFrame:Hide()
lime.optionFrame.name = "lime"
lime.optionFrame.addon = lime:GetName()
lime.optionFrame:SetScript("OnShow", function(self)
	if InCombatLockdown() then
		if not self.title then
			self.title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			self.title:SetText(self.name)
			self.title:SetPoint("TOPLEFT", 8, -12)
			self.version = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			self.version:SetText(lime.version)
			self.version:SetPoint("LEFT", self.title, "RIGHT", 2, 0)
			self.combatWarn = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			self.combatWarn:SetText("combatWarn")
			self.combatWarn:SetPoint("CENTER", 0, 0)
		end
		if not self:IsEventRegistered("PLAYER_REGEN_ENABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:SetScript("OnEvent", nil)
		self:SetScript("OnShow", nil)
		LoadAddOn(self.addon.."_Option")
	end
end)
lime.optionFrame:SetScript("OnEvent", function(self, event, arg)
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if self:IsVisible() and not self.loaded and self:GetScript("OnShow") then
			self:GetScript("OnShow")(self)
		end
	end
end)
InterfaceOptions_AddCategory(lime.optionFrame)

-- 슬래시 명령어
SLASH_lime1 = "/lime"
SLASH_lime2 = "/ya"
SLASH_lime3 = "/양파"
SLASH_lime4 = "/라임"
SLASH_lime5 = "/ㅛㅁ"
SLASH_lime6 = "/ㅇㅍ"
SLASH_lime7 = "/ㄹㅇ"

local function handler(msg)
local command, arg1 = strsplit(" ",msg)
	if command == "s" and arg1 then
		if limeDB.profiles[arg1] then
			if not InCombatLockdown() then
				lime:SetProfile(arg1)
				lime:ApplyProfile()
				lime:Message(L[("Lime_applyprofile")]:format(arg1))
			else 
				lime:Message(L[("Lime_profile_error1")])
			end
		else 	
			lime:Message(L[("Lime_profile_error2")]:format(arg1))
		end 
	elseif command == "s" then
			lime:Message(L["Lime_profile_info"])
	else
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(lime.optionFrame)
	end
end
SlashCmdList["lime"] = handler;

-- 공격대 창 ON/OFF 스크립트
overlord:SetFrameRef("frame", lime)
overlord:Execute("lime = self:GetFrameRef('frame')")
overlord:SetAttribute("_onclick", "lime:SetAttribute('run', not lime:GetAttribute('run'))")
overlord:SetScript("PostClick", function()
	if lime.db.run ~= lime:GetAttribute("run") then
		lime.db.run = lime:GetAttribute("run")
		if lime.db.run then
			lime:Message(L["Lime_Show"])
		else
			lime:Message(L["Lime_Hide"])
		end
		if lime.optionFrame.runMenu and lime.optionFrame.runMenu:IsVisible() then
			lime.optionFrame.runMenu:Update()
		end
		lime.manager.content.hideButton:SetText(lime.db.run and HIDE or SHOW)
	end
end)

-- 단축키 설정 
BINDING_HEADER_lime = "Lime"
BINDING_NAME_lime_OPTION = L["Lime_Preference"]
BINDING_NAME_lime_DOREADYCHECK = L["Lime_ReadyCheck"]
BINDING_NAME_lime_INITIATEROLEPOLL = L["Lime_RoleCheck"]
_G["BINDING_NAME_CLICK limeOverlord:LeftButton"] = L["Lime_Toggle"]

function lime:OnClick(button)
	if button == "RightButton" then
		L_ToggleDropDownMenu(1, nil, lime.mapButtonMenu, "cursor")
	elseif InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == lime.optionFrame then
		InterfaceOptionsFrame_Show()
	else
		InterfaceOptionsFrame_Show()
		InterfaceOptionsFrame_OpenToCategory(lime.optionFrame)
	end
end

--- Broker and Map Button Function
function lime:OnTooltip(tooltip)
	tooltip = tooltip or GameTooltip
	tooltip:AddLine("Lime".." "..lime.version)
	tooltip:AddLine(L["Lime_leftclick"], 1, 1, 0)
	tooltip:AddLine(L["Lime_rightclick"], 1, 1, 0)
end

local function runFunc()
	if InCombatLockdown() then
		lime:Message("전투 중에는 환경을 설정할 수 없습니다.")
	else
		lime:SetAttribute("run", not lime:GetAttribute("run"))
		overlord:GetScript("PostClick")(overlord)
	end
end

local function lockFunc()
	lime.db.lock = not lime.db.lock
end

local function initializeDropDown()
	local info = L_UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	info.isNotRadio = true
	info.text = L["Lime_Preference"]
	info.func = lime.OnClick
	L_UIDropDownMenu_AddButton(info)
	info.notCheckable = nil
	info.text = L["Lime_use"]
	info.checked = lime.db and lime.db.run
	info.func = runFunc
	L_UIDropDownMenu_AddButton(info)
	info.text = L["Lime_lock"]
	info.checked = lime.db and lime.db.lock
	info.func = lockFunc
	L_UIDropDownMenu_AddButton(info)
	info.notCheckable = true
	info.checked = nil
	info.text = L["Lime_ReadyCheck"]
	info.disabled = not lime:IsLeader()
	info.func = DoReadyCheck
	L_UIDropDownMenu_AddButton(info)
	info.text = L["Lime_RoleCheck"]
	info.func = InitiateRolePoll
	L_UIDropDownMenu_AddButton(info)
	info.disabled = nil
	info.func = nil
	info.text = CLOSE
	L_UIDropDownMenu_AddButton(info)
end

lime.mapButtonMenu = CreateFrame("Frame", "LimeMenu", lime, "L_UIDropDownMenuTemplate")
lime.mapButtonMenu:SetID(1)
lime.mapButtonMenu:SetWidth(10)
lime.mapButtonMenu:SetHeight(10)
L_UIDropDownMenu_Initialize(lime.mapButtonMenu, initializeDropDown)

-- 미호환 애드온 리스트 (Obsoleted)
function lime:CheckIncompatible()
	if GetCVar("nameplateShowFriends")=="1" then
		self.db.cflag = false
	else 
		self.db.cflag = true
	end
	-- 경고문 표시 설정
	if self.db.cflag == false and self.db.cwarning == true then
		lime:Message(L["Lime_CheckIncompatible"])
	end
end