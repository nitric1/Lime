
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local _G = _G
local pairs = _G.pairs
local GetTime = _G.GetTime
local UnitBuff = _G.UnitBuff
local lime = _G[...]
-- [[8.0PH]] local GetSpellSubtext = _G.GetSpellSubtext


-- 직업별 생존기 정의 (*는 타인에게 걸 수 있는 생존기)
local SL = lime.GetSpellName
local skills = {	-- 7.2.5
	["WARRIOR"] = { [SL(871)] = L["방벽"], [SL(12975)] = L["최저"], [SL(125565)] = L["사기"], [SL(118038)] = L["투혼"], [SL(23920)] = L["주반"], [SL(184364)] = L["격재"], [SL(203524)] = L["넬타"] },
	["ROGUE"] = { [SL(5277)] = L["회피"], [SL(31224)] = L["그망"], [SL(1966)] = L["교란"], [SL(11327)] = L["소멸"], [SL(199754)] = L["반격"] }, 
	["PALADIN"] = { [SL(642)] = L["무적"], [SL(498)] = L["가호"], [SL(31850)] = L["헌수"], [SL(86659)] = L["고대"], [SL(31821)] = L["오라"], [SL(205191)] = L["눈"] },
	["MAGE"] = { [SL(45438)] = L["얼방"], [SL(32612)] = L["투명"], [SL(110960)] = L["상투"] },
	["HUNTER"] = { [SL(5384)] = L["죽척"], [SL(199483)] = L["위장"], [SL(186265)] = L["거북"] },
	["PRIEST"] = { [SL(27827)] = L["구원"], [SL(47585)] = L["분산"], [SL(15286)] = L["흡선"], [SL(586)] = L["소실"] },
	["DRUID"] = { [SL(61336)] = L["생본"], [SL(22812)] = L["껍질"], [SL(200851)] = L["분노"] },
	["DEATHKNIGHT"] = { [SL(48792)] = L["얼인"], [SL(55233)] = L["흡혈"], [SL(81256)] = L["춤룬"], [SL(48707)] = L["대보"], [SL(194679)] = L["룬전"], [SL(212552)] = L["망령"], [SL(207319)] = L["시체"] },
	["SHAMAN"] = { [SL(108271)] = L["영혼"], [SL(108281)] = L["고인"], [SL(210918)] = L["에테"] },
	["WARLOCK"] = { [SL(104773)] = L["결의"], [SL(108416)] = L["서약"] },
	["MONK"] = { [SL(115203)] = L["강화"], [SL(122783)] = L["마해"], [SL(122278)] = L["해악"], [SL(122470)] = L["업보"], [SL(213664)] = L["민활"], [SL(243435)] = L["강화"], [SL(201318)] = L["강화"] },
	["DEMONHUNTER"] = { [SL(187827)] = L["탈태"], [SL(218256)] = L["강화"], [SL(196555)] = L["황천"], [SL(198589)] = L["흐릿"] },
	["*"] = { [SL(1022)] = L["보축"], [SL(47788)] = L["수호"], [SL(33206)] = L["고억"], [SL(6940)] = L["희축"], [SL(102342)] = L["무껍"], [SL(116849)] = L["고치"], [SL(29166)] = L["자극"], [SL(228049)] = L["여왕"], [SL(204018)] = L["주축"] },
	["POTION"] = { [SL(229206)] = L["힘"], [SL(188029)] = L["방어도"], [SL(188027)] = L["은총"], [SL(188028)] = L["전쟁"] },
	["SEMI"] = { [SL(203720)] = L["쐐기"] }
--[[8.0PH
	["DEATHKNIGHT"] = { [SL(48792)] = "얼인", [SL(55233)] = "흡혈", [SL(81256)] = "춤룬", [SL(48707)] = "대보", [SL(194679)] = "룬전", [SL(212552)] = "망령" },
	["DEMONHUNTER"] = { [SL(187827)] = "탈태", [SL(218256)] = "강화", [SL(196555)] = "황천", [SL(198589)] = "흐릿" },
	["DRUID"] = { [SL(61336)] = "생본", [SL(22812)] = "껍질", [SL(200851)] = "분노" },
	["HUNTER"] = { [SL(5384)] = "죽척", [SL(199483)] = "위장", [SL(186265)] = "거북" },
	["MAGE"] = { [SL(45438)] = "얼방", [SL(32612)] = "투명", [SL(110960)] = "상투" },
	["MONK"] = { [SL(115203)] = "강화", [SL(122783)] = "마해", [SL(122470)] = "업보", [SL(213664)] = "민활", [SL(243435)] = "강화", [SL(201318)] = "강화"},
	["PALADIN"] = { [SL(642)] = "무적", [SL(498)] = "가호", [SL(31850)] = "헌수", [SL(86659)] = "고대", [SL(31821)] = "오라", [SL(205191)] = "눈" },
	["PRIEST"] = { [SL(19286)] = "기도" [SL(27827)] = "구원", [SL(47585)] = "분산", [SL(15286)] = "흡선", [SL(586)] = "소실" },
	["ROGUE"] = { [SL(5277)] = "회피", [SL(31224)] = "그망", [SL(1966)] = "교란", [SL(11327)] = "소멸", [SL(199754)] = "반격" }, 
	["SHAMAN"] = { [SL(108271)] = "영혼", [SL(108281)] = "고인", [SL(210918)] = "에테" },
	["WARLOCK"] = { [SL(104773)] = "결의", [SL(108416)] = "서약" },
	["WARRIOR"] = { [SL(871)] = "방벽", [SL(12975)] = "최저", [SL(118038)] = "투혼", [SL(23920)] = "주반", [SL(184364)] = "격재", [SL(203524)] = "넬타" },
	["*"] = { [SL(1022)] = "보축", [SL(47788)] = "수호", [SL(33206)] = "고억", [SL(6940)] = "희축", [SL(102342)] = "무껍", [SL(116849)] = "고치", [SL(29166)] = "자극", [SL(228049)] = "여왕", [SL(204018)] = "주축" },
	["POTION"] = { },
	["SEMI"] = { [SL(203720)] = "쐐기" }
]]

}
local checkSpellID = {
}
local ignoreEndTime = { [SL(5384)] = true, [SL(122278)] = true }
for _, v in pairs(skills) do
	v[""] = nil
end
ignoreEndTime[""] = nil
checkSpellID[""] = nil

local function findSkill(unit, lookup)
	for spell, newText in pairs(lookup) do
		local name, _, _, _, _, _, endTime, _, _, _, spellId = UnitBuff(unit, spell)
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
			self.survivalticker = C_Timer.NewTicker(0.5, function() survivalSkillOnUpdate(self) end)
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