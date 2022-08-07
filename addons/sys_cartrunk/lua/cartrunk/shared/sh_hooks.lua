hook.Add( "OnEntityCreated", "CarTrunk.OnEntityCreated", function( eEntity ) 
	timer.Simple( 1, function()
		if not IsValid( eEntity ) or not CarTrunk:HasTrunk( eEntity ) then return end 

		CarTrunk:DebugPrint( "The object spawned has a trunk", pPlayer )
		CarTrunk.ServerTrunks[ eEntity:EntIndex() ] = eEntity
	end )
end )


hook.Add( "EntityRemoved", "CarTrunk.EntityRemoved", function( eEntity )
	if not IsValid( eEntity )  or not eEntity.EntIndex then return end

	CarTrunk.ServerTrunks[ eEntity:EntIndex() ] = nil

	-- DarkRP shipment max limit compatibility
	if SERVER and CarTrunk:HasTrunk( eEntity ) then
		local tTrunk = CarTrunk:GetVehicleTrunk( eEntity ) or {}

		for sClass, tEntities in pairs( tTrunk or {} ) do
			for iID, tInfos in pairs( tEntities or {} ) do
				if not tInfos.EntityTableValue or not IsValid( tInfos.EntityTableValue.Inventory_Entity_Owner ) or not tInfos.EntityTableValue.DarkRPItem then 
					continue
				end

				tInfos.EntityTableValue.Inventory_Entity_Owner:removeCustomEntity( tInfos.EntityTableValue.DarkRPItem )
			end
		end

	end

end )
