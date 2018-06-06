
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local lime = lime
local Option = lime.optionFrame
local LBO = LibStub("LibLimeOption-1.0")
local lime_mapicon = LibStub("LibDBIcon-1.0")

function Option:CreateUseMenu(menu, parent)
	self.CreateUseMenu = nil
	local runList = { L["사용하기"], L["사용 안함"] }
	menu.run = LBO:CreateWidget("DropDown", parent, L["lime_basic_01"], L["lime_basic_desc_01"], nil, nil, true,
		function() return lime.db.run and 1 or 2, runList end,
		function(v)
			lime:SetAttribute("run", v == 1)
			LimeOverlord:GetScript("PostClick")(LimeOverlord)
		end
	)
	menu.run:SetPoint("TOPLEFT", 5, -5)
	self.runMenu = menu.run
	local useList = { L["항상"], L["파티 및 공격대"], L["공격대"] }
	menu.use = LBO:CreateWidget("DropDown", parent, L["lime_basic_02"], L["lime_basic_desc_02"], nil, nil, true,
		function() return lime.db.use, useList end,
		function(v)
			if lime.db.use ~= v then
				lime.db.use = v
				Option:SetOption("use", v)
				lime:ToggleManager()
			end
		end
	)
	menu.use:SetPoint("TOPRIGHT", -5, -5)
	local tooltipList = { L["표시 안함"], L["항상 표시"], L["전투 중이 아닐 때만 표시"], L["전투 중일 때만 표시"] }
	menu.tooltip = LBO:CreateWidget("DropDown", parent, L["lime_basic_03"], L["lime_basic_desc_03"], nil, nil, true,
		function() return lime.db.units.tooltip + 1, tooltipList end,
		function(v)
			lime.db.units.tooltip = v - 1
			lime:UpdateTooltipState()
		end
	)
	menu.tooltip:SetPoint("TOP", menu.run, "BOTTOM", 0, -10)
	menu.lock = LBO:CreateWidget("CheckBox", parent, L["lime_basic_04"], L["lime_basic_desc_04"], nil, nil, true,
		function() return lime.db.lock end,
		function(v)
			lime.db.lock = v
			lime.manager.content.lockButton:SetText(lime.db.lock and UNLOCK or LOCK)
		end
	)
	menu.lock:SetPoint("TOP", menu.use, "BOTTOM", 0, -10)
	self.lockMenu = menu.lock
	menu.mapButtonToggle = LBO:CreateWidget("CheckBox", parent, L["lime_basic_05"], L["lime_basic_desc_05"], nil, nil, true,
		function() return limeDB.minimapButton.hide end,
		function(v)
			limeDB.minimapButton.hide = v
			if limeDB.minimapButton.hide then
				lime_mapicon:Hide("Lime")
			else
				lime_mapicon:Show("Lime")
			end
			menu.mapButtonLock:Update()
		end
	)
	menu.mapButtonToggle:SetPoint("TOP", menu.tooltip, "BOTTOM", 0, 0)
	menu.mapButtonLock = LBO:CreateWidget("CheckBox", parent, L["lime_basic_06"] , L["lime_basic_desc_06"], nil,
		function() return limeDB.minimapButton.hide end, nil,
		function() return not limeDB.minimapButton.dragable end,
		function(v)
			limeDB.minimapButton.dragable = not v
			if limeDB.minimapButton.dragable then
			    lime_mapicon:Unlock("Lime")
			else
			    lime_mapicon:Lock("Lime")
			end
		end
	)
	menu.mapButtonLock:SetPoint("TOP", menu.lock, "BOTTOM", 0, 0)
	menu.hideBlizzardParty = LBO:CreateWidget("CheckBox", parent, L["lime_basic_07"], L["lime_basic_desc_07"], nil, nil, true,
		function() return lime.db.hideBlizzardParty end,
		function(v)
			lime:HideBlizzardPartyFrame(v)
		end
	)
	menu.hideBlizzardParty:SetPoint("TOP", menu.mapButtonToggle, "BOTTOM", 0, 0)
	menu.clear = LBO:CreateWidget("Button", parent, L["lime_basic_08"],L["lime_basic_desc_08"] , nil, nil, true,
		function()
			lime.db.px, lime.db.py = nil
			lime:SetUserPlaced(nil)
			lime:ClearAllPoints()
			lime:SetPoint(lime.db.anchor, UIParent, "CENTER", 0, 0)
			lime:SetUserPlaced(nil)
		end
	)
	menu.clear:SetPoint("TOP", menu.mapButtonLock, "BOTTOM", 0, 0)
	menu.manager = LBO:CreateWidget("CheckBox", parent, L["lime_basic_09"], L["lime_basic_09"], nil, nil, true,
		function() return lime.db.useManager end,
		function(v)
			lime.db.useManager = v
			lime:ToggleManager()
			LBO:Refresh()
		end
	)
	menu.manager:SetPoint("TOP", menu.hideBlizzardParty, "BOTTOM", 0, -10)
	menu.managerPos = LBO:CreateWidget("Slider", parent, L["lime_basic_10"], L["lime_basic_desc_10"], nil, function() return not lime.db.useManager end, nil,
		function() return lime.db.managerPos, 0, 360, 0.1, L["도"] end,
		function(v)
			lime.db.managerPos = v
			lime:SetManagerPosition()
		end
	)

	menu.managerPos:SetPoint("TOP", menu.clear, "BOTTOM", 0, -10)
	local castingSentList = { L["표시 안함"], L["항상 표시"], L["마우스를 올릴 때 표시"] }
	menu.castingSent = LBO:CreateWidget("DropDown", parent, L["lime_basic_11"], L["lime_basic_desc_11"], nil, nil, true,
		function() return lime.db.castingSent + 1, castingSentList end,
		function(v)
			lime.db.castingSent = v - 1
		end
	)
	menu.castingSent:SetPoint("TOP", menu.manager, "BOTTOM", 0, -10)
