local lime = lime
local Option = lime.optionFrame
local LBO = LibStub("LibLimeOption-1.0")
local SM = LibStub("LibSharedMedia-3.0")

local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local unpack = _G.unpack

function Option:CreateFrameMenu(menu, parent)
	local function updateTexture(member)
		member:SetupTexture()
		if member:IsVisible() then
			limeMember_UpdateState(member)
			limeMember_UpdatePowerColor(member)
		end
	end
	menu.texture = LBO:CreateWidget("Media", parent, "바 텍스처", "바 텍스처를 설정합니다.", nil, nil, true,
		function() return lime.db.units.texture, "statusbar" end,
		function(v)
			lime.db.units.texture = v
			Option:UpdateMember(updateTexture)
			Option:UpdatePreview()
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)
	menu.scale = LBO:CreateWidget("Slider", parent, "크기", "프레임의 전체적인 크기를 조절합니다.", nil, nil, true,
		function()
			return lime.db.scale * 100, 50, 150, 1, "%"
		end,
		function(v)
			lime.db.scale = v / 100
			lime:LoadPosition()
			if Option.preview then
				Option.preview:SetScale(lime.db.scale)
			end
		end
	)
	menu.scale:SetPoint("TOPRIGHT", -5, -5)

	menu.width = LBO:CreateWidget("Slider", parent, "너비", "프레임의 너비를 조절합니다.", nil, nil, true,
		function()
			return lime.db.width, 32, 256, 1, "픽셀"
		end,
		function(v)
			lime.db.width = v
			lime.nameWidth = v - 2
			lime:SetWidth(v)
			lime:SetAttribute("width", v)
			for _, header in pairs(lime.headers) do
				header:SetWidth(v)
				for _, member in pairs(header.members) do
					member:SetWidth(v)
					member:SetupPowerBar()
					member:SetupBarOrientation()
				end
				if header:IsVisible() then
					header:Hide()
					header:Show()
				end
			end
			Option:UpdatePreview()
		end
	)
	menu.width:SetPoint("TOP", menu.texture, "BOTTOM", 0, -10)
	menu.height = LBO:CreateWidget("Slider", parent, "높이", "프레임의 높이를 조절합니다.", nil, nil, true,
		function()
			return lime.db.height, 25, 256, 1, "픽셀"
		end,
		function(v)
			lime.db.height = v
			lime:SetHeight(v)
			lime:SetAttribute("height", v)
			for _, header in pairs(lime.headers) do
				for _, member in pairs(header.members) do
					member:SetHeight(v)
					member:SetupPowerBar()
					member:SetupBarOrientation()
				end
				if header:IsVisible() then
					header:Hide()
					header:Show()
				end
			end
			lime:SetAttribute("updateposition", not lime:GetAttribute("updateposition"))
			Option:UpdatePreview()
		end
	)
	menu.height:SetPoint("TOP", menu.scale, "BOTTOM", 0, -10)
	menu.offset = LBO:CreateWidget("Slider", parent, "간격", "각 플레이어 간의 간격을 조절합니다.", nil, nil, true,
		function()
			return lime.db.offset, 0, 30, 1, "픽셀"
		end,
		function(v)
			lime.db.offset = v
			Option:SetOption("offset", v)
			Option:UpdatePreview()
		end
	)
	menu.offset:SetPoint("TOP", menu.width, "BOTTOM", 0, -10)
	menu.highlightAlpha = LBO:CreateWidget("Slider", parent, "강조 투명도", "마우스를 올렸을 때 강조되는 텍스처의 투명도를 설정합니다. 0으로 설정하면 보이지 않습니다.", nil, nil, true,
		function()
			return lime.db.highlightAlpha * 100, 0, 100, 1, "%"
		end,
		function(v)
			lime.db.highlightAlpha = v / 100

		end
	)
	menu.highlightAlpha:SetPoint("TOP", menu.height, "BOTTOM", 0, -10)
	local function updateBG(member)
		member.background:SetColorTexture(lime.db.units.backgroundColor[1], lime.db.units.backgroundColor[2], lime.db.units.backgroundColor[3], lime.db.units.backgroundColor[4])
	end
	menu.color = LBO:CreateWidget("ColorPicker", parent, "배경 색상", "각 플레이어의 배경 색상 및 투명도를 설정합니다.", nil, nil, true,
		function()
			return lime.db.units.backgroundColor[1], lime.db.units.backgroundColor[2], lime.db.units.backgroundColor[3], lime.db.units.backgroundColor[4]
		end,
		function(r, g, b, a)
			lime.db.units.backgroundColor[1], lime.db.units.backgroundColor[2], lime.db.units.backgroundColor[3], lime.db.units.backgroundColor[4] = r, g, b, a
			Option:UpdateMember(updateBG)
		end
	)
	menu.color:SetPoint("TOP", menu.offset, "BOTTOM", 0, -10)
