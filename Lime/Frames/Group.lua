-- 배열 초기화
local lime = _G[...]
lime.headers = {}
lime:Execute("HEADERS = newtable(); LIST = newtable();") 
lime:SetAttribute("state-group", "solo")
lime:SetAttribute("state-grouptype", "1")
lime:SetAttribute("state-combat", "no")

-- 감시 드라이버 작동 (솔플/파티/공격대 감시)
RegisterStateDriver(lime, "group", "[group:raid]raid;[group:party]party;solo")
RegisterStateDriver(lime, "grouptype", "[@raid36]8;[@raid31]7;[@raid26]6;[@raid21]5;[@raid16]4;[@raid11]3;[@raid6]2;1")

-- 감시 드라이버 작동 (전투 중인지 감시)
RegisterStateDriver(lime, "combat", "[combat]yes;no")

-- 전역 변수 초기화
local _G = _G
local select = _G.select

-- 그룹 배열 스크립트 초기화
for i = 0, 8 do
	lime.headers[i] = CreateFrame("Frame", lime:GetName().."Group"..i, lime, "limeGroupHeaderTemplate")
	lime:SetFrameRef("header", lime.headers[i])
	lime:Execute("HEADERS["..i.."] = self:GetFrameRef('header')")
	lime.headers[i].index = i
	lime.headers[i].visible = 0
	lime.headers[i].members = {}
	lime.headers[i]:SetAttribute("groupindex", i)
	lime.headers[i]:Show()
	lime.headers[i]:SetAttribute("startingIndex", 1)
	lime.headers[i]:Hide()
	lime.headers[i].partyTag:SetParent(lime.headers[i].members[1])
	lime.headers[i].partyTag:RegisterForDrag("LeftButton", "RightButton")
	lime.headers[i]:SetScript("OnHide", limeMember_OnDragStop)
