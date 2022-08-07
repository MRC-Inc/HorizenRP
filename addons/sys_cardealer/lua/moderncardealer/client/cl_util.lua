if not (file.Exists("moderncardealer/presets", "DATA")) then file.CreateDir("moderncardealer/") end

hook.Add("InitPostEntity", "ModernCarDealer.Hook.Load", function()
    net.Start("ModernCarDealer.Net.Load")
    net.SendToServer()
end)

function ModernCarDealer:RawVehicleData(sClass)
    local tSpawnData = ModernCarDealer.GamemodeVehicles[sClass]
    local tScriptData = ""

    for key, keyValue in pairs(tSpawnData.KeyValues) do
        if string.lower(key) == "vehiclescript" then
            tScriptData = file.Read(keyValue, "GAME") 
        end
    end

    return tSpawnData, tScriptData
end

-- Completely taken from the DarkRP development team, credits to them.

local function MCD_AttachCurrency(str)
    ModernCarDealer.Config.CurrencyOnLeft = ModernCarDealer.Config.CurrencyOnLeft or true
    ModernCarDealer.Config.CurrencySymbol = ModernCarDealer.Config.CurrencySymbol or "$"

    return ModernCarDealer.Config.CurrencyOnLeft and ModernCarDealer.Config.CurrencySymbol .. str or str .. ModernCarDealer.Config.CurrencySymbol
end

function ModernCarDealer:FormatMoney(n)
    if not isnumber(n) then return "nil" end

    if not n then return MCD_AttachCurrency("0") end

    if n >= 1e14 then return MCD_AttachCurrency(tostring(n)) end
    if n <= -1e14 then return "-" .. MCD_AttachCurrency(tostring(math.abs(n))) end

    local negative = n < 0

    n = tostring(math.abs(n))
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n + 1

    for i = dp - 4, 1, -3 do
        n = n:sub(1, i) .. sep .. n:sub(i + 1)
    end

    return (negative and "-" or "") .. MCD_AttachCurrency(n)
end


function ModernCarDealer:PriceCheck(iPrice, sMoreInfo) -- This is just the client side version.
    sMoreInfo = sMoreInfo or ""
    if iPrice < 0 then iPrice = 0 end

    if LocalPlayer():canAfford(iPrice) then
        surface.PlaySound("buttons/button14.wav")

        return true
    else
        ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("afford_notice")..sMoreInfo)
        return false
    end
end

function ModernCarDealer:AlreadyOwned()
    ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("already_owned_notice"))
    surface.PlaySound("buttons/button2.wav")
end

function draw.Circle(x, y, radius, seg) -- CREDITS: https://wiki.facepunch.com/gmod/surface.DrawPoly
    local cir = {}

    table.insert(cir, { x = x, y = y, u = 0.5, v = 0.5 })
    for i = 0, seg do
        local a = math.rad((i / seg) * -360)
        table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
    end

    local a = math.rad(0)
    table.insert(cir, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })

    surface.DrawPoly(cir)
end

local cAccentColor = ModernCarDealer.Config.AccentColor

function ModernCarDealer:ChatMessage(sMessage)
    chat.AddText(cAccentColor, "Modern Car Dealer", Color(121, 121, 121), " » ", color_white, sMessage)
end

function ModernCarDealer:GetPhrase(sPhrase)
    return ModernCarDealer.Language[sPhrase] or "Language Error!"
end

function ModernCarDealer:GetCarKeyValue(sClass, sDealer)
    local iDealerIter = 0

    for sDealerName, tCars in SortedPairs(ModernCarDealer.Cars) do
        iDealerIter = iDealerIter + 1
        if sDealer == sDealerName then
            for iIndex, tCar in pairs(tCars) do
                if tCar.Class == sClass then
                    return iIndex, iDealerIter
                end
            end
            break
        end
    end
end

ModernCarDealer.Config.EngineUpgrades["Default"] = {}
ModernCarDealer.Config.EngineUpgrades["Default"].index = 1
ModernCarDealer.Config.EngineUpgrades["Default"].price = 0
ModernCarDealer.Config.EngineUpgrades["Default"].horsepowerincrease = 0 

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

                tPlanes[tPlane.Class] = tPlane -- They share all the same functions, except one. No need to go add both of them...
            end
        end
    end

    ModernCarDealer.Planes = tPlanes
    table.Merge(ModernCarDealer.GamemodeVehicles, tPlanes)

    for _, v in pairs(ModernCarDealer.GamemodeVehicles) do
        v.Category = v.Category or "Other"
    end
end


ModernCarDealer.UnderglowList = ModernCarDealer.UnderglowList or {}


local function MCD_UnderglowSetup(eVehicle)
    timer.Simple(1, function()
        if IsValid(eVehicle) then          
            ModernCarDealer.UnderglowList[eVehicle:EntIndex()] = {eVehicle, eVehicle:GetNWVector("MCD_Underglow"):ToColor()}
            eVehicle.MCD_UnderglowState = ModernCarDealer.Config.SpawnWithUnderglowEnabled
        end
    end)
end

hook.Add("OnEntityCreated", "ModernCarDealer.Hook.UnderglowPrep", function(eVehicle) if eVehicle:GetClass() == "prop_vehicle_jeep" or eVehicle:GetClass() == "prop_vehicle_airboat" then MCD_UnderglowSetup(eVehicle) end end)

local vRenderDist = 2000 ^ 2 
hook.Add("Think", "ModernCarDealer.Hook.UnderglowThink", function()
    for iIndex, tUData in pairs(ModernCarDealer.UnderglowList) do
        local eVehicle = tUData[1]
        local cColor = tUData[2]

        if not IsValid(eVehicle) then table.remove(ModernCarDealer.UnderglowList, iIndex) continue end

        if eVehicle:GetPos():DistToSqr(LocalPlayer():GetPos()) < vRenderDist and eVehicle.MCD_UnderglowState then
            local vPosCenter = eVehicle:OBBCenter()
            local vMins = eVehicle:GetCollisionBounds()
           
            local dlight = DynamicLight(iIndex)
            if (dlight) then
                dlight.pos = eVehicle:LocalToWorld(Vector(vPosCenter.x, vPosCenter.y, vMins.z))
                dlight.r = cColor.r
                dlight.g = cColor.g
                dlight.b = cColor.b
                dlight.brightness = 4
                dlight.Decay = 0
                dlight.Size = 500
                dlight.DieTime = CurTime() + 1
            end 
        end
    end
end)

