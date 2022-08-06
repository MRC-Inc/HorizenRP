local tCooldowns = {}
local iTimeout = 5

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

hook.Add("EntityRemoved", "ModernCarDealer.Hook.UpdateVehicleHealth", function(eEnt)
    if VC then
        if eEnt.MCD_Owner and not (eEnt.MCD_Owner == 0) and not ModernCarDealer.SimfPhys[eEnt:GetClass()] then
            local iOwnerID = eEnt.MCD_Owner
            local iCID = eEnt.MCD_CID

            local tPlayerCars = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(iOwnerID)..".json", "DATA"))

            for _, tCar in pairs(tPlayerCars) do
                if tCar.CID == iCID then
                    tCar.Health = math.Round(eEnt:VC_getHealth(true))
                    break
                end
            end
            
            file.Write("moderncardealer/playerdata/"..tostring(iOwnerID)..".json", util.TableToJSON(tPlayerCars))

            if player.GetBySteamID64(iOwnerID) then
                ModernCarDealer:RefreshPlayerVehicle(player.GetBySteamID64(iOwnerID))
            end
        end
    end
end)

hook.Add("VC_postVehicleInit", "ModernCarDealer.Hook.SetVehicleHealth", function(eVehicle)
    if VC then
        if not (eVehicle.MCD_Owner == 0) and not ModernCarDealer.SimfPhys[eVehicle:GetClass()] then
            eVehicle:VC_setHealth(eVehicle:VC_getHealthMax()*((eVehicle.MCD_Health or 100)/100))

            eVehicle:VC_fuelSet(eVehicle:VC_fuelGetMax())
        end
    end
end)

hook.Add("PlayerLeaveVehicle", "ModernCarDealer.Hook.TestDriveLeave", function(pPlayer, eVehicle)
    if IsValid(eVehicle) and eVehicle.MCD_TestDriveCar then eVehicle:Remove() timer.Simple(1, function() if IsValid(pPlayer) then pPlayer:SetPos(pPlayer.MCD_vReturnPos) pPlayer:SetAngles(pPlayer.MCD_vReturnAngles) end end) end
end)

local function MCD_Shutdown() -- Backup feature
    local iStamp = os.time()
    local sTime = os.date( "%m%d%Y_%H%M" , Timestamp )

    file.Write(string.lower(string.format("moderncardealer/maps/backups/%s_%s_entities.json", game.GetMap(), sTime)), util.TableToJSON(ModernCarDealer.Entities))
    
    file.Write(string.lower(string.format("moderncardealer/maps/backups/%s_%s_cars.json", game.GetMap(), sTime)), util.TableToJSON(ModernCarDealer.Cars))

    local tBackups = file.Find("moderncardealer/maps/backups/*", "DATA") or {}

    local bCullBackups = false
    if #tBackups > 80 then bCullBackups = true end -- We won't let the backups go over 40 shutdowns (1.25 Megabytes)

    for iIndex, sBackupTXT in pairs(tBackups) do
        if bCullBackups and (iIndex == 1 or iIndex == 2) then
            file.Delete("moderncardealer/maps/backups/"..sBackupTXT)
        end
    end
end

hook.Add("ShutDown", "ModernCarDealer.Hook.ShutDown", MCD_Shutdown)

hook.Add("PlayerButtonDown", "ModernCarDealer.Hook.UnderglowToggle", function(pPlayer, iButton)
    if iButton == ModernCarDealer.Config.UnderglowKey and IsValid(pPlayer:GetVehicle()) then 
        local eVehicle = pPlayer:GetVehicle()
        local sClass = eVehicle:GetClass()
        if MCD_SpamCheck("ModernCarDealer.Net.ToggleUnderglow", pPlayer) and (sClass == "prop_vehicle_jeep" or sClass == "gmod_sent_vehicle_fphysics_base" or sClass == "prop_vehicle_airboat") and not (eVehicle.MCD_Owner == 0) and IsValid(eVehicle) then
            if IsFirstTimePredicted() then
                net.Start("ModernCarDealer.Net.ToggleUnderglow")
                net.WriteEntity(eVehicle)
                net.Broadcast()
            end
        end
    end
end)

hook.Add("PlayerChangedTeam", "ModernCarDealer.Hook.SwitchJob", function(pPlayer)
    if IsValid(pPlayer) and pPlayer.MCD_VehiclesOut then
        for _, tCar in pairs(pPlayer.MCD_VehiclesOut) do
            if tCar[3] then -- Is it a job vehicle?
                if IsValid(tCar[2]) then
                    tCar[2]:Remove()
                end
            end
        end
    end
end)

hook.Add("playerSellVehicle", "ModernCarDealer.Hook.DarkRPCarSellAttempt", function(pPlayer, eVehicle)
    if IsValid(eVehicle) and pPlayer.MCD_VehiclesOut and eVehicle.MCD_Owner then
        return false
    end
end)