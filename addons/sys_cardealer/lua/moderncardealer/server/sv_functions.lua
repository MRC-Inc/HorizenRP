local sMap = string.lower(game.GetMap())

if not (file.Exists("moderncardealer/", "DATA")) then file.CreateDir("moderncardealer") end

if not (file.Exists("moderncardealer/playerdata/", "DATA")) then file.CreateDir("moderncardealer/playerdata") end
if not (file.Exists("moderncardealer/transfer/", "DATA")) then file.CreateDir("moderncardealer/transfer") end
if not (file.Exists("moderncardealer/transfer/vcmod", "DATA")) then file.CreateDir("moderncardealer/transfer/vcmod") end
if not (file.Exists("moderncardealer/transfer/acd", "DATA")) then file.CreateDir("moderncardealer/transfer/acd") end
if not (file.Exists("moderncardealer/transfer/wcd", "DATA")) then file.CreateDir("moderncardealer/transfer/wcd") end

if not (file.Exists("moderncardealer/mcd_cardealers.json", "DATA")) then file.Write("moderncardealer/mcd_cardealers.json", "") end

if not (file.Exists("moderncardealer/maps", "DATA")) then file.CreateDir("moderncardealer/maps", "DATA") end
if not (file.Exists("moderncardealer/maps/backups", "DATA")) then file.CreateDir("moderncardealer/maps/backups", "DATA") end
if not (file.Exists("moderncardealer/maps/"..sMap..".json", "DATA")) then file.Write("moderncardealer/maps/"..sMap..".json", "") end

