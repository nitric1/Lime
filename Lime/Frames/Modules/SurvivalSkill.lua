
local L = LibStub("AceLocale-3.0"):GetLocale("Lime")

local _G = _G
local pairs = _G.pairs
local GetTime = _G.GetTime
local lime = _G[...]

local classskills = {
	["DEATHKNIGHT"] = {
	[48792] = L["lime_survival_얼인"], 
	[55233] = L["lime_survival_흡혈"], 
	[81256] = L["lime_survival_춤룬"], 
	[48707] = L["lime_survival_대보"], 
	[194679] = L["lime_survival_룬전"] 
	},

	["DEMONHUNTER"] = {
	[187827] = L["lime_survival_탈태"], 
	[196555] = L["lime_survival_황천"], 
	[198589] = L["lime_survival_흐릿"]
	},

	["DRUID"] = {
	[61336] = L["lime_survival_생본"], 
	[22812] = L["lime_survival_껍질"] 
	},

	["HUNTER"] = {
	[5384] = L["lime_survival_죽척"], 
	[199483] = L["lime_survival_위장"], 
	[186265] = L["lime_survival_거북"]
	},

	["MAGE"] = { 
	[45438] = L["lime_survival_얼방"], 
	[32612] = L["lime_survival_투명"], 
	[110960] = L["lime_survival_상투"]
	},

	["MONK"] = { 
	[115203] = L["lime_survival_강화"], -- 양조
	[122783] = L["lime_survival_마해"], 
	[122470] = L["lime_survival_업보"], 
	[213664] = L["lime_survival_민활"], 
	[243435]= L["lime_survival_강화"], -- 운무
	[201318] = L["lime_survival_강화"], -- 풍운 명예 특성
	[122278] = L["lime_survival_해악"] 
	},

	["PALADIN"] = { 
	[642] = L["lime_survival_무적"], 
	[498] = L["lime_survival_가호"], 
	[31850] = L["lime_survival_헌수"], 
	[86659] = L["lime_survival_고대"], 
	[31821] = L["lime_survival_오숙"], 
	[205191] = L["lime_survival_눈"] 
	},

	["PRIEST"] = { 
	[27827] = L["lime_survival_구원"], 
	[47585] = L["lime_survival_분산"], 
	[15286] = L["lime_survival_흡선"], 
	[586] = L["lime_survival_소실"], 
	[64901] = L["lime_survival_희망"] 
	},

	["ROGUE"] = { 
	[5277] = L["lime_survival_회피"], 
	[31224] = L["lime_survival_그망"], 
	[11327] = L["lime_survival_소멸"], 
	[199754] = L["lime_survival_반격"] 
	},

	["SHAMAN"] = { 
	[108271] = L["lime_survival_영혼"], 
	[108281] = L["lime_survival_고인"], 
	[210918] = L["lime_survival_에테"] 
	},

	["WARLOCK"] = { 
	[104773] = L["lime_survival_결의"] 
	},

	["WARRIOR"] = { 
	[871] = L["lime_survival_방벽"], 
	[12975] = L["lime_survival_최저"], 
	[118038] = L["lime_survival_투혼"], 
	[23920] = L["lime_survival_주반"], 
	[184364]  = L["lime_survival_격재"], 
	[227744] = L["lime_survival_쇠날"]},
}

-- 타인에게 걸 수 있는 생존기
local commonskills = {
	[1022]  = L["lime_survival_보축"], 
	[47788]  = L["lime_survival_수호"], 
	[33206] = L["lime_survival_고억"], 
	[6940] = L["lime_survival_희축"], 
	[102342] = L["lime_survival_무껍"], 
	[116849] = L["lime_survival_고치"], 
	[29166] = L["lime_survival_자극"], 
	[228049] = L["lime_survival_여왕"], 
	[204018] = L["lime_survival_주축"],
}

-- 물약
local potion = {
	[279152] = L["lime_survival_민첩"], 
	[279153] = L["lime_survival_힘"], 
	[279154] = L["lime_survival_체력"], 
	[279151] = L["lime_survival_지능"], 
	[269853] = L["lime_survival_죽음"], 
	[251231] = L["lime_survival_방어도"], 
	[251316] = L["lime_survival_피"], 
	[252753] = L["lime_survival_마나"], 
	[229206] = L["lime_survival_힘"] 	-- 군단 물약
}

-- 준 생존기
local semiskills = {
	[203720] = L["lime_survival_쐐기"],	--악사
	[1966] = L["lime_survival_교란"],	--도적 
	[185311] = L["lime_survival_약병"]	--도적
}

local ignoreEndTime = { 
	[5384] = true
}

ignoreEndTime[""] = nil

local function findSkill(unit, lookup)
	for i = 1, 40 do 
		local name, _, _, _, _, endTime, _, _, _, spellId = UnitBuff(unit, i)
		for key, val in pairs(lookup) do
			if spellId == key then
				return val, (not ignoreEndTime[spell] and endTime and endTime > 0) and endTime
			end
		end 
	end
	return nil
end

local function checkSkill(unit, class)
	-- 타인에게 걸 수 있는 생존기 체크 및 표시 우선 순위 조정
	local spellId, endTime = findSkill(unit, commonskills)	-- 우선 순위 1등 (외생기)
	if not spellId and classskills[class] then  				-- 우선 순위 2등 (본인 생존기)
		spellId, endTime = findSkill(unit, classskills[class])
	end
	if not spellId and semiskills and lime.db.units.showSurvivalSkillSub then 	--우선 순위 3등 (준 생존기)
		spellId, endTime = findSkill(unit, semiskills)
	end
	if not spellId and potion and lime.db.units.showSurvivalSkillPotion then --우선 순위 4등 (물약류)
		spellId, endTime = findSkill(unit, potion)
	end
	return spellId, endTime
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
			self.survivalticker = C_Timer.NewTicker(0.5, function() survivalSkillOnUpdate(self) end)  -- 개인 생존기 타이머. CPU 부하에 상당히 관여합니다.
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