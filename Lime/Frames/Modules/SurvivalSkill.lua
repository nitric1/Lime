
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")
local LimeAura = LibStub:GetLibrary("LibAuras")

local _G = _G
local pairs = _G.pairs
local GetTime = _G.GetTime
local lime = _G[...]

-- 직업별 생존기 정의 (*는 타인에게 걸 수 있는 생존기)
local SL = lime.GetSpellName
local skills = {
	["DEATHKNIGHT"] = { [SL(48792)] = L["lime_survival_얼인"], [SL(55233)] = L["lime_survival_흡혈"], [SL(81256)] = L["lime_survival_춤룬"], [SL(48707)] = L["lime_survival_대보"], [SL(194679)] = L["lime_survival_룬전"] },
	["DEMONHUNTER"] = { [SL(187827)] = L["lime_survival_탈태"], [SL(196555)] = L["lime_survival_황천"], [SL(198589)] = L["lime_survival_흐릿"] },
	["DRUID"] = { [SL(61336)] = L["lime_survival_생본"], [SL(22812)] = L["lime_survival_껍질"] },
	["HUNTER"] = { [SL(5384)] = L["lime_survival_죽척"], [SL(199483)] = L["lime_survival_위장"], [SL(186265)] = L["lime_survival_거북"] },
	["MAGE"] = { [SL(45438)] = L["lime_survival_얼방"], [SL(32612)] = L["lime_survival_투명"], [SL(110960)] = L["lime_survival_상투"] },
	["MONK"] = { [SL(115203)] = L["lime_survival_강화"]--[[양조]], [SL(122783)] = L["lime_survival_마해"], [SL(122470)] = L["lime_survival_업보"], [SL(213664)] = L["lime_survival_민활"], [SL(243435)] = L["lime_survival_강화"]--[[운무]], [SL(201318)] = L["lime_survival_강화"]--[[풍운 명예]], [SL(122278)] = L["lime_survival_해악"] },
	["PALADIN"] = { [SL(642)] = L["lime_survival_무적"], [SL(498)] = L["lime_survival_가호"], [SL(31850)] = L["lime_survival_헌수"], [SL(86659)] = L["lime_survival_고대"], [SL(31821)] = L["lime_survival_오숙"], [SL(205191)] = L["lime_survival_눈"] },
	["PRIEST"] = { [SL(27827)] = L["lime_survival_구원"], [SL(47585)] = L["lime_survival_분산"], [SL(15286)] = L["lime_survival_흡선"], [SL(586)] = L["lime_survival_소실"], [SL(64901)] = L["lime_survival_희망"] },
	["ROGUE"] = { [SL(5277)] = L["lime_survival_회피"], [SL(31224)] = L["lime_survival_그망"], [SL(11327)] = L["lime_survival_소멸"], [SL(199754)] = L["lime_survival_반격"] }, 
	["SHAMAN"] = { [SL(108271)] = L["lime_survival_영혼"], [SL(108281)] = L["lime_survival_고인"], [SL(210918)] = L["lime_survival_에테"] },
	["WARLOCK"] = { [SL(104773)] = L["lime_survival_결의"},
	["WARRIOR"] = { [SL(871)] = L["lime_survival_방벽"], [SL(12975)] = L["lime_survival_최저"], [SL(118038)] = L["lime_survival_투혼"], [SL(23920)] = L["lime_survival_주반"], [SL(184364)] = L["lime_survival_격재"], [SL(227744)] = L["lime_survival_쇠날"] },
	["*"] = { [SL(1022)] = L["lime_survival_보축"], [SL(47788)] = L["lime_survival_수호"], [SL(33206)] = L["lime_survival_고억"], [SL(6940)] = L["lime_survival_희축"], [SL(102342)] = L["lime_survival_무껍"], [SL(116849)] = L["lime_survival_고치"], [SL(29166)] = L["lime_survival_자극"], [SL(228049)] = L["lime_survival_여왕"], [SL(204018)] = L["lime_survival_주축"] },
	["POTION"] = {[SL(279152)] = L["lime_survival_민첩"], [SL(279153)] = L["lime_survival_힘"], [SL(279154)] = L["lime_survival_체력"], [SL(279151)] = L["lime_survival_지능"], [SL(269853)] = L["lime_survival_죽음"], [SL(251231)] = L["lime_survival_방어도"], [SL(251316)] = L["lime_survival_피"], [SL(252753)] = L["lime_survival_마나"] },
	["SEMI"] = { [SL(203720)] = L["lime_survival_쐐기"]--[[악사]], [SL(1966)] = L["lime_survival_교란"]--[[도적]], [SL(185311)] = L["lime_survival_약병"]--[[도적]] }
}
local checkSpellID = {
}
local ignoreEndTime = { [SL(5384)] = true }
for _, v in pairs(skills) do
	v[""] = nil
end
ignoreEndTime[""] = nil
checkSpellID[""] = nil

local function findSkill(unit, lookup)
	for spell, newText in pairs(lookup) do
		local name, _, _, _, _, endTime, _, _, _, spellId = LimeAura:UnitBuff(unit, spell)
		if name then
			if checkSpellID[name] then
				if checkSpellID[name] == spellId then
					return newText, (not ignoreEndTime[spell] and endTime and endTime > 0) and endTime
				end
			else
				return newText, (not ignoreEndTime[spell] and endTime and endTime > 0) and endTime
			end
		end
	end
	return nil
end

local function checkSkill(unit, class)
	-- 타인에게 걸 수 있는 생존기 체크 및 표시 우선 순위 조정
	local name, endTime = findSkill(unit, skills["*"])	-- 우선 순위 1등 (외생기) 
	if not name and skills[class] then  				-- 우선 순위 2등 (본인 생존기)
		name, endTime = findSkill(unit, skills[class])
	end
	if not name and skills["SEMI"] and lime.db.units.showSurvivalSkillSub then 	--우선 순위 3등 (준생존기)
		name, endTime = findSkill(unit, skills["SEMI"])
	end
	if not name and skills["POTION"] and lime.db.units.showSurvivalSkillPotion then --우선 순위 4등 (물약류)
		name, endTime = findSkill(unit, skills["POTION"])
	end
	return name, endTime
end

local function survivalSkillOnUpdate(self)
	if self.survivalSkillEndTime then
		self.survivalSkillTimeLeft = (":%d"):format(self.survivalSkillEndTime - GetTime() + 0.5)
	end
	limeMember_UpdateLostHealth(self) --이름 프레임 업데이트
end

function limeMember_UpdateSurvivalSkill(self)
	if lime.db.units.useSurvivalSkill then
		self.survivalSkill, self.survivalSkillEndTime = checkSkill(self.displayedUnit, self.class)
		self.survivalSkillTimeLeft = self.survivalSkillEndTime and (self.survivalSkillEndTime - GetTime()) or ""
		if not self.survivalticker then
			self.survivalticker = C_Timer.NewTicker(1.0, function() survivalSkillOnUpdate(self) end)
		end
		survivalSkillOnUpdate(self)
	else
		if self.survivalticker then
			self.survivalticker:Cancel()
			self.survivalticker = nil
		end
		self.survivalSkill, self.survivalSkillEndTime, self.survivalSkillTimeLeft = nil, nil, nil
	end
	limeMember_UpdateLostHealth(self) --이름 프레임 업데이트
end