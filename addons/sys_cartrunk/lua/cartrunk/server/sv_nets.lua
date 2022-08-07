util.AddNetworkString( "CarTrunk.NetworkTrunk" )
util.AddNetworkString( "CarTrunk.TakeOutItem" )
util.AddNetworkString( "CarTrunk.NetworkVehiclesLock" )
util.AddNetworkString( "CarTrunk.NetworkVehicleLock" )
util.AddNetworkString( "CarTrunk.RequestTrunk" )

net.Receive( "CarTrunk.TakeOutItem", function( len, pPlayer )
	local eVehicle = net.ReadEntity()
	local sClass = net.ReadString()
	local iID = net.ReadInt( 32 )

	CarTrunk:TakeItem( pPlayer, eVehicle, sClass, iID )
end )

net.Receive( "CarTrunk.RequestTrunk", function( len, pPlayer )
	if CurTime() - ( pPlayer.LastTrunkRequest or 0 ) < 3 then return end
	pPlayer.LastTrunkRequest = CurTime()

	local eVehicle = net.ReadEntity()
	if not IsValid( eVehicle ) or not eVehicle:IsVehicle() then return end
	if not CarTrunk:AllowedToUseTrunk( pPlayer, eVehicle ) then return end

	CarTrunk:NetworkTrunk( eVehicle, pPlayer, true )
end )