end
lime:Hide()
-- 속성 변경 시 후킹
lime:HookScript("OnAttributeChanged", lime.StopMovingOrSizing)
-- 상속 프레임 속성 지정 
lime:SetAttribute("_childupdate-clearunit", "self:ChildUpdate(scriptid, message)")
-- 그룹 배열 스크립트
lime:SetAttribute("_onattributechanged", [=[
	if name == "state-combat" and value == "yes" and self:GetAttribute("preview") then
		self:SetAttribute("preview", nil)
	elseif name == "preview" then
		if value then
			self:Hide()
		else
			self:SetAttribute("startupdate", nil)
			self:SetAttribute("startupdate", true)
		end
	elseif not self:GetAttribute("ready") or self:GetAttribute("preview") then
		return
	elseif name == "state-group" or (name == "startupdate" and value) or (name == "state-grouptype" and self:GetAttribute("groupby") == "CLASS") or name == "run" then
		self:Hide()
		self:SetAttribute("startupdate", nil)
		local use = self:GetAttribute("use")
		local group = self:GetAttribute("state-group")
		if not self:GetAttribute("run") or use == 0 or (use > 1 and group == "solo") or (use > 2 and group == "party") then
			return self:ChildUpdate("clearunit")
		end
		local width = self:GetAttribute("width")
		local height = self:GetAttribute("height")
		local offset = self:GetAttribute("offset")
		local groupby = self:GetAttribute("groupby")
		local anchor = self:GetAttribute("anchor")
		local dir = self:GetAttribute("dir")
		local groupfilter = self:GetAttribute("groupfilter")
		local grouptype = tonumber(self:GetAttribute("state-grouptype"))
		local column = self:GetAttribute("column")
		local sortname = self:GetAttribute("sortname")
		self:SetWidth(width)
		self:SetHeight(height)
		local xOffset, yOffset = 0, 0
		if dir == 1 then
			yOffset = offset
			if anchor:find("TOP") then
				yOffset = -yOffset
			end
		elseif anchor:find("LEFT") then
			xOffset = offset
		else
			xOffset = -offset
		end
		local index
		local count = 0
		for i = 0, 8 do
			HEADERS[i]:Hide()
			HEADERS[i]:ChildUpdate("clearunit")
			if group == "raid" then
				if i > 0 then
					index = i..""
					if groupby == "GROUP" then
						if groupfilter:find(index) then
							HEADERS[i]:SetAttribute("showRaid", true)
							HEADERS[i]:SetAttribute("xOffset", xOffset)
							HEADERS[i]:SetAttribute("yOffset", yOffset)
							HEADERS[i]:SetAttribute("groupBy", groupby)
							HEADERS[i]:SetAttribute("groupFilter", index)
							HEADERS[i]:SetAttribute("groupingOrder", index)
							HEADERS[i]:SetAttribute("startingIndex", 1)
							HEADERS[i]:SetAttribute("sortMethod", sortname and "NAME" or "INDEX")
							HEADERS[i]:ChildUpdate("width", width)
							HEADERS[i]:ChildUpdate("height", height)
							HEADERS[i]:Show()
						end
					elseif i <= grouptype then
						HEADERS[i]:SetAttribute("showRaid", true)
						HEADERS[i]:SetAttribute("xOffset", xOffset)
						HEADERS[i]:SetAttribute("yOffset", yOffset)
						HEADERS[i]:SetAttribute("groupBy", groupby)
						HEADERS[i]:SetAttribute("groupFilter", groupfilter)
						HEADERS[i]:SetAttribute("groupingOrder", groupfilter)
						HEADERS[i]:SetAttribute("startingIndex", (i - 1) * 5 + 1)
						HEADERS[i]:SetAttribute("sortMethod", sortname and "NAME" or "INDEX")
						HEADERS[i]:ChildUpdate("width", width)
						HEADERS[i]:ChildUpdate("height", height)
						HEADERS[i]:Show()
					end
				end
			elseif i == 0 and (group == "party" or self:GetAttribute("use") == 1) then
				HEADERS[i]:SetAttribute("showPlayer", true)
				HEADERS[i]:SetAttribute("showParty", true)
				HEADERS[i]:SetAttribute("showSolo", true)
				HEADERS[i]:SetAttribute("xOffset", xOffset)
				HEADERS[i]:SetAttribute("yOffset", yOffset)
				HEADERS[i]:SetAttribute("groupBy", groupby)
				HEADERS[i]:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
				HEADERS[i]:SetAttribute("groupingOrder", "1,2,3,4,5,6,7,8")
				HEADERS[i]:SetAttribute("sortMethod", "INDEX")
				HEADERS[i]:ChildUpdate("width", width)
				HEADERS[i]:ChildUpdate("height", height)
				HEADERS[i]:Show()
			end
			if HEADERS[i]:IsShown() then
				count = count + 1
				HEADERS[i]:ChildUpdate("clearallpoints")
				if dir == 1 then
					HEADERS[i]:SetAttribute("point", anchor:find("TOP") and "TOP" or "BOTTOM")
				else
					HEADERS[i]:SetAttribute("point", anchor:find("LEFT") and "LEFT" or "RIGHT")
				end
			end
		end
		self:CallMethod("SetupAll")
		self:Show()
		self:SetAttribute("updateposition", not self:GetAttribute("updateposition"))
	elseif name == "updateposition" then
		local offsetx = self:GetAttribute("offset")
		local offsety = offsetx
		local tag = self:GetAttribute("partytag")
		local column = self:GetAttribute("column")
		local anchor = self:GetAttribute("anchor")
		local width = self:GetAttribute("width")
		local height = self:GetAttribute("height")
		local tagx, tagy = 0, 0
		if self:GetAttribute("dir") == 1 then
			tagy = tag
			width = width + offsetx
			height = (height + offsety) * 5 + tag
		else
			tagx = tag
			width = (width + offsetx) * 5 + tag
			height = height + offsety
		end
		if HEADERS[0]:IsShown() then
			HEADERS[0]:ClearAllPoints()
			HEADERS[0]:SetPoint(anchor, self, anchor, anchor:find("RIGHT") and -tagx or tagx, anchor:find("TOP") and -tagy or tagy)
		else
			for i = 1, 8 do
				if HEADERS[i]:IsShown() then
					HEADERS[i]:ClearAllPoints()
					tinsert(LIST, HEADERS[i])
				end
			end
			if #LIST > 0 then
				if self:GetAttribute("groupby") == "GROUP" then
					for i = 1, #LIST do
						for j = 1, #LIST do
							if i ~= j then
								if self:GetAttribute("grouporder"..LIST[i]:GetAttribute("groupindex")) < self:GetAttribute("grouporder"..LIST[j]:GetAttribute("groupindex")) then
									LIST[i], LIST[j] = LIST[j], LIST[i]
								end
							end
						end
					end
				else
					tag = 0
				end
				local w, h = 0, 0
				if anchor == "TOPLEFT" then
					LIST[1]:SetPoint("TOPLEFT", self, "TOPLEFT", tagx, -tagy)
					for i = 2, #LIST do
						if column == 1 or i % column == 1 then
							w, h = 0, h - height
						else
							w = w + width
						end
						LIST[i]:SetPoint("TOPLEFT", LIST[1], "TOPLEFT", w, h)
					end
				elseif anchor == "TOPRIGHT" then
					LIST[1]:SetPoint("TOPRIGHT", self, "TOPRIGHT", -tagx, -tagy)
					for i = 2, #LIST do
						if column == 1 or i % column == 1 then
							w, h = 0, h - height
						else
							w = w - width
						end
						LIST[i]:SetPoint("TOPRIGHT", LIST[1], "TOPRIGHT", w, h)
					end
				elseif anchor == "BOTTOMLEFT" then
					LIST[1]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", tagx, tagy)
					for i = 2, #LIST do
						if column == 1 or i % column == 1 then
							w, h = 0, h + height
						else
							w = w + width
						end
						LIST[i]:SetPoint("BOTTOMLEFT", LIST[1], "BOTTOMLEFT", w, h)
					end
				elseif anchor == "BOTTOMRIGHT" then
					LIST[1]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -tagx, tagy)
					for i = 2, #LIST do
						if column == 1 or i % column == 1 then
							w, h = 0, h + height
						else
							w = w - width
						end
						LIST[i]:SetPoint("BOTTOMRIGHT", LIST[1], "BOTTOMRIGHT", w, h)
					end
				end
				wipe(LIST)
			end
		end
		self:CallMethod("BorderUpdate", true)
	end
]=])