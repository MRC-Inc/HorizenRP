net.Receive("ModernCarDealer.Net.ServerSendCars", function()
    MsgC(Color(135, 64, 216), "\n------------------------------------------------------------------\n")
    MsgC(color_white, "Modern Car Dealer", Color(135, 64, 216), " > ", color_white, "Data Received!\n")
    MsgC(Color(135, 64, 216), "------------------------------------------------------------------\n\n")
   
    local iNum = net.ReadUInt(22)
    local tData = util.JSONToTable(util.Decompress(net.ReadData(iNum)) or "")
 
    ModernCarDealer.Cars = tData[1]
    ModernCarDealer.Cars = ModernCarDealer.Cars or {}

    ModernCarDealer.Showcases = tData[2]
    ModernCarDealer.Showcases = ModernCarDealer.Showcases or {}

    ModernCarDealer.NPCs = tData[3]
    ModernCarDealer.NPCs = ModernCarDealer.NPCs or {}

    timer.Simple(0.5, function()
        for _, eEnt in pairs(ents.FindByClass("mcd_showcase")) do eEnt:MCD_LoadData() end
        for _, eEnt in pairs(ents.FindByClass("mcd_cardealer")) do eEnt:MCD_LoadData() end
        ModernCarDealer:UpdateVehicles()
    end)
end)

net.Receive("ModernCarDealer.Net.ServerSendClientsCars", function()
    local iNum = net.ReadUInt(22)
    
    ModernCarDealer.MyCars = util.JSONToTable(util.Decompress(net.ReadData(iNum)) or "")

    ModernCarDealer.MyCars = ModernCarDealer.MyCars or {}
end)

net.Receive("ModernCarDealer.Net.OpenEntity", function()
    surface.PlaySound("moderncardealer/notify.wav")

    local eEnt = LocalPlayer():GetEyeTrace().Entity
    if not IsValid(eEnt) then return end
    if not eEnt:GetClass() == "mcd_cardealer" then return end

    local iLoad = 0

    if not ModernCarDealer.NPCs then
        net.Start("ModernCarDealer.Net.LoadFail")
        net.SendToServer()

        iLoad = 0.25
    end 

    local iNum = net.ReadUInt(22)
    local tVehiclesOut = util.JSONToTable(util.Decompress(net.ReadData(iNum)) or "")

    timer.Simple(iLoad, function()
        local tData = ModernCarDealer.NPCs[eEnt:GetNWInt("MCD_Index")]

        if tData.Type == 0 then
            if ModernCarDealer.Cars[tData.Data.Dealer] then
                ModernCarDealer:OpenDealerUI(tData.Data.Dealer, tData.Name)
            else
                ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("error_notice"))
            end
        end

        if tData.Type == 1 then
            if tData.Data.is3D then
                ModernCarDealer:OpenExperimentalGarageUI(tData.Name, tData.Data.Dealers, tVehiclesOut)
            else
                ModernCarDealer:OpenGarageUI(tData.Name, tData.Data.Dealers, tVehiclesOut)
            end
        end
    end)
end)

net.Receive("ModernCarDealer.Net.UpdateUnderglow", function()
    local eVehicle = net.ReadEntity()

    if IsValid(eVehicle) then
        ModernCarDealer.UnderglowList[eVehicle:EntIndex()] = {eVehicle, eVehicle:GetNWVector("MCD_Underglow"):ToColor()}
    end
end)

net.Receive("ModernCarDealer.Net.ChatMessage", function()
    ModernCarDealer:ChatMessage(net.ReadString())
end)


net.Receive("ModernCarDealer.Net.Notify", function()
    local sMessage = net.ReadString()
    local iIcon = net.ReadUInt(3)

    notification.AddLegacy(ModernCarDealer:GetPhrase(sMessage), iIcon, 5)
    surface.PlaySound("moderncardealer/notify.wav")
end)

net.Receive("ModernCarDealer.Net.ToggleUnderglow", function()
    local eVehicle = net.ReadEntity()
    
    eVehicle.MCD_UnderglowState = not eVehicle.MCD_UnderglowState
end)

net.Receive("ModernCarDealer.Net.SendPlayerData", function()
    local bFound = net.ReadBool()

    if bFound then
        local iNum = net.ReadUInt(22)
        local tData = util.JSONToTable(util.Decompress(net.ReadData(iNum)) or "")
        local iID = net.ReadString()

        ModernCarDealer:PlayerManager(tData, iID) 
    else
        ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("error_notice"))
    end
end)