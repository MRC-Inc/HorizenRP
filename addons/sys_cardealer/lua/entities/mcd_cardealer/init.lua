AddCSLuaFile("cl_init.lua") AddCSLuaFile("shared.lua") include("shared.lua")

local tCooldowns = {}
local iTimeout = 0.5
local function MCD_SpamCheck(sNetMessage, pPlayer)
    tCooldowns[pPlayer] = tCooldowns[pPlayer] or {}
    tCooldowns[pPlayer][sNetMessage] = tCooldowns[pPlayer][sNetMessage] or nil

    if not tCooldowns[pPlayer][sNetMessage] then
        tCooldowns[pPlayer][sNetMessage] = CurTime()
        return true
    end
    
    if CurTime() - tCooldowns[pPlayer][sNetMessage] >= iTimeout then
        tCooldowns[pPlayer][sNetMessage] = CurTime()
        return true
    else
		return false
    end
end

function ENT:Initialize()
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:DropToFloor()
end

local function MCD_ProcessJobDealers(pPlayer, tData)
	local bCarOut = false
	
	for _, tCar in pairs(pPlayer.MCD_VehiclesOut or {}) do
		if IsValid(tCar[2]) then
			for _, tSubData in pairs(tData) do
				if tSubData.Data.Class == tCar[2].MCD_Class then
					bCarOut = true
				end
			end
		end
	end

	if not bCarOut then
		local tCars = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", "DATA") or "")
		tCars = tCars or {}

		for iIndex, tCar in pairs(tCars or {}) do -- Sadly this method is neccessary due to the fact that if a car is changed by admins, the player needs them to be removed.
			if tCar.JobCar == true then tCars[iIndex] = nil end
		end

		file.Write("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", util.TableToJSON(tCars))

		timer.Simple(0, function()
			for iDelay, tSubData in pairs(tData) do
				local sDealer = tSubData.Dealer
				local tDealersCar = tSubData.Data
				tDealersCar.Dealer = sDealer
				tDealersCar.JobCar = true
				tDealersCar.Skin = tDealersCar.ForcedSkin

				timer.Simple(iDelay*0.005, function()
					ModernCarDealer:GiveCar(pPlayer:SteamID64(), tDealersCar)
				end)
			end
		end)
	end
end

function ENT:Use(pPlayer)
	if not MCD_SpamCheck("MCD_OpenNPC", pPlayer) then return end
	local tData = self.tDealerData

	if not tData then -- No data error
		if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then
			ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("nodata_notice"), pPlayer)
		end
		return
	end

	if self.sType == "Dealers" then
		if tData.Check and not (tData.Check == "None Selected") then -- A check exists
			if ModernCarDealer.Config.PlayerCheck[tData.Check] then -- Check exists in config
				local bPlayerPassCheck = ModernCarDealer.Config.PlayerCheck[tData.Check][1]
				if bPlayerPassCheck(pPlayer) then -- Check passed
					net.Start("ModernCarDealer.Net.OpenEntity")
					net.Send(pPlayer)
				else -- Check failed
					ModernCarDealer:ChatMessage(ModernCarDealer.Config.PlayerCheck[tData.Check][2], pPlayer)
				end
			else -- Throw error, check does not exist in config
				net.Start("ModernCarDealer.Net.OpenEntity")
				net.Send(pPlayer)
			end
		else -- No check exists
			net.Start("ModernCarDealer.Net.OpenEntity")
			net.Send(pPlayer)
		end
	elseif self.sType == "Garages" then
		local function MCD_ProcessGarage()
			local bJobCars = false 
			local tJobCars = {}
			for _, sDealer in pairs(tData.Dealers) do
				for iIndex, tDealersCar in pairs(ModernCarDealer.Cars[sDealer] or {}) do
					if tDealersCar.JobDealer then -- If it is a job car
						if ModernCarDealer.Config.PlayerCheck[tDealersCar.Check] then -- Check exists in config
							if ModernCarDealer.Config.PlayerCheck[tDealersCar.Check][1](pPlayer) then -- Check passed
								local tData = {}
								tData.Dealer = sDealer
								tData.Data = tDealersCar
								table.insert(tJobCars, tData)
							end
						else -- No check exists
							local tData = {}
							tData.Dealer = sDealer
							tData.Data = tDealersCar
							table.insert(tJobCars, tData)
						end

						bJobCars = true
					end
				end
			end
		
			if bJobCars then
				MCD_ProcessJobDealers(pPlayer, tJobCars)
			end

			for iIndex, tCar in pairs(pPlayer.MCD_VehiclesOut or {}) do -- Send existing vehicles to player
				if not IsValid(tCar[2]) then
					table.remove(pPlayer.MCD_VehiclesOut, tonumber(iIndex))
				end
			end

			ModernCarDealer:RefreshPlayerVehicle(pPlayer)

			local tTableToSend = util.Compress(util.TableToJSON(pPlayer.MCD_VehiclesOut or {})) -- This will rarely send as most people will only spawn 1 car

			timer.Simple(0.1, function()
				net.Start("ModernCarDealer.Net.OpenEntity")
				if tTableToSend then
					net.WriteUInt(#tTableToSend, 22)
					net.WriteData(tTableToSend, #tTableToSend)
				end
				net.Send(pPlayer)
			end)
		end

		if tData.Check and not (tData.Check == "None Selected") then -- A check exists
			if ModernCarDealer.Config.PlayerCheck[tData.Check] then -- Check exists in config
				local bPlayerPassCheck = ModernCarDealer.Config.PlayerCheck[tData.Check][1]
				if bPlayerPassCheck(pPlayer) then -- Check passed
					MCD_ProcessGarage()
				else -- Check failed
					ModernCarDealer:ChatMessage(ModernCarDealer.Config.PlayerCheck[tData.Check][2], pPlayer)
				end
			else -- Throw error, check does not exist in config
				MCD_ProcessGarage()
			end
		else -- No check exists
			MCD_ProcessGarage()
		end
	end
end
