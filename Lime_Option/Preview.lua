local lime = lime
local Option = lime.optionFrame
local SM = LibStub("LibSharedMedia-3.0")
local preview, height, statusBarTexture, fontFile

local function registerDrag(btn)
	btn:EnableMouse(true)
	btn:RegisterForDrag("LeftButton", "RightButton")
	btn:SetScript("OnDragStart", limeMember_OnDragStart)
	btn:SetScript("OnDragStop", limeMember_OnDragStop)
	btn:SetScript("OnHide", limeMember_OnDragStop)
end

local function dummy() end

local function createButton(btn)
	btn = CreateFrame("Frame", nil, btn)
	btn.powerBar = btn:CreateTexture(nil, "BORDER")
	btn.powerBar.SetOrientation = dummy
	btn.powerBar:SetPoint("BOTTOMLEFT", 0, 0)
	btn.powerBar:SetPoint("BOTTOMRIGHT", 0, 0)
	btn.healthBar = btn:CreateTexture(nil, "BORDER")
	btn.healthBar:SetPoint("TOPLEFT", 0, 0)
	btn.healthBar:SetPoint("BOTTOMRIGHT", btn.powerBar, "TOPRIGHT", 0, 0)
	registerDrag(btn)
	return btn
end

local classList = { "WARRIOR", "PRIEST", "ROGUE", "MAGE", "WARLOCK", "HUNTER", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT", "MONK", "DEMONHUNTER" }
local powerColor = { WARRIOR = "1", PRIEST = "05", ROGUE = "3", MAGE = "0", WARLOCK = "0", HUNTER = "2", DRUID = "013", SHAMAN = "09", PALADIN = "0", DEATHKNIGHT = "6", MONK ="03", DEMONHUNTER = "78" }
local powerMatch = { ["0"] = "MANA", ["1"] = "RAGE", ["2"] = "FOCUS", ["3"] = "ENERGY", ["4"] = "LUNAR_POWER", ["5"] = "INSANITY", ["6"] = "RUNIC_POWER", ["7"] = "PAIN", ["8"] = "FURY", ["9"] = "MAELSTROM" }
local allPower = "0123456789"

local function createPreview()
	createPreview = nil
	preview = CreateFrame("Frame", "limePreview", UIParent)
	Option.preview = preview
	preview:SetAllPoints(lime)
	preview:SetFrameStrata(lime:GetFrameStrata())
	preview:SetFrameLevel(1)
	preview:RegisterEvent("PLAYER_REGEN_DISABLED")
	preview:SetScript("OnEvent", function(self)
		if self:IsShown() then
			self.show = nil
			self:Hide()
			Option.previewDropdown:Update()
		end
	end)
	preview.border = CreateFrame("Frame", nil, preview)
	preview.border:SetBackdrop(lime.border:GetBackdrop())
	preview.headers = {}
	preview.headers[0] = preview:CreateTexture()
	preview.headers[0]:Hide()
	for i = 1, 8 do
		preview.headers[i] = CreateFrame("Frame", nil, preview)
		preview.headers[i]:SetAttribute("groupindex", i)
		preview.headers[i].partyTag = CreateFrame("Frame", nil, preview.headers[i])
		preview.headers[i].partyTag.tex = preview.headers[i].partyTag:CreateTexture(nil, "BORDER")
		preview.headers[i].partyTag.tex:SetAllPoints()
		preview.headers[i].partyTag.text = preview.headers[i].partyTag:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		preview.headers[i].partyTag.text:SetPoint("CENTER")
		registerDrag(preview.headers[i].partyTag)
		preview.headers[i].members, preview.headers[i].visible = {}, 5
		for j = 1, 5 do
			preview.headers[i].members[j] = createButton(preview.headers[i])
			preview.headers[i].members[j].class = classList[random(1, 12)]
			height = random(1, powerColor[preview.headers[i].members[j].class]:len())
			preview.headers[i].members[j].powerBar.color = powerMatch[powerColor[preview.headers[i].members[j].class]:sub(height, height)]
			preview.headers[i].members[j].name = preview.headers[i].members[j]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			preview.headers[i].members[j].name:SetPoint("CENTER", preview.headers[i].members[j].healthBar, 0, 5)
			preview.headers[i].members[j].name:SetFormattedText("%d-%d", i, j)
			preview.headers[i].members[j].losttext = preview.headers[i].members[j]:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			preview.headers[i].members[j].losttext:SetPoint("TOP", preview.headers[i].members[j].name, "BOTTOM", 0, -2)
		end
	end
	wipe(classList)
	wipe(powerColor)
	registerDrag, createButton, classList, powerColor = nil
	preview.UpdatePosition = "if name == \"updateposition\" then"..lime:GetAttribute("_onattributechanged"):match("elseif name == \"updateposition\" then(.+)")
	preview.UpdatePosition = preview.UpdatePosition:gsub("self:GetAttribute", "lime:GetAttribute")
	preview.UpdatePosition = loadstring("return function(self, lime, HEADERS, LIST, name)\n"..preview.UpdatePosition.."\nend")()
	preview.border.dummy = preview.border:CreateTexture()
	preview.CallMethod = function(self, method)
		if method == "BorderUpdate" then
			if lime.db.border then
				lime.border.updater:GetScript("OnUpdate")(self.border.dummy)
				self.border:SetAlpha(1)
				self.border:Show()
			else
				self.border:Hide()
			end
		end
	end
end

local numMembers = { 0, 1, 2, 4, 5, 6, 8 }
local LIST = {}

local function checkHeader(show, index)
	if show < index then
		return nil
	elseif lime.db.groupby ~= "GROUP" then
		return true
	elseif show == 1 and index == 1 then
		return true
	else
		return lime.db.groupshown[index]
	end
end

local p1, p2, o1, o2, width

function Option:SetPreview(show)
	if show and numMembers[show] and numMembers[show] > 0 and not InCombatLockdown() then
		if createPreview then
			createPreview()
		end
		lime:SetAttribute("preview", true)
		preview.show = show
		preview:Show()
		preview:SetScale(lime.db.scale)
		preview.border:SetBackdropColor(unpack(lime.db.borderBackdrop))
		preview.border:SetBackdropBorderColor(unpack(lime.db.borderBackdropBorder))
		statusBarTexture = SM:Fetch("statusbar", lime.db.units.texture)
		fontFile = SM:Fetch("font", lime.db.font.file)
		if lime.db.dir == 1 then
			width = lime.db.width
			height = (lime.db.height + lime.db.offset) * 5 - lime.db.offset
			if lime.db.anchor:find("TOP") then
				p1, p2, o1, o2 = "TOP", "BOTTOM", 0, 0 - lime.db.offset
			else
				p1, p2, o1, o2 = "BOTTOM", "TOP", 0, 0 + lime.db.offset
			end
		else
			width = lime.db.width * 5 + lime.db.offset * 4
			height = lime.db.height
			if lime.db.anchor:find("LEFT") then
				p1, p2, o1, o2 = "LEFT", "RIGHT", lime.db.offset, 0
			else
				p1, p2, o1, o2 = "RIGHT", "LEFT", -lime.db.offset, 0
			end
		end
		local members = 0
		for i = 1, 8 do
			if checkHeader(numMembers[show], i) then
				members = members + 5
				preview.headers[i]:Show()
				preview.headers[i]:SetWidth(width)
				preview.headers[i]:SetHeight(height)
				if lime.db.groupby == "GROUP" and lime.db.partyTag then
					preview.headers[i].partyTag:ClearAllPoints()
					if lime.db.dir == 1 then
						preview.headers[i].partyTag:SetPoint(p2.."LEFT", preview.headers[i], p1.."LEFT", 0, 0)
						preview.headers[i].partyTag:SetPoint(p2.."RIGHT", preview.headers[i], p1.."RIGHT", 0, 0)
						preview.headers[i].partyTag:SetHeight(12)
						preview.headers[i].partyTag.text:SetFormattedText("Group %d", i)
					else
						preview.headers[i].partyTag:SetPoint("TOP"..p2, preview.headers[i], "TOP"..p1, 0, 0)
						preview.headers[i].partyTag:SetPoint("BOTTOM"..p2, preview.headers[i], "BOTTOM"..p1, 0, 0)
						preview.headers[i].partyTag:SetWidth(12)
						preview.headers[i].partyTag.text:SetText(i)
					end
					preview.headers[i].partyTag.tex:SetColorTexture(lime.db.partyTagRaid[1], lime.db.partyTagRaid[2], lime.db.partyTagRaid[3], lime.db.partyTagRaid[4])
					preview.headers[i].partyTag:Show()
				else
					preview.headers[i].partyTag:SetHeight(0.001)
					preview.headers[i].partyTag:Hide()
				end
				for j = 1, 5 do
					preview.headers[i].members[j]:SetWidth(lime.db.width)
					preview.headers[i].members[j]:SetHeight(lime.db.height)
					preview.headers[i].members[j]:ClearAllPoints()
					if j == 1 then
						preview.headers[i].members[j]:SetPoint(p1, 0, 0)
					else
						preview.headers[i].members[j]:SetPoint(p1, preview.headers[i].members[j - 1], p2, o1, o2)
					end
					preview.headers[i].members[j].healthBar:SetTexture(statusBarTexture)
					preview.headers[i].members[j].name:SetFont(fontFile, lime.db.font.size, lime.db.font.attribute)
					preview.headers[i].members[j].name:SetShadowColor(0, 0, 0)
					preview.headers[i].members[j].losttext:SetFont(fontFile, lime.db.font.size, lime.db.font.attribute)
					preview.headers[i].members[j].losttext:SetShadowColor(0, 0, 0)
					if lime.db.font.shadow then
						preview.headers[i].members[j].name:SetShadowOffset(1, -1)
						preview.headers[i].members[j].losttext:SetShadowOffset(1, -1)
					else
						preview.headers[i].members[j].name:SetShadowOffset(0, 0)
						preview.headers[i].members[j].losttext:SetShadowOffset(0, 0)
					end
					if lime.db.units.className then
						preview.headers[i].members[j].name:SetTextColor(lime.db.colors[preview.headers[i].members[j].class][1], lime.db.colors[preview.headers[i].members[j].class][2], lime.db.colors[preview.headers[i].members[j].class][3])
					else
						preview.headers[i].members[j].name:SetTextColor(lime.db.colors.name[1], lime.db.colors.name[2], lime.db.colors.name[3])
					end
					if lime.db.units.useClassColors then
						preview.headers[i].members[j].healthBar:SetVertexColor(lime.db.colors[preview.headers[i].members[j].class][1], lime.db.colors[preview.headers[i].members[j].class][2], lime.db.colors[preview.headers[i].members[j].class][3])
					else
						preview.headers[i].members[j].healthBar:SetVertexColor(lime.db.colors.help[1], lime.db.colors.help[2], lime.db.colors.help[3])
					end
					preview.headers[i].members[j].powerBar:SetTexture(statusBarTexture)
					preview.headers[i].members[j].powerBar:SetVertexColor(lime.db.colors[preview.headers[i].members[j].powerBar.color][1], lime.db.colors[preview.headers[i].members[j].powerBar.color][2], lime.db.colors[preview.headers[i].members[j].powerBar.color][3])
					lime.headers[0].members[1].SetupPowerBar(preview.headers[i].members[j])
				end
			else
				preview.headers[i]:Hide()
			end
		end
		preview:UpdatePosition(lime, preview.headers, LIST, "updateposition")
	else
		if not InCombatLockdown() then
			lime:SetAttribute("preview", nil)
		end
		if preview then
			preview.show = nil
			preview:Hide()
			Option.previewDropdown:Update()
		end
	end
end

function Option:UpdatePreview()
	if self:GetPreviewState() > 1 then
		self:SetPreview(preview.show)
	end
end

function Option:GetPreviewState()
	if not InCombatLockdown() and preview and preview.show then
		return preview.show
	else
		return 1
	end
end