end

function Option:CreateHealthBarMenu(menu, parent)
	local orientationList = { "가로", "세로" }
	local function updateOrientation(member)

	end
	menu.orientation = LBO:CreateWidget("DropDown", parent, "생명력 바 방향", "생명력 바의 진행 방향을 설정합니다.", nil, nil, true,
		function()
			return lime.db.units.orientation, orientationList
		end,
		function(v)
			lime.db.units.orientation = v
			Option:UpdateMember(lime.headers[0].members[1].SetupBarOrientation)
		end
	)
	menu.orientation:SetPoint("TOPLEFT", 5, -5)
	local function updateColor(member)
		if member:IsVisible() then
			limeMember_UpdateState(member)
		end
	end
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "직업별 생명력 바 색상", "직업별 색상에 따라 생명력 바 색상을 변경합니다.", nil, nil, true,
		function()
			return lime.db.units.useClassColors
		end,
		function(v)
			lime.db.units.useClassColors = v
			Option:UpdateMember(updateColor)
			Option:UpdatePreview()
		end
	)
	menu.classColor:SetPoint("TOPRIGHT", -5, -5)
	menu.reset = LBO:CreateWidget("Button", parent, "색상 초기화", "설정한 색상을 초깃값으로 되돌립니다.", nil, nil, true,
		function()
			lime.db.colors.help[1], lime.db.colors.help[2], lime.db.colors.help[3] = 0, 1, 0
			lime.db.colors.harm[1], lime.db.colors.harm[2], lime.db.colors.harm[3] = 0.5, 0, 0
			lime.db.colors.vehicle[1], lime.db.colors.vehicle[2], lime.db.colors.vehicle[3] = 0, 0.4, 0
			lime.db.colors.offline[1], lime.db.colors.offline[2], lime.db.colors.offline[3] = 0.25, 0.25, 0.25
			for class, color in pairs(RAID_CLASS_COLORS) do
				if lime.db.colors[class] then
					lime.db.colors[class][1], lime.db.colors[class][2], lime.db.colors[class][3] = color.r, color.g, color.b
				end
			end
			Option:UpdateMember(updateColor)
			Option:UpdatePreview()
			LBO:Refresh(parent)
		end
	)
	menu.reset:SetPoint("TOP", menu.orientation, "BOTTOM", 0, -5)
	local colorList = { "help", "harm", "vehicle", "offline", "WARRIOR", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT", "MONK", "DEMONHUNTER" }
	local colorLocale = { "우호적 대상", "적대적 대상", "탈것 탑승 시", "오프라인일 때", "전사", "도적", "사제", "마법사", "흑마법사", "사냥꾼", "드루이드", "주술사", "성기사", "죽음의 기사", "수도사", "악마사냥꾼" }
	local function getColor(color)
		return lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3]
	end
	local function setColor(r, g, b, color)
		lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3] = r, g, b
		Option:UpdateMember(updateColor)
		Option:UpdatePreview()
	end
	for i, color in ipairs(colorList) do
		menu["color"..i] = LBO:CreateWidget("ColorPicker", parent, colorLocale[i], colorLocale[i].."의 색상을 변경합니다.", nil, nil, true, getColor, setColor, color)
		if i == 1 then
			menu["color"..i]:SetPoint("TOP", menu.reset, "BOTTOM", 0, 15)
		elseif i == 2 then
			menu["color"..i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color"..i]:SetPoint("TOP", menu["color"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
end

function Option:CreateManaBarMenu(menu, parent)
	local posList = { "상단", "하단", "좌측", "우측" }
	menu.pos = LBO:CreateWidget("DropDown", parent, "자원 바 위치", "자원 바의 위치를 설정합니다.", nil, nil, true,
		function()
			return lime.db.units.powerBarPos, posList
		end,
		function(v)
			lime.db.units.powerBarPos = v
			Option:UpdateMember(lime.headers[0].members[1].SetupPowerBar)
			Option:UpdatePreview()
		end
	)
	menu.pos:SetPoint("TOPLEFT", 5, -5)
	menu.height = LBO:CreateWidget("Slider", parent, "크기 비율", "자원 바의 크기 비율을 설정합니다. 0%로 설정하면 자원 바가 숨겨지며 100%로 설정하면 생명력 바가 숨겨집니다.", nil, nil, true,
		function()
			return lime.db.units.powerBarHeight * 100, 0, 100, 1, "%"
		end,
		function(v)
			lime.db.units.powerBarHeight = v / 100
			Option:UpdateMember(lime.headers[0].members[1].SetupPowerBar)
			Option:UpdatePreview()
		end
	)
	menu.height:SetPoint("TOPRIGHT", -5, -5)
	local colorList = { "MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER", "LUNAR_POWER", "INSANITY", "FURY", "PAIN", "MAELSTROM" }
	local function updateColor(member)
		if member:IsVisible() then
			limeMember_UpdatePowerColor(member)
		end
	end
	menu.reset = LBO:CreateWidget("Button", parent, "색상 초기화", "설정한 색상을 초깃값으로 되돌립니다.", nil, nil, true,
		function()
			for _, color in pairs(colorList) do
				lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3] = PowerBarColor[color].r, PowerBarColor[color].g, PowerBarColor[color].b
			end
			Option:UpdateMember(updateColor)
			Option:UpdatePreview()
			LBO:Refresh(parent)
		end
	)
	menu.reset:SetPoint("TOP", menu.pos, "BOTTOM", 0, -5)
	local function getColor(color)
		return lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3]
	end
	local function setColor(r, g, b, color)
		lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3] = r, g, b
		Option:UpdateMember(updateColor)
		Option:UpdatePreview()
	end
	for i, color in ipairs(colorList) do
		menu["color"..i] = LBO:CreateWidget("ColorPicker", parent, _G[color], _G[color].."의 색상을 변경합니다.", nil, nil, true, getColor, setColor, color)
		if i == 1 then
			menu["color"..i]:SetPoint("TOP", menu.reset, "BOTTOM", 0, 15)
		elseif i == 2 then
			menu["color"..i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color"..i]:SetPoint("TOP", menu["color"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
end

function Option:CreateNameMenu(menu, parent)
	local function updateFont(member)
		member.name:SetFont(SM:Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
		member.name:SetShadowColor(0, 0, 0)
		member.losttext:SetFont(SM:Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
		member.losttext:SetShadowColor(0, 0, 0)
		if lime.db.font.shadow then
			member.name:SetShadowOffset(1, -1)
			member.losttext:SetShadowOffset(1, -1)
		else
			member.name:SetShadowOffset(0, 0)
			member.losttext:SetShadowOffset(0, 0)
		end
		if member:IsVisible() then
			limeMember_UpdateName(member)
			limeMember_UpdateDisplayText(member)
			limeMember_SetAuraFont(member)
		end
	end
	menu.file = LBO:CreateWidget("Font", parent, "이름 글꼴 설정", "이름 글꼴을 변경합니다.", nil, nil, true,
		function()
			return lime.db.font.file, lime.db.font.size, lime.db.font.attribute, lime.db.font.shadow
		end,
		function(file, size, attribute, shadow)
			lime.db.font.file, lime.db.font.size, lime.db.font.attribute, lime.db.font.shadow = file, size, attribute, shadow
			lime:UpdateFont()
			lime:UpdateSpellTimerFont()
			Option:UpdateMember(updateFont)
			Option:UpdatePreview()
		end
	)
	menu.file:SetPoint("TOPLEFT", 5, -5)
	local function updateName(member)
		if member:IsVisible() then
			limeMember_UpdateNameColor(member)
		end
	end
	local function getClassColorName()
		return lime.db.units.className
	end
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "직업별 이름 색상 사용", "이름 색상을 직업 색상으로 표시합니다.", nil, nil, true,
		function() return lime.db.units.className end,
		function(v)
			lime.db.units.className = v
			Option:UpdateMember(updateName)
			Option:UpdatePreview()
			LBO:Refresh(parent)
		end
	)
	menu.classColor:SetPoint("TOP", menu.file, "BOTTOM", 0, -10)
	menu.color = LBO:CreateWidget("ColorPicker", parent, "이름 색상", "이름 색상을 설정합니다. 직업별 색상 사용시 적용되지 않습니다.", nil, nil, true,
		function()
			return lime.db.colors.name[1], lime.db.colors.name[2], lime.db.colors.name[3]
		end,
		function(r, g, b)
			lime.db.colors.name[1], lime.db.colors.name[2], lime.db.colors.name[3] = r, g, b
			Option:UpdateMember(updateName)
			Option:UpdatePreview()
		end
	)
	menu.color:SetPoint("TOPRIGHT", -5, -60)
	menu.outRangeName = LBO:CreateWidget("CheckBox", parent, "먼 사정거리 직업별 이름 색상 사용", "사정거리가 벗어난 플레이어의 이름 색상을 직업 색상으로 표시합니다.", nil, nil, true,
		function()
			return lime.db.units.outRangeName
		end,
		function(v)
			lime.db.units.outRangeName = v
			Option:UpdateMember(updateName)
			Option:UpdatePreview()
		end
	)
	menu.outRangeName:SetPoint("TOP", menu.classColor, "BOTTOM", 0, 0)
	menu.deathName = LBO:CreateWidget("CheckBox", parent, "죽은 플레이어 직업별 이름 색상 사용", "죽거나 유령인 플레이어의 이름 색상을 직업별 색상으로 표시합니다.", nil, nil, true,
		function()
			return lime.db.units.deathName
		end,
		function(v)
			lime.db.units.deathName = v
			Option:UpdateMember(updateName)
			Option:UpdatePreview()
		end
	)
	menu.deathName:SetPoint("TOP", menu.outRangeName, "BOTTOM", 0, 0)
	menu.offlineName = LBO:CreateWidget("CheckBox", parent, "오프라인 플레이어 직업별 이름 색상 사용", "오프라인된 플레이어의 이름 색상을 직업별 색상으로 표시합니다.", nil, nil, true,
		function()
			return lime.db.units.offlineName
		end,
		function(v)
			lime.db.units.offlineName = v
			Option:UpdateMember(updateName)
			Option:UpdatePreview()
		end
	)
	menu.offlineName:SetPoint("TOP", menu.deathName, "BOTTOM", 0, 0)
end

function Option:CreatePartyTagMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "파티 이름표 보기", "공격대 파티의 이름표를 표시합니다.", nil, nil, true,
		function() return lime.db.partyTag end,
		function(v)
			lime.db.partyTag = v
			lime:UpdateGroupFilter()
			LBO:Refresh(parent)
		end
	)
	local function disabled()
		return not lime.db.partyTag
	end
	menu.use:SetPoint("TOPLEFT", 5, 5)
	menu.myParty = LBO:CreateWidget("ColorPicker", parent, "내 파티 이름표 색상", "자기 자신이 속한 파티의 이름표 배경 색상을 설정합니다.", nil, disabled, true,
		function() return lime.db.partyTagParty[1], lime.db.partyTagParty[2], lime.db.partyTagParty[3], lime.db.partyTagParty[4] end,
		function(r, g, b, a)
			lime.db.partyTagParty[1], lime.db.partyTagParty[2], lime.db.partyTagParty[3], lime.db.partyTagParty[4] = r, g, b, a
			lime.headers[0].partyTag.tex:SetColorTexture(r, g, b, a);
			if lime.playerGroup then
				lime.headers[lime.playerGroup].partyTag.tex:SetColorTexture(r, g, b, a);
			end
			Option:UpdatePreview()
		end
	)
	menu.myParty:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.otherParty = LBO:CreateWidget("ColorPicker", parent, "파티 이름표 색상", "파티의 이름표 배경 색상을 설정합니다.", nil, disabled, true,
		function() return lime.db.partyTagRaid[1], lime.db.partyTagRaid[2], lime.db.partyTagRaid[3], lime.db.partyTagRaid[4] end,
		function(r, g, b, a)
			lime.db.partyTagRaid[1], lime.db.partyTagRaid[2], lime.db.partyTagRaid[3], lime.db.partyTagRaid[4] = r, g, b, a
			for i = 1, 8 do
				if i ~= lime.playerGroup then
					lime.headers[lime.playerGroup].partyTag.tex:SetColorTexture(r, g, b, a);
				end
			end
			Option:UpdatePreview()
		end
	)
	menu.otherParty:SetPoint("TOP", menu.myParty, "TOP", 0, 0)
	menu.otherParty:SetPoint("RIGHT", -5, 0)
end

function Option:CreateBorderMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "배경 테두리 보기", "공격대 창 전체를 둘러싸는 테두리를 보입니다.", nil, nil, true,
		function() return lime.db.border end,
		function(v)
			lime.db.border = v
			lime:BorderUpdate(true)
			LBO:Refresh(parent)
			if Option:GetPreviewState() > 1 then
				Option.preview:CallMethod("BorderUpdate")
			end
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local function disable()
		return not lime.db.border
	end
	local function updateColor()
		lime.border:SetBackdropColor(lime.db.borderBackdrop[1], lime.db.borderBackdrop[2], lime.db.borderBackdrop[3], lime.db.borderBackdrop[4])
		lime.border:SetBackdropBorderColor(lime.db.borderBackdropBorder[1], lime.db.borderBackdropBorder[2], lime.db.borderBackdropBorder[3], lime.db.borderBackdropBorder[4])
		if Option:GetPreviewState() > 1 then
			Option.preview.border:SetBackdropColor(lime.db.borderBackdrop[1], lime.db.borderBackdrop[2], lime.db.borderBackdrop[3], lime.db.borderBackdrop[4])
			Option.preview.border:SetBackdropBorderColor(lime.db.borderBackdropBorder[1], lime.db.borderBackdropBorder[2], lime.db.borderBackdropBorder[3], lime.db.borderBackdropBorder[4])
		end
	end
	menu.reset = LBO:CreateWidget("Button", parent, "색상 초기화", "설정한 색상을 초깃값으로 되돌립니다.", nil, disable, true,
		function()
			lime.db.borderBackdrop[1], lime.db.borderBackdrop[2], lime.db.borderBackdrop[3], lime.db.borderBackdrop[4] = 0, 0, 0, 0.58
			lime.db.borderBackdropBorder[1], lime.db.borderBackdropBorder[2], lime.db.borderBackdropBorder[3], lime.db.borderBackdropBorder[4] = 0.58, 0.58, 0.58, 1
			updateColor()
			LBO:Refresh(parent)
		end
	)
	menu.reset:SetPoint("TOPRIGHT", -5, 5)
	menu.backdrop = LBO:CreateWidget("ColorPicker", parent, "공격대 내부 테두리 색상", "공격대 창 내부 테두리의 색상 및 투명도를 조절합니다.", nil, disable, true,
		function()
			return lime.db.borderBackdrop[1], lime.db.borderBackdrop[2], lime.db.borderBackdrop[3], lime.db.borderBackdrop[4]
		end,
		function(r, g, b, a)
			lime.db.borderBackdrop[1], lime.db.borderBackdrop[2], lime.db.borderBackdrop[3], lime.db.borderBackdrop[4] = r, g, b, a
			updateColor()
		end
	)
	menu.backdrop:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.border = LBO:CreateWidget("ColorPicker", parent, "공격대 창 테두리 색상", "공격대 창 전체를 둘러싸는 테두리의 색상 및 투명도를 조절합니다.", nil, disable, true,
		function()
			return lime.db.borderBackdropBorder[1], lime.db.borderBackdropBorder[2], lime.db.borderBackdropBorder[3], lime.db.borderBackdropBorder[4]
		end,
		function(r, g, b, a)
			lime.db.borderBackdropBorder[1], lime.db.borderBackdropBorder[2], lime.db.borderBackdropBorder[3], lime.db.borderBackdropBorder[4] = r, g, b, a
			updateColor()
		end
	)
	menu.border:SetPoint("TOP", menu.reset, "BOTTOM", 0, 0)
end

function Option:CreateDebuffColorMenu(menu, parent)
	local function update(member)
		if member:IsVisible() then
			limeMember_UpdateAura(member)
			limeMember_UpdateState(member)
			limeMember_UpdateOutline(member)
		end
	end
	menu.reset = LBO:CreateWidget("Button", parent, "색상 초기화", "설정한 색상을 초깃값으로 되돌립니다.", nil, nil, true,
		function()
			lime.db.colors.Magic[1], lime.db.colors.Magic[2], lime.db.colors.Magic[3] = DebuffTypeColor.Magic.r, DebuffTypeColor.Magic.g, DebuffTypeColor.Magic.b
			lime.db.colors.Curse[1], lime.db.colors.Curse[2], lime.db.colors.Curse[3] = DebuffTypeColor.Curse.r, DebuffTypeColor.Curse.g, DebuffTypeColor.Curse.b
			lime.db.colors.Disease[1], lime.db.colors.Disease[2], lime.db.colors.Disease[3] = DebuffTypeColor.Disease.r, DebuffTypeColor.Disease.g, DebuffTypeColor.Disease.b
			lime.db.colors.Poison[1], lime.db.colors.Poison[2], lime.db.colors.Poison[3] = DebuffTypeColor.Poison.r, DebuffTypeColor.Poison.g, DebuffTypeColor.Poison.b
			lime.db.colors.none[1], lime.db.colors.none[2], lime.db.colors.none[3] = DebuffTypeColor.none.r, DebuffTypeColor.none.g, DebuffTypeColor.none.b
			Option:UpdateMember(update)
			LBO:Refresh(parent)
		end
	)
	menu.reset:SetPoint("TOPLEFT", 5, 2)
	local function getColor(color)
		return lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3]
	end
	local function setColor(r, g, b, color)
		lime.db.colors[color][1], lime.db.colors[color][2], lime.db.colors[color][3] = r, g, b
		Option:UpdateMember(update)
	end
	local colorList = { "Magic", "Curse", "Disease", "Poison", "none" }
	local colorLocale = { "마법", "저주", "질병", "독", "무속성" }
	for i, color in ipairs(colorList) do
		menu["color"..i] = LBO:CreateWidget("ColorPicker", parent, colorLocale[i], colorLocale[i].."약화 효과의 색상을 변경합니다.", nil, nil, true, getColor, setColor, color)
		if i == 1 then
			menu["color"..i]:SetPoint("TOP", menu.reset, "BOTTOM", 0, 15)
		elseif i == 2 then
			menu["color"..i]:SetPoint("TOP", menu.color1, 0, 0)
			menu["color"..i]:SetPoint("RIGHT", -5, 0)
		else
			menu["color"..i]:SetPoint("TOP", menu["color"..(i - 2)], "BOTTOM", 0, 14)
		end
	end
end