util.AddNetworkString("ModernCarDealer.Net.ClientAddCarDealer")
util.AddNetworkString("ModernCarDealer.Net.ClientDeleteCarDealer")
util.AddNetworkString("ModernCarDealer.Net.ServerSendCars")
util.AddNetworkString("ModernCarDealer.Net.ServerSendClientsCars")
util.AddNetworkString("ModernCarDealer.Net.ClientCreateEntity")
util.AddNetworkString("ModernCarDealer.Net.ClientDeleteEntity")
util.AddNetworkString("ModernCarDealer.Net.ClientModifyEntity")
util.AddNetworkString("ModernCarDealer.Net.ClientSpawnPointStart")
util.AddNetworkString("ModernCarDealer.Net.ClientSpawnPointEnd")
util.AddNetworkString("ModernCarDealer.Net.ClientMechanicTriggerSet")
util.AddNetworkString("ModernCarDealer.Net.Transfer")
util.AddNetworkString("ModernCarDealer.Net.RequestVCMODmaps")
util.AddNetworkString("ModernCarDealer.Net.SendVCMODmaps")
util.AddNetworkString("ModernCarDealer.Net.RequestPlayerData")
util.AddNetworkString("ModernCarDealer.Net.SendPlayerData")
util.AddNetworkString("ModernCarDealer.Net.DeletePlayerCar")

util.AddNetworkString("ModernCarDealer.Net.Load")
util.AddNetworkString("ModernCarDealer.Net.LoadFail")
util.AddNetworkString("ModernCarDealer.Net.OpenMechanicUI")
util.AddNetworkString("ModernCarDealer.Net.CloseMechanicUI")
util.AddNetworkString("ModernCarDealer.Net.MechanicTriggerButtonPress")
util.AddNetworkString("ModernCarDealer.Net.ResetOpenMechanicUI")
util.AddNetworkString("ModernCarDealer.Net.OpenEntity")
util.AddNetworkString("ModernCarDealer.Net.PurchaseCar")
util.AddNetworkString("ModernCarDealer.Net.RetrieveCar")
util.AddNetworkString("ModernCarDealer.Net.FixCar")
util.AddNetworkString("ModernCarDealer.Net.SellCar")
util.AddNetworkString("ModernCarDealer.Net.UpgradeCar")
util.AddNetworkString("ModernCarDealer.Net.UpdateUnderglow")
util.AddNetworkString("ModernCarDealer.Net.ToggleUnderglow")
util.AddNetworkString("ModernCarDealer.Net.TestDrive")
util.AddNetworkString("ModernCarDealer.Net.TestDriveCheckSuccessful")
util.AddNetworkString("ModernCarDealer.Net.ChatMessage")
util.AddNetworkString("ModernCarDealer.Net.Notify")

local sMap = string.lower(game.GetMap())
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
        ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("error_notice").." (Net Message Spam)", pPlayer)
        return false
    end
end

