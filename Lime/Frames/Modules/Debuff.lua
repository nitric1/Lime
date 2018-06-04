
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local _G = _G
local lime = _G[...]
local GetTime = _G.GetTime
local UnitBuff = _G.UnitBuff
local UnitDebuff = _G.UnitDebuff
local PlaySoundFile = _G.PlaySoundFile
local SM = LibStub("LibSharedMedia-3.0")
local LRD = LibStub("LibLimeDispel-1.0")
-- [[8.0PH]] local GetSpellSubtext = _G.GetSpellSubtext

local ignoreAuraId = {}
local ignoreAuraName = {}
local bossAuraId = {}
local bossAuraName = {}
local dispelTypes = { Magic = "Magic", Curse = "Curse", Disease = "Disease", Poison = "Poison" }
local lastTime =  0

local function hideIcon(icon)
	if icon then
		icon:SetSize(0.001, 0.001)
		icon:Hide()
		if lime.db.cflag == true or lime.db.cpass == true then
			if GameTooltip:IsOwned(icon) then
				GameTooltip:Hide()
			end
		end
	end
end

local function bossAuraOnUpdate(self, opt)
	if opt == 1 then
		if (self.endTime - GetTime()) > 2.5 then
		self.timerParent.text:SetFormattedText("%d", self.endTime - GetTime() + 0.5)
		else
			self.timerParent.text:SetFormattedText("|cffff0000%.1f|r", self.endTime - GetTime() + 0.5)
		end
	elseif opt == 2 then
		self.timerParent.text:SetFormattedText("%d", GetTime() - self.startTime)
	else
		self.timerParent.text:SetText("")
	end
end

function lime:BuildAuraList()
	table.wipe(ignoreAuraId)
	table.wipe(ignoreAuraName)
	table.wipe(bossAuraId)
	table.wipe(bossAuraName)
	for spellid in pairs(lime.ignoreAura) do
		if lime.db.ignoreAura[spellid] ~= false then
			ignoreAuraId[spellid] = true
		end
	end
	for spell, v in pairs(lime.db.ignoreAura) do
		if v == true then
			if type(spell) == "number" then
				ignoreAuraId[spell] = true
			else
				ignoreAuraName[spell] = true
			end
		end
	end
	for spellid2 in pairs(lime.bossAura) do
		if (lime.db.userAura[spellid2] ~= false) and not ignoreAuraId[spellid2] then
			bossAuraId[spellid2] = true
		end
	end
	for spell2, v in pairs(lime.db.userAura) do
		if (v == true) and not ignoreAuraId[spell2] and not ignoreAuraName[spell2] then
			if type(spell2) == "number" then
				bossAuraId[spell2] = true
			else
				bossAuraName[spell2] = true
			end
		end
	end
end

function limeMember_SetAuraFont(self)
	self.bossAura.count:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", lime.db.font.file), lime.db.font.size, "THINOUTLINE")
	self.bossAura.count:SetShadowColor(0, 0, 0)
	self.bossAura.count:SetShadowOffset(1, -1)
	self.bossAura.timerParent.text:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", lime.db.font.file), lime.db.font.size, "THINOUTLINE")
	self.bossAura.timerParent.text:SetShadowColor(0, 0, 0)
	self.bossAura.timerParent.text:SetShadowOffset(1, -1)
	for i = 1, 5 do
		local debuffIcon = self["debuffIcon"..i]
		debuffIcon.count:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", lime.db.font.file), lime.db.font.size, "THINOUTLINE")
		debuffIcon.count:SetShadowColor(0, 0, 0)
		debuffIcon.count:SetShadowOffset(1, -1)
	end
end

