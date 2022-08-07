ModernCarDealer.Config.Language = "russian" 

ModernCarDealer.Config.ShowCarSpecificsInGarage = true -- Skin, Color, Bodygroups

ModernCarDealer.Config.ShowSortButton = true
ModernCarDealer.Config.CategoryState = 1 -- 1 = All closed, 2 = First open, 3 = All open

ModernCarDealer.Config.CurrencyOnLeft = true
ModernCarDealer.Config.CurrencySymbol = "$"

ModernCarDealer.Config.Use3d2d = true -- Changing this will require a restart

ModernCarDealer.Config.LockCarOnSpawn = true

ModernCarDealer.Config.MaxVehiclesOut = {
    ["default"] = 3, -- This is what is used if the player's rank is not below.
    ["vip"] = 5,
    ["vip+"] = 7,
}

ModernCarDealer.Config.MechanicBlacklist = { -- Use the vehicle class
    ["porcycletdm"] = true,
}

ModernCarDealer.Config.ReturnDistance = 2000 -- Set this to 0 for no limit

ModernCarDealer.Config.AllowRepairInDealer = true
ModernCarDealer.Config.RepairPrice = 500
ModernCarDealer.Config.SellPercentage = 0.50 -- The percent of the value of a car a player gets when selling it

ModernCarDealer.Config.UnderglowKey = KEY_G -- https://wiki.facepunch.com/gmod/Enums/KEY
ModernCarDealer.Config.SpawnWithUnderglowEnabled = false

ModernCarDealer.Config.MechanicKey = KEY_B -- https://wiki.facepunch.com/gmod/Enums/KEY Ignore this if the below is true
ModernCarDealer.Config.TriggerBasedMechanicUI = true -- Set to false to use a button

ModernCarDealer.Config.InsuranceToCarValuePercentage = 0.10
ModernCarDealer.Config.InsuranceMinimum = 1000
ModernCarDealer.Config.InsuranceMaximum = 100000

ModernCarDealer.Config.TestDrivingEnabled = true
ModernCarDealer.Config.TestDrivingPercentMoneyNeeded = 0.50 -- The percent of the value of a car a player needs to be able to test drive it
ModernCarDealer.Config.TestDriveTime = 45

ModernCarDealer.Config.PurchaseableColors = {
    ["Red"] = Color(255, 45, 32),
    ["Pink"] = Color(249, 92, 218),
    ["Yellow"] = Color(249, 221, 92),
    ["Green"] = Color(118, 153, 109),
    ["Blue"] = Color(45, 64, 121),
    ["White"] = Color(255, 255, 255),
    ["Silver"] = Color(143, 156, 164),
    ["Black"] = Color(35, 44, 48),
}

ModernCarDealer.Config.UnderglowPrice = 6500
ModernCarDealer.Config.BodygroupPrice = 1000
ModernCarDealer.Config.SkinPrice = 3000
ModernCarDealer.Config.ColorPrice = 2500

ModernCarDealer.Config.EngineUpgrades["Upgrade 1"] = {}
ModernCarDealer.Config.EngineUpgrades["Upgrade 1"].index = 2
ModernCarDealer.Config.EngineUpgrades["Upgrade 1"].price = 15000
ModernCarDealer.Config.EngineUpgrades["Upgrade 1"].horsepowerincrease = 200

ModernCarDealer.Config.EngineUpgrades["Upgrade 2"] = {}
ModernCarDealer.Config.EngineUpgrades["Upgrade 2"].index = 3
ModernCarDealer.Config.EngineUpgrades["Upgrade 2"].price = 30000
ModernCarDealer.Config.EngineUpgrades["Upgrade 2"].horsepowerincrease = 300

ModernCarDealer.Config.EngineUpgrades["Upgrade 3"] = {}
ModernCarDealer.Config.EngineUpgrades["Upgrade 3"].index = 4
ModernCarDealer.Config.EngineUpgrades["Upgrade 3"].price = 60000
ModernCarDealer.Config.EngineUpgrades["Upgrade 3"].horsepowerincrease = 400

ModernCarDealer.Config.AdminGroups = {
    ["owner"] = true,
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
}

ModernCarDealer.Config.PlayerCheck = {
    ["VIP Check"] = {
        function(pPlayer) return pPlayer:GetUserGroup() == "VIP" or pPlayer:GetUserGroup() == "VIP+" or (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()] or false) end,
        "You are not a VIP user, please donate to access this.",
        false -- Should this check apply to retrieving the vehicle
    },
    ["Police Check"] = {
        function(pPlayer) return pPlayer:isCP() end,
        "You are not a police officer.",
        true -- Should this check apply to retrieving the vehicle
    },
    --[[
    ["Team Check"] = {
        function(pPlayer)
            local teams = {TEAM_EXAMPLE1, TEAM_EXAMPLE2}

            return table.HasValue(teams, pPlayer:Team())
        end,
        "You are not the right team.",
        false -- Should this check apply to retrieving the vehicle
    },
    ]]--
}

local sConfigTheme = "dark"

if sConfigTheme == "dark" then

    ModernCarDealer.Config.PrimaryColor = Color(42, 42, 42)  
    ModernCarDealer.Config.SecondaryColor = Color(29, 29, 29)
    ModernCarDealer.Config.AccentColor = Color(135, 64, 216)
    ModernCarDealer.Config.TextColor =  Color(255, 255, 255)
    ModernCarDealer.Config.Light = false

elseif sConfigTheme == "light" then

    ModernCarDealer.Config.PrimaryColor = Color(220, 220, 220)
    ModernCarDealer.Config.SecondaryColor = Color(135, 64, 216) 
    ModernCarDealer.Config.AccentColor = Color(135, 64, 216)
    ModernCarDealer.Config.TextColor =  Color(255, 255, 255)
    ModernCarDealer.Config.Light = true

elseif sConfigTheme == "mytheme" then

    ModernCarDealer.Config.PrimaryColor = Color(42, 42, 42)  
    ModernCarDealer.Config.SecondaryColor = Color(29, 29, 29)
    ModernCarDealer.Config.AccentColor = Color(135, 64, 216)
    ModernCarDealer.Config.TextColor =  Color(255, 255, 255)
    ModernCarDealer.Config.Light = false

end

ModernCarDealer:UpdateColors()