function ModernCarDealer:RefreshPlayerVehicle(pPlayer)
    local tTableRead = file.Read("moderncardealer/playerdata/"..tostring(pPlayer:SteamID64())..".json", "DATA")
    tTableRead = tTableRead or ""

    if tTableRead then
        local tTableToSend = util.Compress(tTableRead)

        net.Start("ModernCarDealer.Net.ServerSendClientsCars")
        net.WriteUInt(#tTableToSend, 22)
        net.WriteData(tTableToSend, #tTableToSend)
        net.Send(pPlayer)
    end
end

local tDefault = {
    function() return true end,
    "",
    false
}

ModernCarDealer.Config.PlayerCheck["None Selected"] = tDefault

function ModernCarDealer:GiveCar(iId, tCarData)
    local tTable1Json = file.Read("moderncardealer/playerdata/"..tostring(iId)..".json", "DATA")
    local tTable1

    local iUsableCID
    if tTable1Json then
        tTable1 = util.JSONToTable(tTable1Json)

        local tExistingCIDs = {}
        for iIndex, tCar_PreExist in pairs(tTable1) do
            table.insert(tExistingCIDs, tCar_PreExist.CID)
        end
        for i = 1, 256 do 
            if not table.HasValue(tExistingCIDs, i) then
                iUsableCID = i
                break
            end
        end
    end

    local tCar = {}
    tCar.Name = tCarData.Name
    tCar.CID = iUsableCID
    tCar.Class = tCarData.Class
    tCar.Dealer = tCarData.Dealer
    tCar.Price = tCarData.Price
    tCar.Check = tCarData.Check
    tCar.Color = tCarData.Color or color_white
    tCar.Skin = tCarData.Skin or 0
    tCar.Underglow = color_transparent
    tCar.Bodygroups = {}
    tCar.Engine = "Default"
    tCar.Health = 100
    tCar.JobCar = tCarData.JobCar
    tCar.AllowCustomizing = tCarData.AllowCustomizing
    tCar.SimfPhys = tCarData.SimfPhys
    tCar.Insured = tCarData.Insured
    tCar.Inventory = tCarData.Inventory
    tCar.VehicleTrunkWeight = tCarData.VehicleTrunkWeight

    if tTable1Json then -- CASE: Player vehicle data exists
        table.insert(tTable1, tCar)

        file.Write("moderncardealer/playerdata/"..tostring(iId)..".json", util.TableToJSON(tTable1))
    else -- CASE: No player vehicle data exists
        tCar.CID = 1

        file.Write("moderncardealer/playerdata/"..tostring(iId)..".json", util.TableToJSON({tCar}))
    end

    ModernCarDealer:RefreshPlayerVehicle(player.GetBySteamID64(iId))
end

function ModernCarDealer:PriceCheck(pPlayer, iPrice, bHideNotify)
    if iPrice < 0 then iPrice = 0 end

    if pPlayer:canAfford(iPrice) then
        pPlayer:addMoney(-iPrice)

        if not bHideNotify then
            ModernCarDealer:Notify(pPlayer, 3, 5, "purchase_success")
        end
        return true
    end
end

function ModernCarDealer:RawVehicleData(sClass)
    local tSpawnData = ModernCarDealer.GamemodeVehicles[sClass]
    local tScriptData = ""

    if not tSpawnData then return false end

    for key, keyValue in pairs(tSpawnData.KeyValues) do
        if string.lower(key) == "vehiclescript" then
            tScriptData = file.Read(keyValue, "GAME") 
        end
    end
    
    return tSpawnData, tScriptData
end

function ModernCarDealer:ChatMessage(sMessage, pPlayer)
    net.Start("ModernCarDealer.Net.ChatMessage")
    net.WriteString(sMessage)
    net.Send(pPlayer)
end

function ModernCarDealer:Notify(pPlayer, iIcon, iTime, sMessage)
    net.Start("ModernCarDealer.Net.Notify")
    net.WriteString(sMessage)
    net.WriteUInt(iIcon, 3)
    net.Send(pPlayer)
end

function ModernCarDealer:PreloadCar(sType, sID, tData)
    file.Write("moderncardealer/transfer/"..sType.."/"..sID..".json", util.TableToJSON(tData), "DATA")
end

function ModernCarDealer:ProcessData() -- This will only run in the case that entities are modified/created
    file.Write("moderncardealer/maps/"..sMap..".json", util.TableToJSON(ModernCarDealer.Entities))
end

function ModernCarDealer:GetPhrase(sPhrase)
    return ModernCarDealer.Language[sPhrase]
end

function ModernCarDealer:GetCarByKeyValue(iIndex, iDealer)
    local iDealerIter = 0

    for sDealerName, tCars in SortedPairs(ModernCarDealer.Cars) do
        iDealerIter = iDealerIter + 1

        if iDealerIter == iDealer then
            return tCars[iIndex], sDealerName
        end
    end
end

ModernCarDealer.Config.EngineUpgrades["Default"] = {}
ModernCarDealer.Config.EngineUpgrades["Default"].index = 1
ModernCarDealer.Config.EngineUpgrades["Default"].price = 0
ModernCarDealer.Config.EngineUpgrades["Default"].horsepowerincrease = 0 

concommand.Add("mcd_givecar", function(pPlayer, _, tArgs)
    if IsValid(pPlayer) and not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) then return end

    local iReceiver = tArgs[1]
    local sDealer = tArgs[2]
    local sClass = tArgs[3]

    if not iReceiver or not sDealer or not sClass then
        ModernCarDealer:ChatMessage("Incomplete Arguments (Use Quotes)", pPlayer)
        print("MCD: Incomplete Arguements (Use Quotes)")

        return
    end

    if iReceiver == "STEAM_0" then
        ModernCarDealer:ChatMessage("Use SteamID64!", pPlayer)
        print("MCD: Use SteamID64")

        return
    else
        
    end

    local tDealerData = ModernCarDealer.Cars[sDealer]

    if tDealerData then
        local bFound = false
        for _, tCar in pairs(tDealerData) do
            if tCar.Class == sClass then
                bFound = true 

                tCar.Dealer = sDealer
                ModernCarDealer:GiveCar(iReceiver, tCar)
                break
            end
        end

        if not bFound then 
            ModernCarDealer:ChatMessage("No Vehicle", pPlayer)
            print("MCD: No Vehicle")
        else
            ModernCarDealer:ChatMessage("Successfully gave " .. iReceiver .. " vehicle: " .. sClass, pPlayer)
            print("MCD: Successfully gave " .. iReceiver .. " vehicle: " .. sClass)
        end
    else
        ModernCarDealer:ChatMessage("Dealer Error (Use Quotes)", pPlayer)
        print("MCD: Dealer Error (Use Quotes)")
    end
end)

function ModernCarDealer:RemovePlayerCar(iID, iCID)
    local tPlayerCars = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(iID)..".json", "DATA"))

    for iIndex, tCar in pairs(tPlayerCars) do
        if tCar.CID == iCID then
            table.remove(tPlayerCars, tonumber(iIndex))
            break
        end
    end

    file.Write("moderncardealer/playerdata/"..tostring(iID)..".json", util.TableToJSON(tPlayerCars))

    local pRemovedPlayer = player.GetBySteamID64(iID)
    
    if IsValid(pRemovedPlayer) then
        ModernCarDealer:RefreshPlayerVehicle(pRemovedPlayer)
    end
end