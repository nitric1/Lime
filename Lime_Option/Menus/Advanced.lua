local lime = lime
local Option = lime.optionFrame
local LBO = LibStub("LibLimeOption-1.0")

function Option:CreateAdvancedMenu(menu, parent)
	self.CreateAdvancedMenu = nil
	
	menu.cwarning = LBO:CreateWidget("CheckBox", parent, "호환성 경고 메시지 표시", "호환성에 문제가 있는 애드온이 감지되면 경고 메시지를 표시합니다.", nil, nil, true,
		function() return lime.db.cwarning end,
		function(v)
			lime.db.cwarning = v
		end
	)
	menu.cwarning:SetPoint("TOPLEFT", 5, -5)

	menu.cflag = LBO:CreateWidget("CheckBox", parent, "정상 작동 여부", "체크가 되어 있다면 정상적으로 애드온을 사용할 수 있습니다.", nil, true, true,
		function() return lime.db.cflag end,
		function(v)
			lime.db.cflag = v
		end
	)
	menu.cflag:SetPoint("TOPRIGHT", 5, -5)

	menu.globaltimer = LBO:CreateWidget("Slider", parent, "타이머", "레이드 프레임을 반복적으로 새로 고치는 주기입니다. 주기를 수정하려면 LUA를 직접 편집해야 합니다.", nil, true, nil,
		function() return lime.db.globaltimer, 0, 1, 0.1, "초" end,
		function(v)
		end
	)
	menu.globaltimer:SetPoint("TOP", menu.cwarning, "BOTTOM", 0, -10)

	menu.vflag = LBO:CreateWidget("CheckBox", parent, "탑승물 추적 여부", "탑승물 추적 여부를 수정하려면 LUA를 직접 편집해야 합니다.", nil, true, true,
		function() return lime.db.vflag end,
		function(v)
		end
	)
	menu.vflag:SetPoint("TOP", menu.cflag, "BOTTOM", 0, -10)

	menu.cpass = LBO:CreateWidget("CheckBox", parent, "모든 경고 무시", "호환성 경고를 무시하고 제한된 기능을 강제로 작동하도록 합니다. 이 기능은 상당히 위험한 기능이오니, 해당 기능을 잘 모른다면 체크를 하지 마세요.", nil, nil, true,
		function() return lime.db.cpass end,
		function(v)
			lime.db.cpass = v
		end

	)
	menu.cpass:SetPoint("TOP", menu.globaltimer, "BOTTOM", 0, -10)

	menu.advanced = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	menu.advanced:SetText("아군 이름표를 표시하면 Lime의 툴팁 표시 기능이 비활성화됩니다.\n\n모든 경고를 무시하도록 설정하면 툴팁 기능을 다시 사용할 수 있으나\n심각한 충돌이 발생할 가능성이 높습니다.")
	menu.advanced:SetPoint("TOP", 5, -160)
	menu.advanced:SetJustifyH("LEFT")
end