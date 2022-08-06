function CarTrunk:GetVehicleTrunk( xVehicle )
	if isnumber( xVehicle ) then
		return CarTrunk.VehicleTrunk[ iVehicleIndex ] or {}
	elseif type( xVehicle ) == "Vehicle" then
		return CarTrunk.VehicleTrunk[ xVehicle:EntIndex() ] or {}
	end
end
