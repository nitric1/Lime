local _G = _G
local GetTime = _G.GetTime
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local lime = _G[...]
-- [[8.0PH]] local GetSpellSubtext = _G.GetSpellSubtext

function limeMember_SetupCastingBarPos(self)
	if lime.db.units.castingBarPos == 1 then
		self.castingBar:SetPoint("TOPLEFT", 0, 0)
		self.castingBar:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -lime.db.units.castingBarHeight)
		self.castingBar:SetOrientation("HORIZONTAL")
	elseif lime.db.units.castingBarPos == 2 then
		self.castingBar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, lime.db.units.castingBarHeight)
		self.castingBar:SetPoint("BOTTOMRIGHT", 0, 0)
		self.castingBar:SetOrientation("HORIZONTAL")
	elseif lime.db.units.castingBarPos == 3 then
		self.castingBar:SetPoint("TOPLEFT", 0, 0)
		self.castingBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", lime.db.units.castingBarHeight, 0)
		self.castingBar:SetOrientation("VERTICAL")
	elseif lime.db.units.castingBarPos == 4 then
		self.castingBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -lime.db.units.castingBarHeight, 0)
		self.castingBar:SetPoint("BOTTOMRIGHT", 0, 0)
		self.castingBar:SetOrientation("VERTICAL")
	else
		self.castingBar:Hide()
	end
end

function limeMember_CastingBarOnUpdate(self)
	self:SetValue(self.isChannel and (self.endTime - GetTime() + self.startTime) or GetTime())
end

function limeMember_UpdateCastingBar(self)
	if lime.db.units.useCastingBar then
		self.castingBar.startTime, self.castingBar.endTime = select(4, UnitCastingInfo(self.displayedUnit))
		if self.castingBar.startTime then
			self.castingBar.startTime, self.castingBar.endTime, self.castingBar.isChannel = self.castingBar.startTime / 1000, self.castingBar.endTime / 1000
			self.castingBar:SetMinMaxValues(self.castingBar.startTime, self.castingBar.endTime)
			if not self.castingBar.ticker then
				self.castingBar.ticker = C_Timer.NewTicker(0.04, function() limeMember_CastingBarOnUpdate(self.castingBar) end)
			end
			limeMember_CastingBarOnUpdate(self.castingBar)
			return self.castingBar:Show()
		else
			self.castingBar.startTime, self.castingBar.endTime = select(4, UnitChannelInfo(self.displayedUnit))
			if self.castingBar.startTime then
				self.castingBar.startTime, self.castingBar.endTime, self.castingBar.isChannel = self.castingBar.startTime / 1000, self.castingBar.endTime / 1000, true
				self.castingBar:SetMinMaxValues(self.castingBar.startTime, self.castingBar.endTime)
				if not self.castingBar.ticker then
					self.castingBar.ticker = C_Timer.NewTicker(0.04, function() limeMember_CastingBarOnUpdate(self.castingBar) end)
				end
				limeMember_CastingBarOnUpdate(self.castingBar)
				return self.castingBar:Show()
			end
		end
	end
	if self.castingBar.ticker then -- 정상적인 캐스팅 완료 시
		self.castingBar.ticker:Cancel()
		self.castingBar.ticker = nil
	end
	self.castingBar.startTime, self.castingBar.endTime, self.castingBar.isChannel = nil
	self.castingBar:Hide()
end
