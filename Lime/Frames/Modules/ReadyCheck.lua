local _G = _G
local GetReadyCheckStatus = _G.GetReadyCheckStatus
local lime = _G[...]

local GetReadyCheckTimeLeft = _G.GetReadyCheckTimeLeft
local readyCheckFrame = CreateFrame("Frame")
local timer = 0

readyCheckFrame:SetScript("OnEvent", function(self, event)
	if event == "READY_CHECK_FINISHED" then
		if readyCheckFrame.anim then
			readyCheckFrame.anim:Cancel()
			readyCheckFrame.anim = nil
		end
		if readyCheckFrame.animrun then
			readyCheckFrame.animrun:Cancel()
			readyCheckFrame.animrun = nil
		end
		readyCheckFrame.animrun = C_Timer.After(2.5, function() lime_ReadyCheckFinishAnim(true) end)
	else
		lime_ReadyCheckHide()
	end
end)
readyCheckFrame:RegisterEvent("READY_CHECK_FINISHED")
readyCheckFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function lime_ReadyCheckHide()
	lime.doReadyCheck = nil
	if readyCheckFrame.anim then
		readyCheckFrame.anim:Cancel()
		readyCheckFrame.anim = nil
	end
	if readyCheckFrame.animrun then
		readyCheckFrame.animrun:Cancel()
		readyCheckFrame.animrun = nil
	end
	for _, header in pairs(lime.headers) do
		for _, member in pairs(header.members) do
			member.readyCheckIcon:Hide()
		end
	end
end 

function lime_ReadyCheckFinishAnim(reset)
	if reset then
		timer = 1
	end
	timer = timer - 0.02
	if timer > 0 then
		for _, header in pairs(lime.headers) do
			for _, member in pairs(header.members) do
				member.readyCheckIcon:SetAlpha(timer)
			end
		end
		readyCheckFrame.anim = C_Timer.After(0.02, lime_ReadyCheckFinishAnim)
	else
		lime_ReadyCheckHide()
	end
end

function limeMember_UpdateReadyCheck(self)
	if lime.doReadyCheck then
		if GetReadyCheckStatus(self.unit) then
			limeMember_UpdateReadyCheck2(self)
		end
	else
		self.readyCheckIcon:Hide()
	end
end

function lime:READY_CHECK()
	readyCheckFrame:Hide()
	self.doReadyCheck = true
	for _, header in pairs(self.headers) do
		for _, member in pairs(header.members) do
			member.readyCheckIcon:SetAlpha(1)
			member.readyCheckIcon:SetTexture("")
			if member:IsVisible() then
				limeMember_UpdateReadyCheck(member)
			end
		end
	end
end

function limeMember_UpdateReadyCheck2(self)
	if GetReadyCheckTimeLeft() <= 0 then
		return
	end

	local readyCheckStatus = GetReadyCheckStatus(self.unit)
	self.readyCheckStatus = readyCheckStatus
	if ( readyCheckStatus == "ready" ) then
		self.readyCheckIcon:SetTexture(READY_CHECK_READY_TEXTURE)
		self.readyCheckIcon:Show()
	elseif ( readyCheckStatus == "notready" ) then
		self.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
		self.readyCheckIcon:Show()
	elseif ( readyCheckStatus == "waiting" ) then
		self.readyCheckIcon:SetTexture(READY_CHECK_WAITING_TEXTURE)
		self.readyCheckIcon:Show()
	else
		self.readyCheckIcon:Hide()
	end
end
