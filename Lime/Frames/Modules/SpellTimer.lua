local _G = _G
local lime = _G[...]
local ipairs = _G.ipairs
local UnitAura = _G.UnitAura
local usedIndex = {}
local indexSpellInfo = {}
local delimiter = ","
local numberFont = lime:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
local numberFontWidth = {}
local SL = lime.GetSpellName
local blockSpellID = {}

function lime:UpdateSpellTimerFont()
	for _, header in pairs(lime.headers) do
		for _, member in pairs(header.members) do
			for i = 1, 8 do
				local frame = member["spellTimer"..i]
				frame.count:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
				frame.count:SetShadowColor(0, 0, 0)
				frame.count:SetShadowOffset(1, -1)
				frame.timer:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
				frame.timer:SetShadowColor(0, 0, 0)
				frame.timer:SetShadowOffset(1, -1)
				frame:SetScale(limeCharDB.spellTimer[i].scale)
			end
		end
	end
	for i = 1, 5 do
		numberFont:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", lime.db.font.file), lime.db.font.size, lime.db.font.attribute)
		numberFont:SetText(strrep("0", i))
		numberFont:SetShadowColor(0, 0, 0)
		numberFont:SetShadowOffset(1, -1)
		numberFontWidth[i] = ceil(numberFont:GetWidth()) + 1
	end
end

local function onUpdateIconTimer(self, opt)
	if opt == 4 or opt == 5 then
		self.timeLeft = GetTime() - self.startTime
	else
		self.timeLeft = self.expirationTime - GetTime()
	end
	if self.timeLeft > 100 then
		if self.noIcon then
			self.timer:SetText("●")
		else
			self.timer:SetText("")
		end
	else
		self.timer:SetFormattedText("%d", self.timeLeft + 0.5)
	end
	self:SetWidth((numberFontWidth[(self.timer:GetText() or ""):len()] or 0) + (self.noIcon and 0 or 13))
end

local function setIcon(self, index, duration, expirationTime, icon, count)
	if self and index then
		if limeCharDB.spellTimer[index].display == 1 then
			-- 아이콘 + 남은 시간
			self.noIcon = nil
			self.noLeft = nil
			self.icon:SetWidth(13)
			self.icon:SetTexture(icon)
			self.count:SetText(count and count > 1 and count or "")
		elseif limeCharDB.spellTimer[index].display == 2 then
			-- 아이콘
			self.noIcon = nil
			self:SetWidth(13)
			self.icon:SetWidth(13)
			self.icon:SetTexture(icon)
			self.count:SetText(count and count > 1 and count or "")
			duration = nil
		elseif limeCharDB.spellTimer[index].display == 3 then
			-- 남은 시간
			self.noIcon = true
			self.icon:SetWidth(0.001)
			self.icon:SetTexture(nil)
			self.count:SetText(nil)
		elseif limeCharDB.spellTimer[index].display == 4 then
			-- 아이콘 + 경과 시간
			self.noIcon = nil
			self.icon:SetWidth(13)
			self.icon:SetTexture(icon)
			self.count:SetText(count and count > 1 and count or "")
		else
			-- 경과 시간
			self.noIcon = true
			self.noLeft = true
			self.icon:SetWidth(0.001)
			self.icon:SetTexture(nil)
			self.count:SetText(nil)
		end
		if duration and duration > 0 and expirationTime then
			self.startTime = expirationTime - duration
			self.expirationTime = expirationTime
			if not self.spellticker then
				self.spellticker = C_Timer.NewTicker(0.5, function() onUpdateIconTimer(self, limeCharDB.spellTimer[index].display) end)
			end
			onUpdateIconTimer(self, limeCharDB.spellTimer[index].display)
		else
			if self.spellticker then --정상적으로 주문 타이머 만료 시 타이머 삭제
				self.spellticker:Cancel()
				self.spellticker = nil
			end
			self.expirationTime, self.timeLeft = nil, nil
			if self.noIcon then
				self.timer:SetText("●")
			else
				self.timer:SetText("")
			end
		end
		self:Show()
	elseif self and self:IsShown() then
		if self.spellticker then
			self.spellticker:Cancel()
			self.spellticker = nil
		end
		self.expirationTime, self.timeLeft, self.noIcon = nil
		self:Hide()
	end
end

function limeMember_UpdateSpellTimer(self)
	for _, index in ipairs(usedIndex) do
		local found
		for _, spell in ipairs(indexSpellInfo[index]) do
			local spellname = spell[1]
			local filter = spell[2]
			local filterNum = spell[3]
			local spellId = tonumber(spellname)
			if type(spellId) == "number" then
				-- 주문 ID로 표시 (권장)
				for i = 1, 40 do
					local name2, icon2, count2, _, duration2, expirationTime2, _, _, _, spellId2 = UnitAura(self.displayedUnit, i, filter)
					if name2 and spellId2 == spellId then
						found = true
						setIcon(self["spellTimer"..index], index, duration2, expirationTime2, icon2, count2)
						break
					end
				end
			end
		end
		if not found then
			setIcon(self["spellTimer"..index])
		end
	end
end

local pos = { "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", "LEFT", "RIGHT", "TOPLEFT", "TOP", "TOPRIGHT" }
local filter = { "HELPFUL PLAYER", "HARMFUL PLAYER", "HELPFUL", "HARMFUL" }
local SL = lime.GetSpellName

