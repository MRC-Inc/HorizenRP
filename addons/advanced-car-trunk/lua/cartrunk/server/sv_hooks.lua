hook.Add( "PlayerButtonDown", "CarTrunk.PlayerButtonDown", function( pPlayer, iKey )
	pPlayer.CarTrunk = pPlayer.CarTrunk or {}
	pPlayer.CarTrunk.keyCurrentlyPressed = pPlayer.CarTrunk.keyCurrentlyPressed or {}

	pPlayer.CarTrunk.keyCurrentlyPressed[ iKey ] = true

	if pPlayer.CarTrunk.keyCurrentlyPressed[ CarTrunk.Config.KeyOne ] and pPlayer.CarTrunk.keyCurrentlyPressed[ CarTrunk.Config.KeyTwo ] then

		local eEntity = pPlayer:GetEyeTrace().Entity

		if not IsValid( eEntity ) then return end

		local trunkVehicle
		for iVehicleIndex, eVehicle in pairs( CarTrunk.ServerTrunks ) do 
			if CarTrunk:CanStoreItem( pPlayer, eVehicle, eEntity ) then
				trunkVehicle = eVehicle
				break
			end
		end

		if IsValid( trunkVehicle ) then
			CarTrunk:StoreItem( pPlayer, trunkVehicle, eEntity )
		end
	end
end )

hook.Add( "PlayerButtonUp", "CarTrunk.PlayerButtonUp", function( pPlayer, iKey ) 
	if pPlayer.CarTrunk and pPlayer.CarTrunk.keyCurrentlyPressed and pPlayer.CarTrunk.keyCurrentlyPressed[ iKey ] then
		pPlayer.CarTrunk.keyCurrentlyPressed[ iKey ] = nil
	end
end )

hook.Add( "playerBuyVehicle", "CarTrunk.playerBuyVehicle", function( pPlayer, eVehicle )
	if not CarTrunk:HasTrunk( eVehicle ) then return end
	CarTrunk:NetworkTrunk( eVehicle, pPlayer, false )
end )


-- I need to broadcast if the vehicle is locked or not for the 3rd allowed mod
hook.Add( "onKeysUnlocked", "CarTrunk.onKeysUnlocked", function( eVehicle )
	if CarTrunk.Config.AllowedToUseTrunk ~= 3 then return end

	CarTrunk.VehicleLocked[ eVehicle:EntIndex() ] = false

	net.Start( "CarTrunk.NetworkVehicleLock" )
		net.WriteInt( eVehicle:EntIndex(), 32 )
		net.WriteBool( false )
	net.Broadcast()
end )

hook.Add( "onKeysLocked", "CarTrunk.onKeysLocked", function( eVehicle )
	if CarTrunk.Config.AllowedToUseTrunk ~= 3 then return end

	CarTrunk.VehicleLocked[ eVehicle:EntIndex() ] = true

	net.Start( "CarTrunk.NetworkVehicleLock" )
		net.WriteInt( eVehicle:EntIndex(), 32 )
		net.WriteBool( true )
	net.Broadcast()
end )

hook.Add( "PlayerInitialSpawn", "CarTrunk.PlayerInitialSpawn", function( pPlayer )
	timer.Simple(1, function()
		if not IsValid( pPlayer ) then return end
		if not CarTrunk.VehicleLocked or not istable( CarTrunk.VehicleLocked ) or table.IsEmpty( CarTrunk.VehicleLocked ) then return end

		net.Start( "CarTrunk.NetworkVehiclesLock" )
			net.WriteUInt( #CarTrunk.VehicleLocked, 16 )
			for k, v in pairs( CarTrunk.VehicleLocked ) do
				net.WriteUInt( k, 32 )
				net.WriteBool( v )
			end
		net.Send( pPlayer )
	end )
end )
