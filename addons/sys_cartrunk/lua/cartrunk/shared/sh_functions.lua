--[[
	AUTOMATIC COMPATIBILITY FUNCTIONS
]]
local function calculateVehicleWeight( eVehicle )
	if CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ] and CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].weight then
		CarTrunk.VehiclesWeight[ eVehicle:GetVehicleClass() ] = CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].weight
		return CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].weight
	end

	local fDistance = eVehicle:OBBMins():Distance( eVehicle:OBBMaxs() )
	local iWeight = math.ceil( fDistance / 50 ) * 50 -- only take multiple of 50

	CarTrunk.VehiclesWeight[ eVehicle:GetVehicleClass() ] = iWeight

	return iWeight
end
function CarTrunk:GetVehicleMaxWeight( eVehicle )
	if not IsValid( eVehicle ) then return end

	return CarTrunk.VehiclesWeight[ eVehicle:GetVehicleClass() ] or calculateVehicleWeight( eVehicle )
end

-- If the object weight is set in the config, it'll be saved as class. If not, it'll be saved as a model.
local function calculateObjectWeight( eEntity )
	if CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ] and CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ].weight then
		CarTrunk.ObjectWeight[ eEntity:GetClass() ] = CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ].weight
		return CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ].weight
	end

	local fDistance = eEntity:OBBMins():Distance( eEntity:OBBMaxs() )
	local iWeight = math.ceil( fDistance )

	CarTrunk.ObjectWeight[ eEntity:GetModel() ] = iWeight

	return iWeight
end
function CarTrunk:GetObjectWeight( eEntity )
	if not IsValid( eEntity ) then return end

	return CarTrunk.ObjectWeight[ eEntity:GetClass() ] or CarTrunk.ObjectWeight[ eEntity:GetModel() ] or calculateObjectWeight( eEntity )
end

--[[ 
	UTIL
]]
function CarTrunk:HasTrunk( eVehicle )
	if IsValid( eVehicle ) and eVehicle:IsVehicle() and eVehicle.GetVehicleClass then
		if CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ] and CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].hasTrunk == false then
			return false
		end
		return true
	end
end
function CarTrunk:GetVehicleWeight( xVehicle )
	if CarTrunk.VehicleTrunkWeight[ ( xVehicle.EntIndex and xVehicle:EntIndex() ) or xVehicle ] then
		return CarTrunk.VehicleTrunkWeight[ ( xVehicle.EntIndex and xVehicle:EntIndex() ) or xVehicle ]
	end

	local tTrunk = CarTrunk:GetVehicleTrunk( xVehicle )
	local iWeight = 0

	for sClass, tData in pairs( tTrunk or {} ) do
		for iID, tInfos in pairs( tData or {} ) do
			iWeight = iWeight + ( tInfos.Weight or 0 )
		end
	end

	return iWeight
end

function CarTrunk:IsEntityBlacklisted( eEntity )
	return ( CarTrunk.Config.SpecificEntities and CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ] and CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ].isBlacklisted )
end

function CarTrunk:IsEntityOwner( pPlayer, eEntity )
	if eEntity:GetClass() == "spawned_weapon" or eEntity:GetClass() == "spawned_ammo" or eEntity:GetClass() == "spawned_food" then
		return true
	end
	return ( eEntity.CPPIGetOwner and eEntity:CPPIGetOwner() == pPlayer ) or true
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          --76561198984335102
function CarTrunk:GetEntityType( eEntity )
	if eEntity:IsWeapon() then
		return "Weapon"
	else
		return CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ] and CarTrunk.Config.SpecificEntities[ eEntity:GetClass() ].category or "Miscellaneous"
	end

end

local trunkRightsModes = {
	[1] = function( pPlayer, eVehicle )
		return eVehicle:isKeysOwnedBy( pPlayer )
	end,
	[2] = function( pPlayer, eVehicle )
		return eVehicle:isMasterOwner( pPlayer )
	end,
	[3] = function( pPlayer, eVehicle )
		return not CarTrunk.VehicleLocked[ eVehicle:EntIndex() ]
	end,
}

function CarTrunk:AllowedToUseTrunk( pPlayer, eVehicle )
	return trunkRightsModes[ trunkRightsModes[ CarTrunk.Config.AllowedToUseTrunk ] and CarTrunk.Config.AllowedToUseTrunk or 1 ]( pPlayer, eVehicle ) 
end

function CarTrunk:DebugPrint( sString, pPlayer )
	if not CarTrunk.DebugMode then return end

	print( "[Advanced Car Trunk] " .. sString )

	if pPlayer and IsValid( pPlayer ) then
		pPlayer:ChatPrint( "[Advanced Car Trunk] " .. sString )
	end
end