function limeMember_UpdateAura(self)
	self.numDebuffIcons = 0
	local baIndex, baIsBuff, baIcon, baCount, baDuration, baExpirationTime
	local dispelable, dispelType
	for i = 1, 40 do
		local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossAura = UnitDebuff(self.displayedUnit, i)
		-- 약화 효과 체크
		if name then
			if not ignoreAuraId[spellId] and not ignoreAuraName[name] then
				debuffType = dispelTypes[debuffType] or "none"
				if isBossAura and not bossAuraId[spellId] and not bossAuraName[name] and lime.db.userAura[spellId] ~= false and lime.db.userAura[name] ~= false then
					lime.db.userAura[spellId] = true
					bossAuraId[spellId] = true
					lime:Message("|cffff6600"..name.."|r"..L["Lime_register_BossAura"]) 
				end
				if self.optionTable.useBossAura and (not baIndex or bsIsBuff) and (bossAuraId[spellId] or bossAuraName[name]) then--약화 효과는 항상 강화 효과에 우선합니다.
					-- 중요 효과 내용 임시 테이블에 저장
					baIndex = i
					baIsBuff = false
					baIcon = icon
					baCount = count
					baDuration = duration
					baExpirationTime = expirationTime
				elseif self.optionTable.debuffIconFilter[debuffType] and self.optionTable.debuffIcon > self.numDebuffIcons then
					-- 약화 효과 아이콘
					self.numDebuffIcons = self.numDebuffIcons + 1
					local debuffIcon = self["debuffIcon"..self.numDebuffIcons]
					if debuffIcon then
						debuffIcon:SetSize(self.optionTable.debuffIconSize, self.optionTable.debuffIconSize)
						debuffIcon:SetID(i)
						if lime.db.colors[debuffType] then
							debuffIcon.color:SetColorTexture(lime.db.colors[debuffType][1], lime.db.colors[debuffType][2], lime.db.colors[debuffType][3])
						else
							debuffIcon.color:SetColorTexture(0, 0, 0)
						end
						debuffIcon.icon:SetTexture(icon)
						debuffIcon.count:SetText(count and count > 1 and count or nil)
						debuffIcon:Show()
					end
				end
				if not dispelable and LRD:CheckHelpDispel(debuffType) then
					dispelable = true
					dispelType = debuffType
				end
			end
		end
		-- 강화 효과 체크
		local nameB, _, iconB, countB, _, durationB, expirationTimeB, _, _, _, spellIdB, _, isBossAuraB = UnitBuff(self.displayedUnit, i)
		if isBossAuraB and self.optionTable.useBossAura and not ignoreAuraId[spellIdB] and not ignoreAuraName[nameB] and not baIndex then--보스효과로 지정된 경우만 체크합니다. (cpu 사용량 문제)
			if isBossAuraB and not bossAuraId[spellIdB] and not bossAuraName[nameB] and lime.db.userAura[spellIdB] ~= false and lime.db.userAura[nameB] ~= false then
				lime.db.userAura[spellIdB] = true
				bossAuraId[spellIdB] = true
				lime:Message("|cffff6600"..nameB.."|r"..L["Lime_register_BossAura"]) 
			end
			if bossAuraId[spellIdB] or bossAuraName[nameB] then
				-- 중요 효과 내용 임시 테이블에 저장
				baIndex = i
				baIsBuff = true
				baIcon = iconB
				baCount = countB
				baDuration = durationB
				baExpirationTime = expirationTimeB
			end
		end
		if not name and not nameB then
			break
		end
	end
	if baIndex then
		-- 중요 효과 표시
		self.bossAura:SetSize(self.optionTable.bossAuraSize, self.optionTable.bossAuraSize)
		self.bossAura.icon:SetTexture(baIcon)
		self.bossAura.count:SetText(baCount and baCount > 1 and baCount or nil)
		self.bossAura:SetID(baIndex)
		if self.optionTable.bossAuraTimer and baDuration and (baDuration > 0) then
			self.bossAura.cooldown:SetCooldown(baExpirationTime - baDuration, baDuration)
			self.bossAura.cooldown:Show()
		else
			self.bossAura.cooldown:Hide()
		end
		self.bossAura:Show()
		if baDuration and baDuration > 0 and baExpirationTime then
			self.bossAura.endTime = baExpirationTime
			self.bossAura.startTime = baExpirationTime - baDuration
			if not self.bossAura.ticker then
				self.bossAura.ticker = C_Timer.NewTicker(0.5, function() bossAuraOnUpdate(self.bossAura, self.optionTable.bossAuraOpt) end)
			end
			bossAuraOnUpdate(self.bossAura, self.optionTable.bossAuraOpt)
		else
			if self.bossAura.ticker then
				self.bossAura.ticker:Cancel()
				self.bossAura.ticker = nil
			end
			self.bossAura.timerParent.text:SetText(nil)
		end
	else
		hideIcon(self.bossAura)
	end
	for i = self.numDebuffIcons + 1, 5 do
		hideIcon(self["debuffIcon"..i])
	end
	if dispelable then
		self.dispelType = dispelType
		if self.optionTable.dispelSound ~= "None" then
			if GetTime() > lastTime then
				lastTime = GetTime() + self.optionTable.dispelSoundDelay
				PlaySoundFile(SM:Fetch("sound", self.optionTable.dispelSound))
			end
		end
	else
		self.dispelType = nil
	end
end

function limeMember_BossAuraOnLoad(self)
	self.cooldown.noOCC = true
	self.cooldown.noCooldownCount = true
	self.cooldown:SetHideCountdownNumbers(true)
end

local tooltipUpdate = 0
function limeMember_AuraIconOnUpdate(self, elapsed)
	if lime.db.cflag == true or lime.db.cpass == true then
		if not lime.tootipState then return end
		tooltipUpdate = tooltipUpdate + elapsed
		if tooltipUpdate > 0.1 then
			tooltipUpdate = 0
			if self:IsMouseOver() then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
				GameTooltip:SetUnitDebuff(self:GetParent().displayedUnit, self:GetID())
			elseif GameTooltip:IsOwned(self) then
				GameTooltip:Hide()
			end
		end
	end
end