end

function Option:CreateGroupMenu(menu, parent)
	Option.CreateGroupMenu = nil
	local groupbyList = { L["파티별"], L["직업별"] }
	menu.groupby = LBO:CreateWidget("DropDown", parent, L["lime_basic_12"], L["lime_basic_desc_12"], nil, nil, true,
		function() return lime.db.groupby == "GROUP" and 1 or 2, groupbyList end,
		function(v)
			lime.db.groupby = v == 1 and "GROUP" or "CLASS"
			menu.group:Update()
			menu.class:Update()
			lime:UpdateGroupFilter()
		end
	)
	menu.groupby:SetPoint("TOPLEFT", 5, -5)
	local anchorList = { L["좌측 상단"], L["우측 상단"], L["좌측 하단"], L["우측 하단"] }
	menu.anchor = LBO:CreateWidget("DropDown", parent, L["lime_basic_13"], L["lime_basic_desc_13"], nil, nil, true,
		function()
			if lime.db.anchor == "TOPLEFT" then
				return 1, anchorList
			elseif lime.db.anchor == "TOPRIGHT" then
				return 2, anchorList
			elseif lime.db.anchor == "BOTTOMLEFT" then
				return 3, anchorList
			else
				return 4, anchorList
			end
		end,
		function(v)
			if v == 1 then
				lime.db.anchor = "TOPLEFT"
			elseif v == 2 then
				lime.db.anchor = "TOPRIGHT"
			elseif v == 3 then
				lime.db.anchor = "BOTTOMLEFT"
			else
				lime.db.anchor = "BOTTOMRIGHT"
			end
			lime:SavePosition()
			lime:LoadPosition()
			lime:UpdateGroupFilter()
		end
	)
	menu.anchor:SetPoint("TOPRIGHT", -5, -5)
	menu.column = LBO:CreateWidget("Slider", parent, L["lime_basic_14"], L["lime_basic_desc_14"], nil, nil, true,
		function() return lime.db.column, 1, 8, 1, L["개 그룹"] end,
		function(v)
			lime.db.column = v
			lime:UpdateGroupFilter()
		end
	)
	menu.column:SetPoint("TOP", menu.groupby, "BOTTOM", 0, -5)
	local dirList = { L["세로 방향"], L["가로 방향"] }
	menu.dir = LBO:CreateWidget("DropDown", parent, L["lime_basic_15"], L["lime_basic_desc_15"], nil, nil, true,
		function() return lime.db.dir, dirList end,
		function(v)
			lime.db.dir = v
			lime:UpdateGroupFilter()
		end
	)
	menu.dir:SetPoint("TOP", menu.anchor, "BOTTOM", 0, -5)
	menu.partyTag = LBO:CreateWidget("CheckBox", parent, L["lime_basic_16"], L["lime_basic_desc_16"], nil, nil, true,
		function() return lime.db.partyTag end,
		function(v)
			lime.db.partyTag = v
			lime:UpdateGroupFilter()
		end
	)
	menu.partyTag:SetPoint("TOP", menu.column, "BOTTOM", 0, -5)
	menu.sortName = LBO:CreateWidget("CheckBox", parent, L["lime_basic_17"], L["lime_basic_desc_17"], nil, nil, true,
		function() return lime.db.sortName end,
		function(v)
			lime.db.sortName = v
			lime:UpdateGroupFilter()
		end
	)
	menu.sortName:SetPoint("TOP", menu.dir, "BOTTOM", 0, -5)
	menu.group = LBO:CreateWidget("ShowHide", parent, function() return lime.db.groupby ~= "GROUP" end)
	menu.group:SetPoint("TOPLEFT", menu.partyTag, "BOTTOMLEFT", 0, 0)
	menu.group:SetPoint("RIGHT", 0, -5)
	menu.group:SetHeight(160)
	menu.group:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		tile = true, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	menu.group:SetBackdropColor(0, 0, 0)
	menu.group.text = menu.group:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	menu.group.text:SetPoint("TOPLEFT", 10, -5)
	menu.group.text:SetPoint("TOPRIGHT", -10, -5)
	menu.group.text:SetHeight(30)
	menu.group.text:SetJustifyH("LEFT")
	menu.group.text:SetText(L["lime_basic_18"])

	Option.group = {}
	Option.groupAnchor = {}
	local function setGroupPos(self)
		self:SetUserPlaced(nil)
		self:ClearAllPoints()
		self:SetUserPlaced(nil)
		self:SetPoint("CENTER", Option.groupAnchor[lime.db.grouporder[self.index]], 0, 0)
		self:SetUserPlaced(nil)
		self:SetFrameLevel(menu.group:GetFrameLevel() + 1)
	end
	local function groupOnHide(self)
		if Option.group.drag == self then
			Option.group.drag = nil
			self:SetUserPlaced(nil)
			self:StopMovingOrSizing()
			self:SetUserPlaced(nil)
			self:SetFrameLevel(menu.group:GetFrameLevel() + 1)
			return true
		end
		return nil
	end
	local function groupOnDragStop(self)
		if groupOnHide(self) then
			self:GetScript("OnMouseUp")(self)
			for i = 1, 8 do
				if i ~= self.index and Option.group[i]:IsMouseOver() then
					lime.db.grouporder[self.index], lime.db.grouporder[i] = lime.db.grouporder[i], lime.db.grouporder[self.index]
					setGroupPos(Option.group[i])
					return lime:UpdateGroupFilter()
				end
			end
		end
		setGroupPos(Option.group[self.index])
	end
	local function groupOnDragStart(self)
		Option.group.drag = self
		self:SetFrameLevel(menu.group:GetFrameLevel() + 2)
		self:SetUserPlaced(nil)
		self:StartMoving()
		self:SetUserPlaced(nil)
	end
	local function groupOnClick(self)
		lime.db.groupshown[self.index] = not lime.db.groupshown[self.index]
		lime:UpdateGroupFilter()
	end
	Option.group.Update = function()
		if Option.group.drag then
			groupOnHide(Option.group.drag)
		end
		if menu.group.visible:IsVisible() then
			if InCombatLockdown() or UnitAffectingCombat("player") then
				for i = 1, 8 do
					setGroupPos(Option.group[i])
					Option.group[i]:Disable()
					Option.group[i]:SetAlpha(0.5)
					if lime.db.groupshown[i] then
						Option.group[i].selectedHighlight:Show()
					else
						Option.group[i].selectedHighlight:Hide()
					end
				end
			else
				for i = 1, 8 do
					setGroupPos(Option.group[i])
					Option.group[i]:Enable()
					Option.group[i]:SetAlpha(1)
					if lime.db.groupshown[i] then
						Option.group[i].selectedHighlight:Show()
					else
						Option.group[i].selectedHighlight:Hide()
					end
				end
			end
		end
	end
	for i = 1, 8 do
		Option.group[i] = CreateFrame("Button", Option:GetName().."GroupButton"..i, menu.group.visible, "CRFManagerFilterGroupButtonTemplate")
		Option.group[i].index = i
		Option.group[i]:SetFrameLevel(menu.group:GetFrameLevel() + 1)
		Option.group[i]:SetSize(36, 36)
		Option.group[i]:SetText(i)
		Option.group[i]:SetMovable(true)
		Option.group[i]:RegisterForDrag("LeftButton")
		Option.group[i]:SetClampedToScreen(true)
		Option.group[i]:SetScript("OnDragStart", groupOnDragStart)
		Option.group[i]:SetScript("OnDragStop", groupOnDragStop)
		Option.group[i]:SetScript("OnHide", groupOnHide)
		Option.group[i]:SetScript("OnClick", groupOnClick)
		Option.groupAnchor[i] = menu.group.visible:CreateTexture()
		Option.groupAnchor[i]:SetSize(36, 36)
	end
	Option.groupAnchor[1]:SetPoint("TOPRIGHT", Option.groupAnchor[2], "TOPLEFT", -2, 0)
	Option.groupAnchor[2]:SetPoint("TOPRIGHT", menu.group.text, "BOTTOM", -1, -20)
	Option.groupAnchor[3]:SetPoint("TOPLEFT", menu.group.text, "BOTTOM", 1, -20)
	Option.groupAnchor[4]:SetPoint("TOPLEFT", Option.groupAnchor[3], "TOPRIGHT", 2, 0)
	Option.groupAnchor[5]:SetPoint("TOP", Option.groupAnchor[1], "BOTTOM", 0, -2)
	Option.groupAnchor[6]:SetPoint("TOP", Option.groupAnchor[2], "BOTTOM", 0, -2)
	Option.groupAnchor[7]:SetPoint("TOP", Option.groupAnchor[3], "BOTTOM", 0, -2)
	Option.groupAnchor[8]:SetPoint("TOP", Option.groupAnchor[4], "BOTTOM", 0, -2)
	menu.group.visible:SetScript("OnShow", Option.group.Update)
	menu.group.visible:SetScript("OnEvent", Option.group.Update)
	menu.group.visible:RegisterEvent("PLAYER_ENTERING_WORLD")
	menu.group.visible:RegisterEvent("PLAYER_REGEN_DISABLED")
	menu.group.visible:RegisterEvent("PLAYER_REGEN_ENABLED")

	menu.class = LBO:CreateWidget("ShowHide", parent, function() return lime.db.groupby ~= "CLASS" end)
	menu.class:SetAllPoints(menu.group)

	Option.class = {}
	Option.classAnchor = {}
	local function lookupTable(tbl, value)
		for i = 1, #tbl do
			if tbl[i] == value then
				return i
			end
		end
		return nil
	end
	local function setclassPos(self, index)
		index = index or lookupTable(lime.db.classorder, self.index)
		self:SetUserPlaced(nil)
		self:ClearAllPoints()
		self:SetUserPlaced(nil)
		self:SetPoint("CENTER", Option.classAnchor[index], 0, 0)
		self:SetUserPlaced(nil)
		self:SetFrameLevel(menu.class:GetFrameLevel() + 1)
	end
	local function classOnHide(self)
		if Option.class.drag == self then
			Option.class.drag = nil
			self:SetUserPlaced(nil)
			self:StopMovingOrSizing()
			self:SetUserPlaced(nil)
			self:SetFrameLevel(menu.class:GetFrameLevel() + 1)
			return true
		end
		return nil
	end
	local function classOnDragStop(self)
		if classOnHide(self) then
			self:GetScript("OnMouseUp")(self)
			for i, class in ipairs(lime.db.classorder) do
				if self.index ~= class and Option.class[class]:IsMouseOver() then
					local index = lookupTable(lime.db.classorder, self.index)
					lime.db.classorder[index], lime.db.classorder[i] = lime.db.classorder[i], lime.db.classorder[index]
					return lime:UpdateGroupFilter()
				end
			end
		end
		setclassPos(Option.class[self.index])
	end
	local function classOnDragStart(self)
		Option.class.drag = self
		self:SetFrameLevel(menu.class:GetFrameLevel() + 2)
		self:SetUserPlaced(nil)
		self:StartMoving()
		self:SetUserPlaced(nil)
	end
	local function classOnClick(self)
		lime.db.classshown[self.index] = not lime.db.classshown[self.index]
		lime:UpdateGroupFilter()
	end
	Option.class.Update = function()
		if Option.class.drag then
			classOnHide(Option.class.drag)
		end
		if menu.class.visible:IsVisible() then
			if InCombatLockdown() or UnitAffectingCombat("player") then
				for i, class in ipairs(lime.db.classorder) do
					setclassPos(Option.class[class], i)
					Option.class[class]:Disable()
					Option.class[class]:SetAlpha(0.5)
					if lime.db.classshown[class] then
						Option.class[class].selectedHighlight:Show()
					else
						Option.class[class].selectedHighlight:Hide()
					end
				end
			else
				for i, class in ipairs(lime.db.classorder) do
					setclassPos(Option.class[class], i)
					Option.class[class]:Enable()
					Option.class[class]:SetAlpha(1)
					if lime.db.classshown[class] then
						Option.class[class].selectedHighlight:Show()
					else
						Option.class[class].selectedHighlight:Hide()
					end
				end
			end
		end
	end
	for i, class in ipairs(lime.classes) do
		Option.class[class] = CreateFrame("Button", Option:GetName().."ClassButton"..i, menu.class.visible, "CRFManagerFilterGroupButtonTemplate")
		Option.class[class]:GetHighlightTexture():SetAlpha(0.25)
		Option.class[class].index = class
		Option.class[class]:SetFrameLevel(menu.class:GetFrameLevel() + 1)
		Option.class[class]:SetSize(36, 36)
		Option.class[class]:SetMovable(true)
		Option.class[class]:RegisterForDrag("LeftButton")
		Option.class[class]:SetClampedToScreen(true)
		Option.class[class]:SetScript("OnDragStart", classOnDragStart)
		Option.class[class]:SetScript("OnDragStop", classOnDragStop)
		Option.class[class]:SetScript("OnHide", classOnHide)
		Option.class[class]:SetScript("OnClick", classOnClick)
		Option.class[class].tex = Option.class[class]:CreateTexture(nil, "OVERLAY", 2)
		Option.class[class].tex:SetPoint("CENTER", 0, 0)
		Option.class[class].tex:SetSize(30, 30)
		Option.class[class].tex:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
		Option.class[class].tex:SetTexCoord(CLASS_ICON_TCOORDS[class][1], CLASS_ICON_TCOORDS[class][2], CLASS_ICON_TCOORDS[class][3], CLASS_ICON_TCOORDS[class][4])
		Option.class[class].tex:SetAlpha(0.75)
		Option.classAnchor[i] = menu.class.visible:CreateTexture()
		Option.classAnchor[i]:SetSize(36, 36)
	end

	Option.classAnchor[1]:SetPoint("TOPRIGHT", Option.classAnchor[2], "TOPLEFT", -2, 0)
	Option.classAnchor[2]:SetPoint("TOPRIGHT", Option.classAnchor[3], "TOPLEFT", -2, 0)
	Option.classAnchor[3]:SetPoint("TOPRIGHT", menu.group.text, "BOTTOM", -1, -20)
	Option.classAnchor[4]:SetPoint("TOPLEFT", menu.group.text, "BOTTOM", 1, -20)
	Option.classAnchor[5]:SetPoint("TOPLEFT", Option.classAnchor[4], "TOPRIGHT", 2, 0)
	Option.classAnchor[6]:SetPoint("TOPLEFT", Option.classAnchor[5], "TOPRIGHT", 2, 0)
	Option.classAnchor[7]:SetPoint("TOP", Option.classAnchor[1], "BOTTOM", 0, -2)
	Option.classAnchor[8]:SetPoint("TOP", Option.classAnchor[2], "BOTTOM", 0, -2)
	Option.classAnchor[9]:SetPoint("TOP", Option.classAnchor[3], "BOTTOM", 0, -2)
	Option.classAnchor[10]:SetPoint("TOP", Option.classAnchor[4], "BOTTOM", 0, -2)
	Option.classAnchor[11]:SetPoint("TOP", Option.classAnchor[5], "BOTTOM", 0, -2)
	Option.classAnchor[12]:SetPoint("TOP", Option.classAnchor[6], "BOTTOM", 0, -2)

	menu.class.visible:SetScript("OnShow", Option.class.Update)
	menu.class.visible:SetScript("OnEvent", Option.class.Update)
	menu.class.visible:RegisterEvent("PLAYER_ENTERING_WORLD")
	menu.class.visible:RegisterEvent("PLAYER_REGEN_DISABLED")
	menu.class.visible:RegisterEvent("PLAYER_REGEN_ENABLED")
end
