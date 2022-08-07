ModernCarDealer = ModernCarDealer or {}
ModernCarDealer.Config = ModernCarDealer.Config or {}
ModernCarDealer.Config.EngineUpgrades = {} 

MsgC(Color(135, 64, 216), "\n------------------------------------------------------------------\n")
MsgC(color_white, "Modern Car Dealer", Color(135, 64, 216), " > ", color_white, "Addon Loaded\n")
MsgC(Color(135, 64, 216), "------------------------------------------------------------------\n\n")

function ModernCarDealer:UpdateColors()
    if CLIENT then
        include("moderncardealer/client/cl_gui.lua")
        include("moderncardealer/client/cl_admin.lua")
        include("moderncardealer/client/cl_derma.lua")
    end
end

if (SERVER) then
    resource.AddWorkshop("2532231885")
    
    include("moderncardealer/sh_config.lua")
    include("moderncardealer/language/"..ModernCarDealer.Config.Language..".lua")

    include("moderncardealer/server/sv_functions.lua")
    include("moderncardealer/server/sv_net.lua")
    include("moderncardealer/server/sv_hooks.lua")

    AddCSLuaFile("moderncardealer/sh_config.lua")
    AddCSLuaFile("moderncardealer/language/"..ModernCarDealer.Config.Language..".lua")

    AddCSLuaFile("moderncardealer/client/cl_derma.lua")
    AddCSLuaFile("moderncardealer/client/cl_gui.lua")
    AddCSLuaFile("moderncardealer/client/cl_util.lua")
    AddCSLuaFile("moderncardealer/client/cl_font.lua")
    AddCSLuaFile("moderncardealer/client/cl_admin.lua")
    AddCSLuaFile("moderncardealer/client/cl_net.lua")
else
    include("moderncardealer/sh_config.lua")
    include("moderncardealer/language/"..ModernCarDealer.Config.Language..".lua")

    include("moderncardealer/client/cl_derma.lua")
    include("moderncardealer/client/cl_gui.lua")
    include("moderncardealer/client/cl_util.lua")
    include("moderncardealer/client/cl_font.lua")
    include("moderncardealer/client/cl_admin.lua")
    include("moderncardealer/client/cl_net.lua")
end





















-- V 2.0.2 IGNORE THIS IT IS ONLY FOR USERS WHO FORGET TO TRANSFER CONFIG
ModernCarDealer.Config.MechanicKey = ModernCarDealer.Config.MechanicKey or KEY_B
ModernCarDealer.Config.TriggerBasedMechanicUI = ModernCarDealer.Config.TriggerBasedMechanicUI or true

ModernCarDealer.Config.InsuranceToCarValuePercentage = ModernCarDealer.Config.InsuranceToCarValuePercentage or 0.10
ModernCarDealer.Config.InsuranceMinimum = ModernCarDealer.Config.InsuranceMinimum or 1000
ModernCarDealer.Config.InsuranceMaximum = ModernCarDealer.Config.InsuranceMaximum or 100000

-- V 2.1.3 IGNORE THIS IT IS ONLY FOR USERS WHO FORGET TO TRANSFER CONFIG
ModernCarDealer.Config.CategoryState = ModernCarDealer.Config.CategoryState or 1

-- V 2.2.9 IGNORE THIS IT IS ONLY FOR USERS WHO FORGET TO TRANSFER CONFIG
ModernCarDealer.Config.MechanicBlacklist = ModernCarDealer.Config.MechanicBlacklist or {}