lime.ignoreAura = {
	[6788] = true, [8326] = true, [11196] = true, [15822] = true, [21163] = true,
	[24360] = true, [24755] = true, [25771] = true, [26004] = true, [26013] = true,
	[26680] = true, [28169] = true, [28504] = true, [29232] = true, [30108] = true,
	[30529] = true, [36032] = true, [36893] = true, [36900] = true, [36901] = true,
	[40880] = true, [40882] = true, [40883] = true, [40891] = true, [40896] = true,
	[40897] = true, [41292] = true, [41337] = true, [41350] = true, [41425] = true,
	[43681] = true, [55711] = true, [57723] = true, [57724] = true, [64805] = true,
	[64808] = true, [64809] = true, [64810] = true, [64811] = true, [64812] = true,
	[64813] = true, [64814] = true, [64815] = true, [64816] = true, [69127] = true,
	[69438] = true, [70402] = true, [71328] = true, [72144] = true, [72145] = true,
	[80354] = true, [89798] = true, [96328] = true, [96325] = true,
	[96326] = true, [95809] = true, [36895] = true, [71041] = true, [122835] = true,
	[173660] = true, [173649] = true, [173657] = true, [173658] = true, [173976] = true,
	[173661] = true, [174524] = true, [173659] = true,
	[160455] = true, -- Fatigued
	[206151] = true, -- 도전자의 짐(쐐기 신화)
	[234143] = true, -- 무너지는 미래의 반지
}

lime.bossAura = {
------------------------ 8.0 PH



------------------------ WoW Legion Debuff
[106872] = true, [107268] = true, [111600] = true, [118961] = true, [145206] = true,
[153795] = true, [155721] = true, [160029] = true, [185093] = true, [192048] = true, 
[192706] = true, [193069] = true, [193367] = true, [193783] = true, [194327] = true,
[196068] = true, [197943] = true, [198006] = true, [198190] = true, [199063] = true,
[201146] = true, [203096] = true, [203770] = true, [203774] = true, [204463] = true,
[204517] = true, [204531] = true, [204611] = true, [204859] = true, [204895] = true,
[204962] = true, [205201] = true, [205344] = true, [205649] = true, [205771] = true,
[205984] = true, [206384] = true, [206480] = true, [206617] = true, [206651] = true,
[206798] = true, [206936] = true, [208431] = true, [208929] = true, [209011] = true,
[209158] = true, [209244] = true, [209598] = true, [209615] = true, [209973] = true,
[210315] = true, [210863] = true, [210879] = true, [211471] = true, [211802] = true,
[211939] = true, [212568] = true, [214167] = true, [214335] = true, [215449] = true,
[216040] = true, [217093] = true, [218304] = true, [218342] = true, [218350] = true,
[218368] = true, [218809] = true, [219024] = true, [219025] = true, [219602] = true,
[219610] = true, [219812] = true, [219964] = true, [219965] = true, [219966] = true,
[221028] = true, [221246] = true, [221344] = true, [221606] = true, [221891] = true,
[222178] = true, [222719] = true, [223511] = true, [223655] = true, [224188] = true,
[225080] = true, [225105] = true, [227832] = true, [228029] = true, [228054] = true,
[228248] = true, [228249] = true, [228253] = true, [228270] = true, [228280] = true,
[228331] = true, [228883] = true, [228918] = true, [229159] = true, [230139] = true,
[230201] = true, [230362] = true, [231363] = true, [231729] = true, [231998] = true,
[232249] = true, [233272] = true, [233568] = true, [233570] = true, [233963] = true,
[233983] = true, [234114] = true, [235117] = true, [235222] = true, [236283] = true,
[236459] = true, [236494] = true, [236519] = true, [236550] = true, [236596] = true,
[236710] = true, [238018] = true, [238598] = true, [239264] = true, [239739] = true,
[240447] = true, [240706] = true, [240735] = true, [243299] = true, [245509] = true,

--- 중앙인님 7.3 패치에 포함된 디버프
--- http://www.inven.co.kr/board/powerbbs.php?come_idx=1636&l=29890
[145263] = true, [228794] = true, [205429] = true, [228810] = true, [216344] = true,
[206847] = true, [228811] = true, [216345] = true, [217046] = true, [228835] = true,
[228796] = true, [237590] = true, [243624] = true, [205445] = true, [214670] = true,
[223350] = true, [228818] = true, [228744] = true, [206458] = true, [240746] = true,
[240209] = true, [243536] = true, [206506] = true, [243276] = true,

--- 7.3.2
[246677] = true,

--- 7.3.5 안토러스 공격대 찾기 
[254122] = true, [244892] = true, [244768] = true, [244410] = true,
[252797] = true, [247641] = true, [245586] = true, [246220] = true,
[253600] = true, [246687] = true, [244536] = true, [252621] = true,
[245770] = true, [257196] = true, [244172] = true,

--- 7.3.5 안토러스 일반 
[243961] = true, [244613] = true, [250669] = true, [251570] = true, [248396] = true, 
[255029] = true,

--- 7.3.5 안토러스 영웅 
[244086] = true, [244094] = true, [254429] = true, [245075] = true,	[245118] = true,
}