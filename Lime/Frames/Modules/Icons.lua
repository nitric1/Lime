local _G = _G
local pairs = _G.pairs
local ipairs = _G.ipairs
local ceil = _G.math.ceil
local sort = _G.table.sort
local twipe = _G.table.wipe
local tinsert = _G.table.insert
local lime = _G[...]

local iconTable = { TOPLEFT = {}, TOP = {}, TOPRIGHT = {}, LEFT = {}, CENTER = {}, RIGHT = {}, BOTTOMLEFT = {}, BOTTOM = {}, BOTTOMRIGHT = {} }
local relPoint = { TOPLEFT = "TOPRIGHT", TOPRIGHT = "TOPLEFT", LEFT = "RIGHT", RIGHT = "LEFT", BOTTOMLEFT = "BOTTOMRIGHT", BOTTOMRIGHT = "BOTTOMLEFT" }
local iconOrder = {
	--bossAura = 0,
	roleIcon = 1,
	leaderIcon = 2,
	raidIcon1 = 3,
	raidIcon2 = 4,
	debuffIcon1 = 5,
	debuffIcon2 = 6,
	debuffIcon3 = 7,
	debuffIcon4 = 8,
	debuffIcon5 = 9,
}
local centerIndex

local posTableDefault = {
	bossAura = { "bossAuraPos", "CENTER" },
	roleIcon = { "roleIconPos", "TOPLEFT" },
	leaderIcon = { "leaderIconPos", "TOPLEFT" },
	raidIcon1 = { "raidIconPos", "TOPLEFT" },
	healIcon = { "healIconPos", "BOTTOMLEFT" },
	debuffIcon1 = { "debuffIconPos", "TOPRIGHT" },
}
posTableDefault.raidIcon2 = posTableDefault.raidIcon1
posTableDefault.debuffIcon2 = posTableDefault.debuffIcon1
posTableDefault.debuffIcon3 = posTableDefault.debuffIcon1
posTableDefault.debuffIcon4 = posTableDefault.debuffIcon1
posTableDefault.debuffIcon5 = posTableDefault.debuffIcon1

local function addIcon(self, icon, pos)
	if self[icon] then
		self[icon]:ClearAllPoints()
		if not pos or not iconTable[pos] then
			if posTableDefault[icon] then
				self.optionTable[posTableDefault[icon][1]] =  posTableDefault[icon][2]
				pos = posTableDefault[icon][2]
			else
				pos = "CENTER"
			end
		end
		if iconOrder[icon] then
			tinsert(iconTable[pos], icon)
		else
			self[icon]:SetPoint(pos, 0, 0)
		end
	end
end

local function sortIcon(a, b)
	if iconOrder[a] and iconOrder[b] then
		if iconOrder[a] == iconOrder[b] then
			return a < b
		else
			return iconOrder[a] < iconOrder[b]
		end
	elseif iconOrder[a] then
		return true
	elseif iconOrder[b] then
		return false
	else
		return a < b
	end
end

local function fixPoint(point)
	if point == "CENTERLEFT" then
		return "LEFT"
	elseif point == "CENTERRIGHT" then
		return "RIGHT"
	else
		return point
	end
end

local function debug(self, ...)
	if self == lime.headers[0].members[1] then
		print(...)
	end
end

function limeMember_SetupIconPos(self)
	addIcon(self, "bossAura", self.optionTable.bossAuraPos)
	addIcon(self, "roleIcon", self.optionTable.roleIconPos)
	addIcon(self, "leaderIcon", self.optionTable.leaderIconPos)
	addIcon(self, "raidIcon1", self.optionTable.raidIconPos)
	addIcon(self, "raidIcon2", self.optionTable.raidIconPos)
	addIcon(self, "healIcon", self.optionTable.healIconPos)
	addIcon(self, "debuffIcon1", self.optionTable.debuffIconPos)
	addIcon(self, "debuffIcon2", self.optionTable.debuffIconPos)
	addIcon(self, "debuffIcon3", self.optionTable.debuffIconPos)
	addIcon(self, "debuffIcon4", self.optionTable.debuffIconPos)
	addIcon(self, "debuffIcon5", self.optionTable.debuffIconPos)
	for i = 1, 4 do
		addIcon(self, "spellTimer"..i, limeCharDB.spellTimer[i].pos)
	end
	for pos, tbl in pairs(iconTable) do
		if #tbl == 0 then
			-- noting
		elseif #tbl == 1 then
			self[tbl[1]]:SetPoint(pos, 0, 0)
		elseif relPoint[pos] then
			for i, icon in ipairs(tbl) do
				if i == 1 then
					self[icon]:SetPoint(pos, 0, 0)
				else
					self[icon]:SetPoint(pos, self[tbl[i - 1]], relPoint[pos], 0, 0)
				end
			end
		elseif #tbl % 2 == 0 then
			centerIndex = #tbl / 2
			sort(tbl, sortIcon)
			for i, icon in ipairs(tbl) do
				if i == centerIndex then
					self[icon]:SetPoint(fixPoint(pos.."RIGHT"), self, pos, 0, 0)
				elseif i == (centerIndex + 1) then
					self[icon]:SetPoint(fixPoint(pos.."LEFT"), self, pos, 0, 0)
				elseif i < centerIndex then
					self[icon]:SetPoint(fixPoint(pos.."RIGHT"), self[tbl[i + 1]], fixPoint(pos.."LEFT"), 0, 0)
				else
					self[icon]:SetPoint(fixPoint(pos.."LEFT"), self[tbl[i - 1]], fixPoint(pos.."RIGHT"), 0, 0)
				end
			end
		else
			centerIndex = ceil(#tbl / 2)
			sort(tbl, sortIcon)
			for i, icon in ipairs(tbl) do
				if i < centerIndex then
					self[icon]:SetPoint(fixPoint(pos.."RIGHT"), self[tbl[i + 1]], fixPoint(pos.."LEFT"), 0, 0)
				elseif i > centerIndex then
					self[icon]:SetPoint(fixPoint(pos.."LEFT"), self[tbl[i - 1]], fixPoint(pos.."RIGHT"), 0, 0)
				else
					self[icon]:SetPoint(pos, 0, 0)
				end
			end
		end
		twipe(tbl)
	end
end