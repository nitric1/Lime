local lime = lime
local Option = lime.optionFrame
local LBO = LibStub("LibLimeOption-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

function Option:CreateAdvancedMenu(menu, parent)
	self.CreateAdvancedMenu = nil

	menu.cwarning = LBO:CreateWidget("CheckBox", parent, L["lime_advanced_01"], L["lime_advanced_desc_01"], nil, nil, true,
		function() return lime.db.cwarning end,
		function(v)
			lime.db.cwarning = v
		end
	)
	menu.cwarning:SetPoint("TOPLEFT", 5, -5)

	menu.cflag = LBO:CreateWidget("CheckBox", parent, L["lime_advanced_02"], L["lime_advanced_desc_02"], nil, true, true,
		function() return lime.db.cflag end,
		function(v)
			lime.db.cflag = v
		end
	)
	menu.cflag:SetPoint("TOPRIGHT", 5, -5)

	menu.globaltimer = LBO:CreateWidget("Slider", parent, L["lime_advanced_03"], L["lime_advanced_desc_03"], nil, true, nil,
		function() return lime.db.globaltimer, 0, 1, 0.1, L["초"] end,
		function(v)
		end
	)
	menu.globaltimer:SetPoint("TOP", menu.cwarning, "BOTTOM", 0, -10)

	menu.vflag = LBO:CreateWidget("CheckBox", parent, L["lime_advanced_04"], L["lime_advanced_desc_04"], nil, true, true,
		function() return lime.db.vflag end,
		function(v)
		end
	)
	menu.vflag:SetPoint("TOP", menu.cflag, "BOTTOM", 0, -10)

	menu.cpass = LBO:CreateWidget("CheckBox", parent, L["lime_advanced_05"], L["lime_advanced_desc_05"], nil, nil, true,
		function() return lime.db.cpass end,
		function(v)
			lime.db.cpass = v
		end

	)
	menu.cpass:SetPoint("TOP", menu.globaltimer, "BOTTOM", 0, -10)

	menu.advanced = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	menu.advanced:SetText(L["lime_advanced_06"])
	menu.advanced:SetPoint("TOP", 3, -150)
	menu.advanced:SetSize(380, 50)
	menu.advanced:SetJustifyV("TOP")
	menu.advanced:SetJustifyH("LEFT")

	menu.lockmasterkey = LBO:CreateWidget("CheckBox", parent, L["lime_advanced_07"], L["lime_advanced_desc_07"], nil, nil, true,
		function() return lime.db.lockmasterkey end,
		function(v)
			lime.db.lockmasterkey = v
		end
	)
	menu.lockmasterkey:SetPoint("TOP", menu.cpass, "BOTTOM", 0, -50)
end