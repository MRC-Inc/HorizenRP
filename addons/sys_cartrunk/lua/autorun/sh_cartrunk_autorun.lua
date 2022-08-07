CarTrunk = CarTrunk or {}
CarTrunk.Config = {}
CarTrunk.Config.Language = {}
CarTrunk.Config.SpecificEntities = {}
CarTrunk.Config.SpecificVehicles = {}
CarTrunk.Lang = {}
CarTrunk.VehiclesWeight = {}
CarTrunk.ServerTrunks = {}
CarTrunk.ObjectWeight = {}
CarTrunk.VehicleLocked = {}
CarTrunk.VehicleTrunkWeight = {}

CarTrunk.DebugMode = false
CarTrunk.CurrentVersion = "28898"

CarTrunk.Config.SpecificVehicles[ "" ] = {
	hasTrunk = false,
}

function CarTrunk:LoadLanguage()
	local chosenLang = CarTrunk.Config.Language or "en"

	local dirLang = "cartrunk/languages/" .. chosenLang .. ".lua"

	if not file.Exists(dirLang, "LUA") then chosenLang = "en" end

	if SERVER then
		AddCSLuaFile(dirLang)
	end
	CarTrunk.Lang = include(dirLang)
end


local loadingFilesMessage = [[
-----------------------------------------
	Car Trunk :
	LOADING FILES
-----------------------------------------
]]

local finishedLoadingFilesMessage = [[
-----------------------------------------
	Car Trunk :
	FILES LOADED
-----------------------------------------
]]

function CarTrunk:LoadFiles()

	if SERVER then 
		Msg( loadingFilesMessage )
	end

	local sharedFiles = file.Find( "cartrunk/shared/*", "LUA" )
	for k, v in pairs( sharedFiles ) do
		include( "cartrunk/shared/" .. v )

		if SERVER then
			AddCSLuaFile( "cartrunk/shared/" .. v )
		end

		print( "[ Advanced Car Dealer ] Loaded " .. v )
	end

	local configFiles = file.Find( "cartrunk/*", "LUA" )
	for k, v in pairs( configFiles ) do
		include( "cartrunk/" .. v )

		if SERVER then
			AddCSLuaFile( "cartrunk/" .. v )
		end

		print( "[ Advanced Car Dealer ] Loaded " .. v )
	end

	if SERVER then
		local serverFiles = file.Find( "cartrunk/server/*", "LUA" )
		for k, v in pairs( serverFiles ) do
			include( "cartrunk/server/" .. v )
			
			print( "[ Advanced Car Dealer ] Loaded " .. v )
		end
	end

	local clientFiles = file.Find( "cartrunk/client/*", "LUA" )
	for k, v in pairs( clientFiles ) do
		if CLIENT then
			include( "cartrunk/client/" .. v )
		elseif SERVER then
			AddCSLuaFile( "cartrunk/client/" .. v )
		end

		print( "[ Advanced Car Dealer ] Loaded " .. v )
	end

	CarTrunk:LoadLanguage()

	hook.Run( "CarTrunk:OnScriptLoaded" )

	if SERVER then 
		Msg( finishedLoadingFilesMessage )
	end
end

hook.Add( "PreGamemodeLoaded", "PreGamemodeLoaded.CarTrunk", function()
	CarTrunk:LoadFiles()
end )

function CarTrunk:L(sKey)
	return CarTrunk.Lang[sKey] or sKey
end