local function MCD_Send(pPlayer)
    timer.Simple(0, function() 
        local tTableToSend = ModernCarDealer.NetworkedData
        net.Start("ModernCarDealer.Net.ServerSendCars")
        net.WriteUInt(#tTableToSend, 22)
        net.WriteData(tTableToSend, #tTableToSend)
        net.Send(pPlayer)
    end)
end

local function MCD_Broadcast()
    timer.Simple(0, function() 
        MsgC(Color(135, 64, 216), "\n------------------------------------------------------------------\n")
        MsgC(color_white, "Modern Car Dealer", Color(135, 64, 216), " > ", color_white, "Sending Vehicles!\n")
        MsgC(Color(135, 64, 216), "------------------------------------------------------------------\n\n")

        local tTableToSend = ModernCarDealer.NetworkedData
        
        net.Start("ModernCarDealer.Net.ServerSendCars")
        net.WriteUInt(#tTableToSend, 22)
        net.WriteData(tTableToSend, #tTableToSend)
        net.Broadcast()
    end)
end

local eTrigger

local function MCD_CreateNPCs(bLoad)
    if ModernCarDealer.Entities then
        local tDealerNPCs = ModernCarDealer.Entities["Dealers"]
        local tGarageNPCs = ModernCarDealer.Entities["Garages"]
        local tShowcases = ModernCarDealer.Entities["Showcases"]
     
        if ModernCarDealer.PlayerNPCs and ModernCarDealer.PlayerShowcases then -- If an entity exists, we are going to delete it here. The rest of the function is dedicated to creating new ones.
            for iEntIndex, _ in pairs(ModernCarDealer.PlayerShowcases) do local eEnt = ents.GetByIndex(iEntIndex) if IsValid(eEnt) then eEnt:Remove() end end
            for iEntIndex, _ in pairs(ModernCarDealer.PlayerNPCs) do local eEnt = ents.GetByIndex(iEntIndex) if IsValid(eEnt) then eEnt:Remove() end end
        
            if IsValid(eTrigger) then eTrigger:Remove() end
        end
        
        ModernCarDealer.PlayerShowcases = {}
        ModernCarDealer.PlayerNPCs = {}

        for sName, tNPC in pairs(tDealerNPCs) do
            local eNPC = ents.Create("mcd_cardealer")
            eNPC.sName = sName

            if IsValid(eNPC) then
                eNPC:SetPos(tNPC.Position)
                eNPC:SetAngles(Angle(0, tNPC.Angles.y, 0))
                eNPC:SetModel(tNPC.Model)
                eNPC:Spawn()
                eNPC.tDealerData = tNPC
                eNPC.sType = "Dealers"
                
                local tData = {}
                tData.Type = 0
                tData.Name = sName
                tData.Data = tNPC

                if tNPC.Model == "models/painless/monitor.mdl" then
                    tData.Computer = true
                end

                ModernCarDealer.PlayerNPCs[eNPC:EntIndex()] = tData
                eNPC:SetNWInt("MCD_Index", eNPC:EntIndex()) -- This is the only fix that worked, for some reason server and client are getting different indexes.
            end
        end

        for sName, tNPC in pairs(tGarageNPCs) do
            local eNPC = ents.Create("mcd_cardealer")
            eNPC.sName = sName

            if IsValid(eNPC) then
                eNPC:SetPos(tNPC.Position)
                eNPC:SetAngles(Angle(0, tNPC.Angles.y, 0))
                eNPC:SetModel(tNPC.Model)
                eNPC:Spawn()
                eNPC.tDealerData = tNPC
                eNPC.sType = "Garages"

                local tData = {}
                tData.Type = 1
                tData.Name = sName
                tData.Data = tNPC

                if tNPC.Model == "models/painless/monitor.mdl" then
                    tData.Computer = true
                end

                ModernCarDealer.PlayerNPCs[eNPC:EntIndex()] = tData
                eNPC:SetNWInt("MCD_Index", eNPC:EntIndex()) -- This is the only fix that worked, for some reason server and client are getting different indexes.
            end
        end

        for iID, tShowCase in pairs(tShowcases) do
            local eShowCase = ents.Create("mcd_showcase")
            if IsValid(eShowCase) then
                eShowCase:SetPos(tShowCase.Position)
                eShowCase:SetAngles(Angle(0, tShowCase.Angles.y, 0))
                eShowCase:Spawn()
                eShowCase:SetModel(tShowCase.Model)
                eShowCase:DropToFloor()
                eShowCase:PhysicsInit(SOLID_NONE)
                eShowCase:SetSolid(SOLID_VPHYSICS)
                eShowCase:SetMaterial("")

                local tVehicleInfo, tScriptDataRaw = ModernCarDealer:RawVehicleData(tShowCase.Class)

                if not tVehicleInfo == false then 
                    local iFirstQuotationMark, _ = string.find(tScriptDataRaw, '"')
                    local tScriptData = util.KeyValuesToTable(string.sub(tScriptDataRaw, iFirstQuotationMark, #tScriptDataRaw), false, false)
                    
                    local iTopSpeed = tScriptData.engine.maxspeed -- All the special stats that appear are calculated here instead of on the client
                    local iHorsePower = tScriptData.engine.horsepower
                    local iBraking = tScriptData.axle.brakefactor
                    local iBraking = tScriptData.body.massoverride
                    
                    local tData = {}
                    tData.ID = iID
                    tData.Price = tShowCase.Price
                    tData.Class = tShowCase.Class
                    tData.Name = ModernCarDealer.GamemodeVehicles[tShowCase.Class].Name
                    
                    tData.Speed = iTopSpeed
                    tData.HP = iHorsePower
                    tData.Braking = iBraking
                    tData.Torque = iBraking
    
                    tData.Entity = eShowCase:EntIndex()
    
                    ModernCarDealer.PlayerShowcases[eShowCase:EntIndex()] = tData
                    eShowCase:SetNWInt("MCD_Index", eShowCase:EntIndex()) -- This is the only fix that worked, for some reason server and client are getting different indexes.
    
                    eShowCase:SetColor(Color(tShowCase.Color.r, tShowCase.Color.g, tShowCase.Color.b))
                
                    eShowCase.tDealerData = tShowCase
                    eShowCase.sType = "Showcases"
                else
                    eShowCase:SetModel("models/error.mdl")
                end
            end
        end

        eTrigger = ents.Create("mcd_trigger")
        if IsValid(eTrigger) then eTrigger:Spawn() end
    end

    ModernCarDealer.NetworkedData = {}
    ModernCarDealer.NetworkedData[1] = ModernCarDealer.Cars
    ModernCarDealer.NetworkedData[2] = ModernCarDealer.PlayerShowcases
    ModernCarDealer.NetworkedData[3] = ModernCarDealer.PlayerNPCs
    

    ModernCarDealer.NetworkedData = util.Compress(util.TableToJSON(ModernCarDealer.NetworkedData)) -- If we do this now we don't have to waste resources later

    if not bLoad then
        ModernCarDealer:ProcessData()
    end
end

function ModernCarDealer:UpdateVehicles()
    ModernCarDealer.GamemodeVehicles = list.Get("Vehicles")
    local tSimfPhys = list.Get("simfphys_vehicles")
    if tSimfPhys then
        ModernCarDealer.SimfPhys = {}

        for sCar, _ in pairs(tSimfPhys) do
            ModernCarDealer.SimfPhys[sCar] = true
        end

        table.Merge(ModernCarDealer.GamemodeVehicles, tSimfPhys)
    end

    local tPlanes = {}

    for sName, tData in pairs(scripted_ents.GetList()) do
        local tData = tData.t

        if tData then
            if simfphys and simfphys.LFS and (tData.Vehicle or tData.SeatPos) and not (tData.ClassName == "lunasflightschool_basescript") and not (tData.ClassName == "lunasflightschool_template") then
                local tPlane = {}
                tPlane.Class = tData.ClassName or "N/A"
                tPlane.Name = tData.PrintName or "N/A"
                tPlane.Model = tData.MDL or tData.EntModel or "N/A"
                tPlane.Category = "LFS"

                tPlanes[tPlane.Class] = tPlane
            elseif (tData.Base == "wac_hc_base" or tData.Base == "wac_pl_base") and tData.PrintName then
                local tPlane = {}
                tPlane.Class = tData.ClassName or "N/A"
                tPlane.Name = tData.PrintName or "N/A"
                tPlane.Model = tData.Model
                tPlane.Category = "WAC"

                tPlanes[tPlane.Class] = tPlane
            end
        end
    end

    ModernCarDealer.Planes = tPlanes
    table.Merge(ModernCarDealer.GamemodeVehicles, tPlanes)

    for _, v in pairs(ModernCarDealer.GamemodeVehicles) do
        v.Category = v.Category or "Other"
    end
end
local function MCD_Load()
    timer.Simple(1, function()
        ModernCarDealer:UpdateVehicles()

        ModernCarDealer.Cars = util.JSONToTable(file.Read("moderncardealer/mcd_cardealers.json", "DATA"))

        ModernCarDealer.Entities = util.JSONToTable(file.Read("moderncardealer/maps/"..string.lower(game.GetMap())..".json", "DATA") or "")
        ModernCarDealer.Entities = ModernCarDealer.Entities or {}
        ModernCarDealer.Entities["Garages"] = ModernCarDealer.Entities["Garages"] or {}
        ModernCarDealer.Entities["Dealers"] = ModernCarDealer.Entities["Dealers"] or {}
        ModernCarDealer.Entities["Showcases"] = ModernCarDealer.Entities["Showcases"] or {}

        ModernCarDealer.Entities["SpawnPositions"] = ModernCarDealer.Entities["SpawnPositions"] or {}

        --[[
        local tSpawnPositions = {}
        local bMissing = false
        for _, tEnt in pairs(ModernCarDealer.Entities["Garages"]) do
            if tEnt.SpawnPoints then
                table.Merge(tSpawnPositions, tEnt.SpawnPoints)
            else
                bMissing = true
            end
        end
        ModernCarDealer.Entities["SpawnPositions"] = tSpawnPositions

        if bMissing then
            MsgC(Color(135, 64, 216), "\n-------------------------------------------------------------------\n")
            MsgC(Color(135, 64, 216), "\n-------------------------------------------------------------------\n")
            MsgC(Color(135, 64, 216), "\n----  You need to respawn your garages to utilize this update  ----\n")
            MsgC(Color(135, 64, 216), "\n-------------------------------------------------------------------\n")
            MsgC(Color(135, 64, 216), "\n-------------------------------------------------------------------\n")
        end
        ]]--

        MCD_CreateNPCs()
        MCD_Broadcast()
    end)
end

hook.Add("PostCleanupMap", "ModernCarDealer.Hook.PostCleanupMap", MCD_Load)
hook.Add("InitPostEntity", "ModernCarDealer.Hook.InitPostEntity", MCD_Load)
hook.Add("PlayerInitialSpawn", "ModernCarDealer.Hook.SendAllCars", function(pPlayer) pPlayer.MCD_CapableToLoad = true end)

local bCheckVC -- Data transferring feature
if #file.Find("moderncardealer/transfer/vcmod/*", "DATA") > 0 then
    bCheckVC = true
end

local bCheckACD 
if #file.Find("moderncardealer/transfer/acd/*", "DATA") > 0 then
    bCheckACD = true
end

local bCheckWCD 
if #file.Find("moderncardealer/transfer/wcd/*", "DATA") > 0 then
    bCheckWCD = true
end

local function MCD_ParseTransferData(sPath, iID64)
    if file.Exists(sPath, "DATA") then
        local tCars = util.JSONToTable(file.Read(sPath, "DATA"))

        for _, tCar in pairs(tCars) do
            ModernCarDealer:GiveCar(iID64, tCar)
        end
        
        file.Delete(sPath)
    end
end

local function MCD_LoadPlayer(pPlayer, sRand)
    if pPlayer.MCD_CapableToLoad == true then
        if IsValid(pPlayer) then
            MCD_Send(pPlayer)

            ModernCarDealer:RefreshPlayerVehicle(pPlayer)

            if bCheckVC then
                local sPath = "moderncardealer/transfer/vcmod/"..tostring(pPlayer:UniqueID())..".json"
                MCD_ParseTransferData(sPath, pPlayer:SteamID64())
            end
            if bCheckACD then
                local sPath = "moderncardealer/transfer/acd/"..tostring(pPlayer:SteamID64())..".json"
                MCD_ParseTransferData(sPath, pPlayer:SteamID64())
            end
            if bCheckWCD then
                local sPath = "moderncardealer/transfer/wcd/"..tostring(pPlayer:UniqueID())..".json"
                MCD_ParseTransferData(sPath, pPlayer:SteamID64())
            end

            pPlayer.MCD_CapableToLoad = false

            timer.Remove("ModernCarDealer.Timer.LoadPlayer_"..sRand)
        end
    end
end

net.Receive("ModernCarDealer.Net.Load", function(len, pPlayer)
    local sRand = tostring(math.random(1, 20000))
    timer.Create("ModernCarDealer.Timer.LoadPlayer_"..sRand, 10, 12, function() MCD_LoadPlayer(pPlayer, sRand) end)  -- Try to load the addon 12 times
end)

net.Receive("ModernCarDealer.Net.LoadFail", function(len, pPlayer) -- This should never be used but is a failsafe
    pPlayer.MCD_LoadFailSafe = pPlayer.MCD_LoadFailSafe or false

    if not pPlayer.MCD_LoadFailSafe then
        pPlayer.MCD_LoadFailSafe = true
        pPlayer.MCD_CapableToLoad = true

        MCD_LoadPlayer(pPlayer, "")
    end
end)

concommand.Add("mcd_resetmapdata", function(pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    file.Write("moderncardealer/maps/"..sMap..".json", "")

    timer.Simple(1, MCD_Load)
end)

concommand.Add("mcd_resetdealerdata", function(pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    file.Write("moderncardealer/mcd_cardealers.json", "")

    timer.Simple(1, MCD_Load)
end)

local function MCD_CreateDealer(tTable)
    local sDealerName = tTable[2]
    local tDealer = tTable[1]

    local tInitial = ModernCarDealer.Cars
    
    tInitial = tInitial or {}

    tInitial[sDealerName] = tDealer

    local tFinal = util.TableToJSON(tInitial)

    file.Write("moderncardealer/mcd_cardealers.json", tFinal)
    
    ModernCarDealer.Cars = tInitial

    MCD_CreateNPCs()
    MCD_Broadcast()
end

net.Receive("ModernCarDealer.Net.ClientAddCarDealer", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local iNum = net.ReadUInt(22)
    local tJsonTableToRecieve = util.Decompress(net.ReadData(iNum)) or {}
    local tCars = util.JSONToTable(tJsonTableToRecieve)
    MCD_CreateDealer(tCars)
end)

net.Receive("ModernCarDealer.Net.ClientDeleteCarDealer", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local sDealerToRemove = net.ReadString()

    local tCars = ModernCarDealer.Cars
  
    tCars[sDealerToRemove] = nil

    file.Write("moderncardealer/mcd_cardealers.json", util.TableToJSON(tCars))
    
    MCD_CreateNPCs()
    MCD_Broadcast()
end)

net.Receive("ModernCarDealer.Net.ClientCreateEntity", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local sType = -1
    local iType = net.ReadUInt(2)

    if iType == 0 then
        sType = "Dealers"
    elseif iType == 1 then
        sType = "Garages"
    elseif iType == 2 then
        sType = "Showcases"
    end

    local iNum = net.ReadUInt(22)
    local tJsonTableToRecieve = util.Decompress(net.ReadData(iNum)) or {}
    local tEnt = util.JSONToTable(tJsonTableToRecieve)
    table.Merge(ModernCarDealer.Entities[sType], tEnt)

    if iType == 1 then
        for sName, tSpecifics in pairs(tEnt) do
            ModernCarDealer.Entities["SpawnPositions"][sName] = tSpecifics.SpawnPoints -- TEMP FIX
            tSpecifics.SpawnPoints = nil
        end
    elseif iType == 2 then
        local eShowcase = net.ReadEntity()
        if IsValid(eShowcase) then eShowcase:Remove() end
    end

    MCD_CreateNPCs()
    MCD_Broadcast()
end)

net.Receive("ModernCarDealer.Net.ClientDeleteEntity", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local eNPC = ents.GetByIndex(net.ReadUInt(32)) 

    if IsValid(eNPC) then
        for eAllNPCName, eAllNPC in pairs(ModernCarDealer.Entities[eNPC.sType]) do
            if eAllNPC.Position == eNPC.tDealerData.Position then
                ModernCarDealer.Entities[eNPC.sType][eAllNPCName] = nil
            end
        end
    end

    MCD_CreateNPCs()
    MCD_Broadcast()
end)

net.Receive("ModernCarDealer.Net.ClientModifyEntity", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local eNPC = ents.GetByIndex(net.ReadUInt(32))
    local bToPlayer = net.ReadBool()

    if IsValid(eNPC) then
        local tInitial = ModernCarDealer.Entities[eNPC.sType]

        for eAllNPCName, eAllNPC in pairs(tInitial) do
            if eAllNPC.Position == eNPC.tDealerData.Position then
                if bToPlayer then
                    tInitial[eAllNPCName].Position = pPlayer:GetPos()
                    tInitial[eAllNPCName].Angles = pPlayer:GetAngles()
                else
                    tInitial[eAllNPCName].Position = eNPC:GetPos()
                    tInitial[eAllNPCName].Angles = eNPC:GetAngles()
                end
            end
        end
    end

    MCD_CreateNPCs()
    MCD_Broadcast()
end)

net.Receive("ModernCarDealer.Net.PurchaseCar", function(len, pPlayer) -- NET: Spam check
    if not MCD_SpamCheck("ModernCarDealer.Net.PurchaseCar", pPlayer) then return end
    
    local iKey = net.ReadUInt(10)
    local iValue = net.ReadUInt(10)
    
    local tCarData, sDealerName = ModernCarDealer:GetCarByKeyValue(iKey, iValue)

    local cColor = net.ReadColor()
    local bInsured = net.ReadBool()

    local iPrice = tCarData.Price
    local iInsurancePrice = math.Clamp(iPrice*ModernCarDealer.Config.InsuranceToCarValuePercentage, ModernCarDealer.Config.InsuranceMinimum, ModernCarDealer.Config.InsuranceMaximum)
    if bInsured == true then iPrice = iPrice + iInsurancePrice end

    if ModernCarDealer.Config.PlayerCheck[tCarData.Check] and not ModernCarDealer.Config.PlayerCheck[tCarData.Check][1](pPlayer) then ModernCarDealer:Notify(pPlayer, 1, 5, "requirements") return end

    if pPlayer:canAfford(iPrice) then
        ModernCarDealer:Notify(pPlayer, 3, 5, "purchase_success_garage")

        pPlayer:addMoney(-iPrice)

        tCarData.Dealer = sDealerName
        tCarData.Color = cColor
        tCarData.JobDealer = false
        tCarData.Insured = bInsured

        ModernCarDealer:GiveCar(pPlayer:SteamID64(), tCarData)
    end
end)

local function MCD_CheckPoint(tPoint)
    local bIndividualCheckPassed = true
    local vMax = Vector(tPoint[4].x, tPoint[4].y, tPoint[4].z+200)
    local eEnts = ents.FindInBox(tPoint[3], vMax)
    for _, eEnt in pairs(eEnts) do
        if eEnt:GetClass() == "player" or eEnt:GetClass() == "prop_vehicle_jeep" or eEnt:GetClass() == "gmod_sent_vehicle_fphysics_base" or eEnt:GetClass() == "prop_vehicle_airboat" or eEnt:GetClass() == "" then
            bIndividualCheckPassed = false
        end
    end

    return bIndividualCheckPassed
end

local iDistanceCheck = ModernCarDealer.Config.ReturnDistance ^ 2

net.Receive("ModernCarDealer.Net.RetrieveCar", function(len, pPlayer) -- NET: Spam check, lots of checks
    if not MCD_SpamCheck("ModernCarDealer.Net.RetrieveCar", pPlayer) then return end

    local iNum = net.ReadUInt(8)

    local iPresetNum = net.ReadUInt(22)
    local tJsonTableToRecieve = util.Decompress(net.ReadData(iPresetNum)) or ""
    local tPresetData = util.JSONToTable(tJsonTableToRecieve)
    local tPlayerCars = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", "DATA"))

    -- Gather the actual vehicle only using the car ID to prevent exploiting
    local tVehicle = {}
    for _, tAll in pairs(tPlayerCars) do
        if tAll.CID == iNum then
            tVehicle = tAll
        end
    end

    if not pPlayer.MCD_VehiclesOut then pPlayer.MCD_VehiclesOut = {} end

    if ModernCarDealer.Config.PlayerCheck[tVehicle.Check] and not ModernCarDealer.Config.PlayerCheck[tVehicle.Check][1](pPlayer) and ModernCarDealer.Config.PlayerCheck[tVehicle.Check][3] then ModernCarDealer:Notify(pPlayer, 1, 5, "requirements") return end

    -- This will only run if the vehicle is out
    local bAlreadyOut = false
    for _, tCar in pairs(pPlayer.MCD_VehiclesOut) do
        if tCar[1] == iNum and IsValid(tCar[2]) then
                if tCar[2]:GetPos():DistToSqr(pPlayer:GetPos()) < iDistanceCheck then
                    ModernCarDealer:Notify(pPlayer, 3, 5, "vehicle_returned")
                    tCar[2]:Remove()
                else
                    ModernCarDealer:Notify(pPlayer, 1, 5, "car_far")
                end
                bAlreadyOut = true
            break
        end
    end
    if bAlreadyOut then return end

    local iMaxVehiclesConfig
    if isnumber(ModernCarDealer.Config.MaxVehiclesOut) then
        iMaxVehiclesConfig = ModernCarDealer.Config.MaxVehiclesOut
    else
        iMaxVehiclesConfig = ModernCarDealer.Config.MaxVehiclesOut[pPlayer:GetUserGroup()] or ModernCarDealer.Config.MaxVehiclesOut["default"] or 3
    end

    -- Maximum vehicle check
    if #pPlayer.MCD_VehiclesOut == iMaxVehiclesConfig then
        ModernCarDealer:Notify(pPlayer, 1, 5, "max_vehicles")
        return
    end

    local tNPC = pPlayer:GetEyeTrace().Entity
    local tPoint = nil
    local bPassed = false
    
    -- Spawn point check
    --local tAllSpawnPoints = tNPC.tDealerData.SpawnPoints or ModernCarDealer.Entities["SpawnPositions"]
    local tAllSpawnPoints = ModernCarDealer.Entities["SpawnPositions"][tNPC.sName]

    tAllSpawnPoints = tAllSpawnPoints or {}

    if #tAllSpawnPoints == 0 then
        ModernCarDealer:Notify(pPlayer, 1, 5, "error_notice")
        return
    end

    -- Everything works out!
   
    
    for iIndex, tPointGiven in pairs(tAllSpawnPoints) do
        if MCD_CheckPoint(tPointGiven) then -- Is the spawn position open?
            bPassed = true

            if tPoint == nil then
                tPoint = tPointGiven
            else
                if tPointGiven[1]:DistToSqr(pPlayer:GetPos()) < tPoint[1]:DistToSqr(pPlayer:GetPos()) then -- Closest spawn point
                    tPoint = tPointGiven
                end
            end
        end
    end

    if bPassed then
        local tVehicleTable = ModernCarDealer.GamemodeVehicles[tVehicle.Class]
        
        -- Spawning
        local eVehicle
        local aAng = tPoint[2]
        aAng = Angle(aAng.p, aAng.y + 180, aAng.r)
        local bSim = tVehicle.SimfPhys
        if not tVehicleTable.KeyValues then
            bSim = true
        end

        if not bSim then
            eVehicle = ents.Create(tVehicleTable.Class)
            if not IsValid(eVehicle) then return end

            eVehicle:SetModel(tVehicleTable.Model)
            for iK, iKV in pairs(tVehicleTable.KeyValues) do
                eVehicle:SetKeyValue(iK, iKV)
            end

            eVehicle:SetPos(tPoint[1])
            eVehicle:SetAngles(aAng)
            eVehicle:Spawn()
            eVehicle:Activate()
            eVehicle:SetCustomCollisionCheck(true)

            if IsValid(tNPC) and tNPC.tDealerData and tNPC.tDealerData.EnterVehicle then
                pPlayer:EnterVehicle(eVehicle)
            end

            eVehicle:SetVehicleClass(tVehicle.Class)

            -- Keys
            eVehicle:keysOwn(pPlayer)
            if ModernCarDealer.Config.LockCarOnSpawn then
                eVehicle:keysLock()
            end
        else
            if ModernCarDealer.Planes and ModernCarDealer.Planes[tVehicle.Class] then -- LFS Check 3
                eVehicle = ents.Create(tVehicle.Class)

                eVehicle:SetPos(tPoint[1])
                eVehicle:SetAngles(aAng)
                eVehicle:Spawn()
                eVehicle:Activate()
                eVehicle:SetCustomCollisionCheck(true)
            else
                eVehicle = simfphys.SpawnVehicleSimple(tVehicle.Class, tPoint[1], aAng)

                -- Keys
                eVehicle:keysOwn(pPlayer)
                if ModernCarDealer.Config.LockCarOnSpawn then
                    eVehicle:keysLock()
                end
            end
        end


   
        -- Appearance
        eVehicle:SetColor(tVehicle.Color) -- Color
        eVehicle:SetSkin(tVehicle.Skin) -- Skin
        for iKey, iValue in pairs(tVehicle.Bodygroups) do -- Bodygroups
            eVehicle:SetBodygroup(iKey, iValue)
        end

        if tVehicle.Underglow.a == 255 then -- Underglow setup
            eVehicle:SetNWVector("MCD_Underglow", Color(tVehicle.Underglow.r, tVehicle.Underglow.g, tVehicle.Underglow.b):ToVector())
        end

        for sName, tUpgrade in SortedPairs(ModernCarDealer.Config.EngineUpgrades) do
            if sName == tVehicle.Engine and not (tVehicle.SimfPhys) then
                local tParams = eVehicle:GetVehicleParams()
        
                eVehicle.iInitialHorsepower = tParams.engine.horsepower

                tParams.engine.horsepower = eVehicle.iInitialHorsepower + tUpgrade.horsepowerincrease
            
                eVehicle:SetVehicleParams(tParams)

                eVehicle.iEngineUpgrade = tUpgrade.index
                break
            end
        end

        -- Server Data
        eVehicle.MCD_Owner = pPlayer:SteamID64()
        eVehicle.MCD_CID = iNum
        eVehicle.MCD_Health = tVehicle.Health or 100
        eVehicle.MCD_Class = tVehicle.Class

		eVehicle.VehicleName = tVehicle.Class
        eVehicle.VehicleTable = tVehicleTable

        -- Job Vehicle
        if tVehicle.JobCar then -- Job Vehicle Setup
            eVehicle.MCD_Owner = 0

            if tPresetData and tVehicle.AllowCustomizing then 
                for iKey, iValue in pairs(tPresetData.Bodygroups) do
                    eVehicle:SetBodygroup(iKey, iValue)
                end

                eVehicle:SetSkin(tPresetData.Skin)

                eVehicle:SetColor(Color(tPresetData.Color.r, tPresetData.Color.g, tPresetData.Color.b))
            end
        end

        table.insert(pPlayer.MCD_VehiclesOut, {tVehicle.CID, eVehicle, tVehicle.JobCar})
        gamemode.Call("PlayerSpawnedVehicle", pPlayer, eVehicle) -- For some reason some cars don't like this and if the hook doesn't work, it doesn't run code after so?

        ModernCarDealer:Notify(pPlayer, 3, 5, "vehicle_retrieved")

    else
        ModernCarDealer:Notify(pPlayer, 1, 5, "spawn_positions_full")
    end
end)

local tSpawnPointInvisibleEntities = {}

net.Receive("ModernCarDealer.Net.ClientSpawnPointStart", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    --local tPreExistingSpawnPositions = ModernCarDealer.Entities["SpawnPositions"]

    tSpawnPointInvisibleEntities = {}

    --[[
    for _, vPreExisitingInfo in pairs(tPreExistingSpawnPositions) do
        local ePreExistingEnt = ents.Create("mcd_carspawn")
        if IsValid(ePreExistingEnt) then
            ePreExistingEnt:SetPos(vPreExisitingInfo[1])
            ePreExistingEnt:SetAngles(vPreExisitingInfo[2])
            ePreExistingEnt:Spawn()

            table.insert(tSpawnPointInvisibleEntities, ePreExistingEnt)
        end
    end
    ]]--

    hook.Add("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown"..tostring(pPlayer), function(pPlayerAll, iKeyRaw)
        if pPlayerAll ~= pPlayer then return end
        local tTrace = pPlayer:GetEyeTrace()

        if iKeyRaw == KEY_ENTER then
            local eEntTrace = tTrace.Entity

            if not (eEntTrace:GetClass() == "mcd_carspawn") then
                local eEnt = ents.Create("mcd_carspawn")
                if IsValid(eEnt) then
                    eEnt:SetAngles(Angle(0, pPlayer:EyeAngles().y-90, 0))
                    eEnt:SetPos(tTrace.HitPos + tTrace.HitNormal * 24 + eEnt:GetAngles():Right()*-80)
                    eEnt:Spawn()

                    table.insert(tSpawnPointInvisibleEntities, eEnt)
                end
            end
        end
        if iKeyRaw == KEY_BACKSPACE then
            local eEntTrace = tTrace.Entity
            
            if eEntTrace:GetClass() == "mcd_carspawn" then
                eEntTrace:Remove()
            end
        end
    end)
end)

net.Receive("ModernCarDealer.Net.ClientSpawnPointEnd", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    hook.Remove("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown"..tostring(pPlayer))

    for _, eExistingEnt in pairs(tSpawnPointInvisibleEntities) do
        if IsValid(eExistingEnt) then
            eExistingEnt:Remove()
        end
    end

    MCD_CreateNPCs()
    MCD_Broadcast()
end)

net.Receive("ModernCarDealer.Net.FixCar", function(len, pPlayer)
    local iCID = net.ReadUInt(8)
    
    local tPlayerCars = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", "DATA"))

    for _, tCar in pairs(tPlayerCars) do
        if tCar.CID == iCID then
            local iPrice

            if tCar.Insured then
                iPrice = 0
            else
                iPrice = ModernCarDealer.Config.RepairPrice
            end

            if pPlayer:canAfford(iPrice) then
                pPlayer:addMoney(-iPrice)
                ModernCarDealer:Notify(pPlayer, 3, 5, "vehicle_repaired")   
                
                tCar.Health = 100
            else
                ModernCarDealer:Notify(pPlayer, 1, 5, "afford_notice")
                return
            end 

            break
        end
    end

    file.Write("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", util.TableToJSON(tPlayerCars))

    ModernCarDealer:RefreshPlayerVehicle(pPlayer)
end)

net.Receive("ModernCarDealer.Net.SellCar", function(len, pPlayer) -- NET: Spam check
    if not MCD_SpamCheck("ModernCarDealer.Net.SellCar", pPlayer) then return end

    local iCID = net.ReadUInt(8)

    local sFilePath = "moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json"
    local tPlayerCars = util.JSONToTable(file.Read(sFilePath, "DATA"))

    for iIndex, tCar in pairs(tPlayerCars) do
        if tCar.CID == iCID then
            tPlayerCars[tonumber(iIndex)] = nil
            
            file.Write(sFilePath, util.TableToJSON(tPlayerCars))

            local bExploited = false -- Exploit protection
            local tPlayerCars2 = util.JSONToTable(file.Read(sFilePath, "DATA"))
            for _, tCar in pairs(tPlayerCars2) do
                if tCar.CID == iCID then
                    print("MCD: Exploit attempt at player: "..pPlayer:GetName())
                    bExploited = true
                end
            end

            if not bExploited then
                pPlayer:addMoney(tCar.Price*ModernCarDealer.Config.SellPercentage)
            end

            break
        end
    end

    ModernCarDealer:Notify(pPlayer, 3, 5, "vehicle_sold")        
 
    ModernCarDealer:RefreshPlayerVehicle(pPlayer)
end)

net.Receive("ModernCarDealer.Net.DeletePlayerCar", function(len, pPlayer) -- NET: Spam check
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local iCID = net.ReadUInt(8)
    local iID = net.ReadString()

    ModernCarDealer:RemovePlayerCar(iID, iCID)
end)

net.Receive("ModernCarDealer.Net.UpgradeCar", function(len, pPlayer) -- NET: Spam check, distance check
    if not MCD_SpamCheck("ModernCarDealer.Net.UpgradeCar", pPlayer) then return end
    if not pPlayer.MCD_InMechanicUI then return end

    local eVehicle = pPlayer:GetVehicle()
    if not (pPlayer:SteamID64() == eVehicle.MCD_Owner) then return end

    local tMaxMins = ModernCarDealer.Entities["MechanicPositions"]
    local vMins = tMaxMins[1]
    local vMaxs = tMaxMins[2]
    if pPlayer:GetPos():DistToSqr((vMins + vMaxs) / 2) > 1960000 then return end

    local tPlayerCars = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", "DATA"))

    local iCommand = net.ReadUInt(3)
    
    if iCommand == 1 and ModernCarDealer:PriceCheck(pPlayer, ModernCarDealer.Config.ColorPrice) then
        local cSetColor = net.ReadColor()

        eVehicle:SetColor(cSetColor)

        for _, tCar in pairs(tPlayerCars) do
            if tCar.CID == eVehicle.MCD_CID then
                tCar.Color = cSetColor
                break
            end
        end
    end
    if iCommand == 2 and ModernCarDealer:PriceCheck(pPlayer, ModernCarDealer.Config.SkinPrice) then
        local cSetSkin = net.ReadUInt(5)

        eVehicle:SetSkin(cSetSkin)

        for _, tCar in pairs(tPlayerCars) do
            if tCar.CID == eVehicle.MCD_CID then
                tCar.Skin = cSetSkin
                break
            end
        end
    end
    if iCommand == 3 then
        if ModernCarDealer:PriceCheck(pPlayer, ModernCarDealer.Config.BodygroupPrice) then
            local iKey = net.ReadUInt(5)
            local iValue = net.ReadUInt(5)

            eVehicle:SetBodygroup(iKey, iValue)
            
            for _, tCar in pairs(tPlayerCars) do
                if tCar.CID == eVehicle.MCD_CID then
                    tCar.Bodygroups[iKey] = iValue
                    break
                end
            end
        end
    end
    if iCommand == 4 then
        local cUnderGlowColor = net.ReadColor()
        for _, tCar in pairs(tPlayerCars) do
            if tCar.CID == eVehicle.MCD_CID and ModernCarDealer:PriceCheck(pPlayer, ModernCarDealer.Config.UnderglowPrice) then
                tCar.Underglow = cUnderGlowColor
                eVehicle:SetNWVector("MCD_Underglow", Color(cUnderGlowColor.r, cUnderGlowColor.g, cUnderGlowColor.b):ToVector())

                net.Start("ModernCarDealer.Net.UpdateUnderglow")
                net.WriteEntity(eVehicle)
                net.Broadcast()
                break
            end
        end
    end

    if iCommand == 5 then
        local iUpgrade = net.ReadUInt(5)

        for sName, tUpgrade in SortedPairs(ModernCarDealer.Config.EngineUpgrades) do
            if tUpgrade.index == iUpgrade then
                for _, tCar in pairs(tPlayerCars) do
                    if tCar.CID == eVehicle.MCD_CID and ModernCarDealer:PriceCheck(pPlayer, tUpgrade.price) then
                        tCar.Engine = sName
          
                        local tParams = eVehicle:GetVehicleParams()

                        tParams.engine.horsepower = eVehicle.iInitialHorsepower + tUpgrade.horsepowerincrease
                    
                        eVehicle:SetVehicleParams(tParams)

                        eVehicle.iEngineUpgrade = tUpgrade.index

                        break
                    end
                end
                break
            end
        end
    end

    file.Write("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", util.TableToJSON(tPlayerCars))

    ModernCarDealer:RefreshPlayerVehicle(pPlayer)
end)

net.Receive("ModernCarDealer.Net.ClientMechanicTriggerSet", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end
    
    local vFirstVector = net.ReadVector()
    local vSecondVector = net.ReadVector()

    ModernCarDealer.Entities["MechanicPositions"] = {vFirstVector, vSecondVector}

    MCD_CreateNPCs()
    MCD_Broadcast()
end)


net.Receive("ModernCarDealer.Net.ResetOpenMechanicUI", function(len, pPlayer) -- NET: Spam check, UI check
    if not MCD_SpamCheck("ModernCarDealer.Net.ResetOpenMechanicUI", pPlayer) then return end

    if pPlayer.MCD_InMechanicUI then
        local eEnt = pPlayer:GetVehicle()
        eEnt:Fire("TurnOn", "1")

        timer.Simple(3, function() if IsValid(pPlayer) then pPlayer.MCD_InMechanicUI = false end end)
    end
end)

net.Receive("ModernCarDealer.Net.TestDrive", function(len, pPlayer)  -- NET: Spam check, distance check
    if not MCD_SpamCheck("ModernCarDealer.Net.TestDrive", pPlayer) then return end
    
    if not ModernCarDealer.Config.TestDrivingEnabled then return end
    
    local iKey = net.ReadUInt(10)
    local iValue = net.ReadUInt(10)
    local eDealer = pPlayer:GetEyeTrace().Entity

    if not IsValid(eDealer) or not (eDealer:GetClass() == "mcd_cardealer") then return end

    local tCarData, sDealer = ModernCarDealer:GetCarByKeyValue(iKey, iValue)

    local tDealerNPCs = ModernCarDealer.Entities["Dealers"]

    local bDistanceCheckPassed = false
    for _, tDealer in pairs(tDealerNPCs) do
        if tDealer.Position:DistToSqr(pPlayer:GetPos()) < iDistanceCheck then 
            bDistanceCheckPassed = true
            break
        end
    end
    
    if not bDistanceCheckPassed then return end

    if ModernCarDealer:PriceCheck(pPlayer, (tCarData.Price*ModernCarDealer.Config.TestDrivingPercentMoneyNeeded) - 1, true) then
        if ModernCarDealer.Config.PlayerCheck[tCarData.Check] and not ModernCarDealer.Config.PlayerCheck[tCarData.Check][1](pPlayer) then ModernCarDealer:Notify(pPlayer, 1, 5, "requirements") return end

        -- Spawn point check
        local tAllSpawnPoints = {}

        for sGarage, tGarage in pairs(ModernCarDealer.Entities["SpawnPositions"]) do
            for _, tPosition in pairs(tGarage) do
                table.insert(tAllSpawnPoints, tPosition)
            end
        end

        if #tAllSpawnPoints == 0 then
            ModernCarDealer:Notify(pPlayer, 1, 5, "error_notice")
            return
        end

        local tPoint = nil
        local bPassed = false
    
        for iIndex, tPointGiven in pairs(tAllSpawnPoints) do
            if MCD_CheckPoint(tPointGiven) then -- Is the spawn position open?
                bPassed = true
    
                if tPoint == nil then
                    tPoint = tPointGiven
                else
                    if tPointGiven[1]:DistToSqr(pPlayer:GetPos()) < tPoint[1]:DistToSqr(pPlayer:GetPos()) then -- Closest spawn point
                        tPoint = tPointGiven
                    end
                end
            end
        end

        if bPassed then
            local tVehicleTable = ModernCarDealer.GamemodeVehicles[tCarData.Class]
            
            pPlayer.MCD_vReturnPos = pPlayer:GetPos()
            pPlayer.MCD_vReturnAngles = pPlayer:GetAngles()

            local eVehicle
            local aAng = tPoint[2]
            aAng = Angle(aAng.p, aAng.y + 180, aAng.r)

            if not tCarData.SimfPhys then
                eVehicle = ents.Create(tVehicleTable.Class)
                if not IsValid(eVehicle) then return end

                eVehicle:SetModel(tVehicleTable.Model)
                for iK, iKV in pairs(tVehicleTable.KeyValues) do
                    eVehicle:SetKeyValue(iK, iKV)
                end

                eVehicle:SetPos(tPoint[1])
                eVehicle:SetAngles(aAng)
                eVehicle:Spawn()
                eVehicle:Activate()
                eVehicle:SetCustomCollisionCheck(true)
                eVehicle:SetCollisionGroup(COLLISION_GROUP_WEAPON)

                pPlayer:EnterVehicle(eVehicle)
            else
                return 
            end

            eVehicle:keysOwn(pPlayer)
            
            eVehicle.MCD_TestDriveCar = true

            timer.Simple(0, function()
                eVehicle:keysLock()

                timer.Simple(ModernCarDealer.Config.TestDriveTime, function() if IsValid(eVehicle) then eVehicle:Remove() timer.Simple(1, function() if IsValid(pPlayer) then pPlayer:SetPos(pPlayer.MCD_vReturnPos) pPlayer:SetAngles(pPlayer.MCD_vReturnAngles) end end) end end)

                net.Start("ModernCarDealer.Net.TestDriveCheckSuccessful")
                net.Send(pPlayer)
            end)
        else
            ModernCarDealer:Notify(pPlayer, 1, 5, "spawn_positions_full")
            return
        end
    end
end)

net.Receive("ModernCarDealer.Net.Transfer", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end


    local sType
    local iType = net.ReadUInt(2)

    if iType == 0 then
        sType = "ACD"
    elseif iType == 1 then
        sType = "WCD"
    elseif iType == 2 then
        sType = "VCMOD"
    end

    local bTransferPlayerData = net.ReadBool()

    if sType == "ACD" then
        if not AdvCarDealer then ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("error_notice")..": Addon not installed!", pPlayer) return end

        local tVehicles = {}
        for sBrand, tCar in pairs(AdvCarDealer.GetConfig().Vehicles) do
            for sClass, tCarDetails in pairs(tCar) do
                local tVehicle = {}

                if ModernCarDealer.GamemodeVehicles[sClass] then
                    tVehicle.Category = sBrand
                    tVehicle.Check = "None Selected"
                    tVehicle.Class = sClass
                    tVehicle.Name = tCarDetails.name
                    tVehicle.Price = tCarDetails.priceCatalog

                    table.insert(tVehicles, tVehicle)
                else
                    ModernCarDealer:ChatMessage(string.format(ModernCarDealer:GetPhrase("content_missing"), sClass), pPlayer)
                end
            end
        end
        

        MCD_CreateDealer({tVehicles, "ACD: All"})

        ModernCarDealer:ChatMessage("Successfully created a car dealer!", pPlayer)

        if bTransferPlayerData then
            local tCarsToGive = {}

            local function fCompleted(tStoredCars)
                for _, tCarStored in pairs(tStoredCars) do
                    for _, tCarAll in pairs(tVehicles) do
                        if tCarStored.vehicle == tCarAll.Class then
                            tCarsToGive[tCarStored.steamID] = tCarsToGive[tCarStored.steamID] or {}

                            local tCar = {}

                            tCar.Name = tCarAll.Name
                            tCar.Class = tCarAll.Class
                            tCar.Dealer = "ACD: All"
                            tCar.Price = tCarAll.Price
                            tCar.Check = "None Selected"
                            tCar.Color = color_white
                            tCar.Skin = 0
                            tCar.JobCar = false
                            tCar.AllowCustomizing = false

                            table.insert(tCarsToGive[tCarStored.steamID], tCar)
                            break
                        end
                    end
                end

                for sSteamID, tCars in pairs(tCarsToGive) do
                    print("Modern Car Dealer: Giving "..sSteamID..": ")
                    PrintTable(tCars)

                    ModernCarDealer:PreloadCar("acd", util.SteamIDTo64(sSteamID), tCars)
                end
            end
        
            MySQLite.query( "SELECT vehicle, steamID FROM adv_cardealer_vehicles", fCompleted )
        end
    end

    if sType == "VCMOD" then
        local sMap = net.ReadString()

        local tDealers = file.Find("vcmod/cardealer/maps/"..sMap.."/*", "DATA")
        local tAllVehicles = {}

        for _, sDealerTXT in pairs(tDealers) do
            local tDealer = util.JSONToTable(file.Read("vcmod/cardealer/maps/"..sMap.."/"..sDealerTXT, "DATA"))
            local tVehicles = {}
    
            for _, tCarDetails in pairs(tDealer.Vehicles) do
                if ModernCarDealer.GamemodeVehicles[tCarDetails.Entity] then
                    local tVehicle = {}
                    tVehicle.Category = "None"
                    tVehicle.Check = "None Selected"
                    tVehicle.Class = tCarDetails.Entity
                    tVehicle.Name = tCarDetails.Name
                    tVehicle.Price = tCarDetails.Price
    
                    table.insert(tVehicles, tVehicle)
    
                    tVehicle.Dealer = "VCMOD: "..tDealer.Name
                    table.insert(tAllVehicles, tVehicle)
                else
                    ModernCarDealer:ChatMessage(string.format(ModernCarDealer:GetPhrase("content_missing"), tCarDetails.Entity), pPlayer)
                end
            end

            MCD_CreateDealer({tVehicles, "VCMOD: "..tostring(tDealer.Name)})
        end

        if bTransferPlayerData then
            local tPlayerDatas = file.Find("vcmod/cardealer/plydata/*", "DATA")
            
            for _, sPlayerDataTXT in pairs(tPlayerDatas) do
                local tCarsToGive = {}

                local tPlayerData = util.JSONToTable(file.Read("vcmod/cardealer/plydata/"..sPlayerDataTXT, "DATA"))
                
                for sData, _ in pairs(tPlayerData.Vehicles) do                    
                    local tCarVcmod = string.Explode("$$$_VC_$$$", sData) -- VCMOD PLYDATA
                
                    local tCar = {} -- FINAL SUBMIT

                    for _, tCarFromAll in pairs(tAllVehicles) do
                        if tCarFromAll.Name == tCarVcmod[2] then
                            tCar.Name = tCarFromAll.Name
                            tCar.Class = tCarFromAll.Class
                            tCar.Dealer = tCarFromAll.Dealer
                            tCar.Price = tCarFromAll.Price
                            tCar.Check = "None Selected"
                            tCar.Color = color_white
                            tCar.Skin = 0
                            tCar.JobCar = false
                            tCar.AllowCustomizing = false

                            table.insert(tCarsToGive, tCar)
                            break
                        end
                    end
                end

                local iUniqueID = string.Replace(sPlayerDataTXT, ".txt", "")

                print("Modern Car Dealer: Giving "..tostring(iUniqueID)..": ")
                PrintTable(tCarsToGive)

                ModernCarDealer:PreloadCar("vcmod", iUniqueID, tCarsToGive)
            end
        end

        ModernCarDealer:ChatMessage(string.format("%s... (%i)", ModernCarDealer:GetPhrase("completed"), #tDealers), pPlayer)
    end
    if sType == "WCD" then
        local tVehicles = {}
        local tIDs = {}
        local tDealers = file.Find("wcd/cars/*", "DATA")

        for _, sDealersTXT in pairs(tDealers) do
            local tCarDetails = util.JSONToTable(file.Read("wcd/cars/"..sDealersTXT, "DATA"))

            if not tCarDetails.__WCDEnt == true then
                if ModernCarDealer.GamemodeVehicles[tCarDetails.class] then
                    local tVehicle = {}
                
                    tVehicle.Category = "None"
                    tVehicle.Check = "None Selected"
                    tVehicle.Class = tCarDetails.class
                    tVehicle.Name = tCarDetails.name
                    tVehicle.Price = tCarDetails.price

                    tIDs[tCarDetails.id] = tVehicle
                    table.insert(tVehicles, tVehicle)
                else
                    ModernCarDealer:ChatMessage(string.format(ModernCarDealer:GetPhrase("content_missing"), tCarDetails.class), pPlayer)
                end
            end
        end

        MCD_CreateDealer({tVehicles, "WCD: All"})
        ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("completed"), pPlayer)

        if bTransferPlayerData then
            local function fCompleted(tStoredInfo)
                local tStoredCars = {}

                for _, tStored in pairs(tStoredInfo) do
                    local tVehiclesWCD = util.JSONToTable(tStored.value)

                    if string.EndsWith(tStored.infoid, "[wcd::owned]") and #tStored.value > 2 then
                        local iUniqueID = string.Replace(tStored.infoid, "[wcd::owned]", "")
                    
                        local tCarsToGive = {}
                        local bContinue = false

                        for iID, _ in pairs(tVehiclesWCD) do
                            local tCar = tIDs[iID]

                            if tCar then
                                local tVehicle = {}

                                tVehicle.Name = tCar.Name
                                tVehicle.Class = tCar.Class
                                tVehicle.Dealer = "WCD: All"
                                tVehicle.Price = tCar.Price
                                tVehicle.Check = "None Selected"
                                tVehicle.Color = color_white
                                tVehicle.Skin = 0
                                tVehicle.JobCar = false
                                tVehicle.AllowCustomizing = false
                                
                                table.insert(tCarsToGive, tVehicle)

                                bContinue = true
                            end
                        end

                        if bContinue then
                            print("Modern Car Dealer: Giving "..tostring(iUniqueID)..": ")
                            PrintTable(tCarsToGive)

                            ModernCarDealer:PreloadCar("wcd", iUniqueID, tCarsToGive)
                        end
                    end
                end 
            end
        
            MySQLite.query("SELECT * FROM playerpdata", fCompleted)
        end
    end

    if bTransferPlayerData then
        ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("restart_notice"), pPlayer)
    end
end)

net.Receive("ModernCarDealer.Net.RequestVCMODmaps", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local _, tDirectories = file.Find("vcmod/cardealer/maps/*", "DATA")
    
    local tTableToSend = util.Compress(util.TableToJSON(tDirectories))

    net.Start("ModernCarDealer.Net.SendVCMODmaps")
    net.WriteUInt(#tTableToSend, 22)
    net.WriteData(tTableToSend, #tTableToSend)
    net.Send(pPlayer)
end)

net.Receive("ModernCarDealer.Net.RequestPlayerData", function(len, pPlayer)
    if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end
    local sID = net.ReadString()

    local tJson = file.Read("moderncardealer/playerdata/"..tostring(sID)..".json", "DATA")

    if tJson then
        local tTableToSend = util.Compress(tJson)

        net.Start("ModernCarDealer.Net.SendPlayerData")
        net.WriteBool(true)
        net.WriteUInt(#tTableToSend, 22)
        net.WriteData(tTableToSend, #tTableToSend)
        net.WriteString(tostring(sID))
        net.Send(pPlayer)
    else
        net.Start("ModernCarDealer.Net.SendPlayerData")
        net.WriteBool(false)
        net.Send(pPlayer)
    end
end)