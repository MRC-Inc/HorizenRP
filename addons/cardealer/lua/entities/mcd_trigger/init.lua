AddCSLuaFile("shared.lua") include("shared.lua")

function ENT:Initialize()
	local tMaxMins = ModernCarDealer.Entities["MechanicPositions"]
	local vMins
	local vMaxs
	if tMaxMins then
		vMins = tMaxMins[1]
		vMaxs = tMaxMins[2]
	else
		self:Remove()
		return
	end

	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBoundsWS(vMins, vMaxs)
end

local function MCD_ProcessMechanicTriggerUsage(eEnt, bBypass)
	if eEnt:GetClass() == "prop_vehicle_jeep" or eEnt:GetClass() == "prop_vehicle_airboat" then
		if not IsValid(eEnt:GetDriver()) then return end

		local pPlayer = eEnt:GetDriver()
		
		if not (pPlayer:SteamID64() == eEnt.MCD_Owner) then return end
		if ModernCarDealer.Config.MechanicBlacklist[eEnt:GetVehicleClass()] then return end

		if not pPlayer.MCD_InMechanicUI or bBypass then
			pPlayer.MCD_InMechanicUI = true

			if not bBypass then
				net.Start("ModernCarDealer.Net.OpenMechanicUI")
				net.WriteInt(eEnt.iEngineUpgrade or 1, 4)
				net.Send(pPlayer)
			end

			if ModernCarDealer.Config.TriggerBasedMechanicUI or bBypass then
				eEnt:Fire("TurnOff", "1")
				eEnt:Fire("HandBrakeOn", "1")
			end
		end
	end
end

function ENT:StartTouch(eEnt)
	MCD_ProcessMechanicTriggerUsage(eEnt)
end

net.Receive("ModernCarDealer.Net.MechanicTriggerButtonPress", function(len, pPlayer) MCD_ProcessMechanicTriggerUsage(pPlayer:GetVehicle(), pPlayer.MCD_InMechanicUI) end)

function ENT:EndTouch(eEnt)
	if not ModernCarDealer.Config.TriggerBasedMechanicUI then
		if not IsValid(eEnt:GetDriver()) then return end
		
		local pPlayer = eEnt:GetDriver()
		
		if not (pPlayer:SteamID64() == eEnt.MCD_Owner) then return end
		
		if pPlayer.MCD_InMechanicUI then
			timer.Simple(1, function()
				if IsValid(pPlayer) then
					pPlayer.MCD_InMechanicUI = false

					net.Start("ModernCarDealer.Net.CloseMechanicUI")
					net.Send(pPlayer)
				end
			end)
		end
	end
end