function lime:BuildSpellTimerList()
	table.wipe(usedIndex)
	table.wipe(indexSpellInfo)
	for i = 1, 8 do
		if filter[limeCharDB.spellTimer[i].use] and limeCharDB.spellTimer[i].name then
			table.insert(usedIndex, i)
			local spells = {}
			spells[1], spells[2], spells[3], spells[4], spells[5] = delimiter:split(limeCharDB.spellTimer[i].name)
			indexSpellInfo[i] = {}
			for _, spell in ipairs(spells) do
				local info = {spell:trim(), filter[limeCharDB.spellTimer[i].use], limeCharDB.spellTimer[i].use}
				table.insert(indexSpellInfo[i], info)
			end
		end
	end
end

function lime:SetupSpellTimer(reset)
	if not reset and limeCharDB.spellTimer and #limeCharDB.spellTimer == 8 then return end
	limeCharDB.spellTimer = limeCharDB.spellTimer or {}
	for i = 1, 8 do
		limeCharDB.spellTimer[i] = limeCharDB.spellTimer[i] or {}
		limeCharDB.spellTimer[i].use = 0		-- 1:내가 시전한 버프 2:내가 시전한 디버프 3:모든 버프 4:모든 디버프 0:사용 안함
		limeCharDB.spellTimer[i].display = 1	-- 1:아이콘 + 남은 시간 2:아이콘 3:남은 시간 4:아이콘 + 경과 시간 5:경과 시간
		limeCharDB.spellTimer[i].scale = 1
		limeCharDB.spellTimer[i].pos = pos[i]
	end
	if self.playerClass == "ROGUE" then
		limeCharDB.spellTimer[1].use = 1
		limeCharDB.spellTimer[1].name = "57934"	-- 속임수 거래
	elseif self.playerClass == "PRIEST" then
		limeCharDB.spellTimer[1].use = 1
		limeCharDB.spellTimer[1].name = "139"	-- 소생 (8.0 Legit)
		limeCharDB.spellTimer[1].pos = "BOTTOMLEFT"
		limeCharDB.spellTimer[2].use = 1
		limeCharDB.spellTimer[2].name = "41635"	-- 회복의 기원 (8.0 Legit)
		limeCharDB.spellTimer[2].pos = "BOTTOMRIGHT"
		limeCharDB.spellTimer[3].use = 1
		limeCharDB.spellTimer[3].name = "194384"-- 속죄 (8.0 Legit)
		limeCharDB.spellTimer[3].pos = "BOTTOMRIGHT"
		limeCharDB.spellTimer[4].use = 1
		limeCharDB.spellTimer[4].name = "17"	-- 신의 권능: 보호막 (8.0 Legit)
		limeCharDB.spellTimer[4].pos = "BOTTOMLEFT"
	elseif self.playerClass == "HUNTER" then
		limeCharDB.spellTimer[1].use = 1
		limeCharDB.spellTimer[1].name = "34477"	-- 눈속임
	elseif self.playerClass == "DRUID" then
		limeCharDB.spellTimer[1].use = 1
		limeCharDB.spellTimer[1].name = "33763"	-- 피어나는 생명 (8.0 Legit)
		limeCharDB.spellTimer[1].pos = "BOTTOMLEFT"
		limeCharDB.spellTimer[2].use = 1
		limeCharDB.spellTimer[2].name = "774"	-- 회복 (8.0 Legit)
		limeCharDB.spellTimer[2].pos = "BOTTOMRIGHT"
		limeCharDB.spellTimer[3].use = 0
		limeCharDB.spellTimer[3].name = "8936"	-- 재생 (8.0 Legit)
		limeCharDB.spellTimer[4].use = 0
		limeCharDB.spellTimer[4].name = "48438"	-- 급속 성장 (8.0 Legit)
		limeCharDB.spellTimer[5].use = 1
		limeCharDB.spellTimer[5].name = "155777"	-- 회복 (싹틔우기) (8.0 Legit)
		limeCharDB.spellTimer[5].pos = "BOTTOM"
	elseif self.playerClass == "SHAMAN" then
		limeCharDB.spellTimer[1].use = 1
		limeCharDB.spellTimer[1].name = "61295"	-- 성난 해일 (8.0 Legit)
		limeCharDB.spellTimer[1].pos = "BOTTOMLEFT"
		limeCharDB.spellTimer[2].use = 1
		limeCharDB.spellTimer[2].name = "974"	-- 대지의 보호막 (8.0 Legit)
		limeCharDB.spellTimer[2].pos = "BOTTOMRIGHT"
	elseif self.playerClass == "PALADIN" then
		limeCharDB.spellTimer[1].use = 3
		limeCharDB.spellTimer[1].name = "53563"..",".."156910"	-- 빛의 봉화, 신념의 봉화 (8.0 Legit)
		limeCharDB.spellTimer[1].pos = "BOTTOMLEFT"
		limeCharDB.spellTimer[2].use = 1
		limeCharDB.spellTimer[2].name = "1022"..",".."1044"..",".."6940"..",".."1038"	-- 보호의 손길, 자유의 손길, 희생의 손길, 구원의 손길 (8.0 Legit)
		limeCharDB.spellTimer[2].pos = "BOTTOMRIGHT"
	elseif self.playerClass == "MONK" then
		limeCharDB.spellTimer[1].use = 1
		limeCharDB.spellTimer[1].name = "124682"	-- 포용의 안개 (8.0 Legit)
		limeCharDB.spellTimer[1].pos = "BOTTOMLEFT"
		limeCharDB.spellTimer[2].use = 1
		limeCharDB.spellTimer[2].name = "119611"	-- 소생의 안개 (8.0 Legit)
		limeCharDB.spellTimer[2].pos = "BOTTOMRIGHT"
		limeCharDB.spellTimer[3].use = 1
		limeCharDB.spellTimer[3].name = "191840"	-- 정수의 샘 (8.0 Legit)
		limeCharDB.spellTimer[3].pos = "BOTTOM"
	end
end
