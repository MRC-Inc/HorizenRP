net.Receive( "CarTrunk.NetworkTrunk", function( len )
	local shouldUpdateTrunk = net.ReadBool()
	local iVehicleIndex = net.ReadUInt( 32 )

	if shouldUpdateTrunk then
		local tVehicleTrunk = net.ReadTable()
		CarTrunk.VehicleTrunk[ iVehicleIndex ] = tVehicleTrunk
		CarTrunk.VehicleTrunkWeight[ iVehicleIndex ] = nil
	else
		CarTrunk.VehicleTrunkWeight[ iVehicleIndex ] = net.ReadUInt( 32 )
	end

	local shouldOpenMenu = net.ReadBool()
	if shouldOpenMenu then
		CarTrunk:OpenTrunk( Entity( iVehicleIndex ) )
	end
end )

net.Receive( "CarTrunk.NetworkVehiclesLock", function()
	CarTrunk.VehicleLocked = {}

	local iLenTable = net.ReadUInt( 16 ) or 1
	for i = 1, iLenTable do
		CarTrunk.VehicleLocked[ net.ReadUInt( 32 ) ] = net.ReadBool()
	end
end )

net.Receive( "CarTrunk.NetworkVehicleLock", function()
	local iVehicleIndex = net.ReadInt( 32 )
	CarTrunk.VehicleLocked[ iVehicleIndex ] = net.ReadBool() or false
end )