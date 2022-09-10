ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.PrintName = "Bank"
ENT.Category = "ItemStore"

ENT.Spawnable = true
ENT.AdminOnly = true

if SERVER then
	AddCSLuaFile()

	function ENT:Initialize()
		self:SetModel( "models/props_lab/reciever_cart.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:GetPhysicsObject():EnableMotion( false )
	end

	function ENT:SpawnFunction( pl, trace, class )
		local ent = ents.Create( class )
		ent:SetPos( trace.HitPos + trace.HitNormal * 16 )
		ent:Spawn()

		return ent
	end

	function ENT:Use( pl )
		if not IsValid( pl ) then return end

		pl.Bank:Sync()
		pl:OpenContainer( pl.Bank:GetID(), itemstore.Translate( "bank" ) )
	end

	concommand.Add( "itemstore_savebanks", function( pl )
		if not game.SinglePlayer() and IsValid( pl ) then return end

		local banks = {}

		for _, ent in ipairs( ents.FindByClass( "itemstore_bank" ) ) do
			table.insert( banks, {
				Position = ent:GetPos(),
				Angles = ent:GetAngles()
			} )
		end

		file.Write( "itemstore/banks/" .. game.GetMap() .. ".txt", util.TableToJSON( banks ) )

		print( "Banks for map " .. game.GetMap() .. " saved." )
	end )

	hook.Add( "InitPostEntity", "ItemStoreSpawnBanks", function()
		local banks = util.JSONToTable( file.Read( "itemstore/banks/" .. game.GetMap() .. ".txt", "DATA" ) or "" ) or {}

		for _, data in ipairs( banks ) do
			local bank = ents.Create( "itemstore_bank" )
			bank:SetPos( data.Position )
			bank:SetAngles( data.Angles )
			bank:Spawn()
		end
	end )
else
	function ENT:DrawTranslucent()
		self:DrawModel()

		local text = itemstore.Translate( "bank" )
		local font = "DermaLarge"

		surface.SetFont( font )
		local textw, texth = surface.GetTextSize( text )
		local w = 5 + textw + 5
		local h = 2 + texth + 2
		local x, y = -w / 2, -h / 2

		cam.Start3D2D( self:GetPos() + self:GetAngles():Up() * 50, Angle( 0, CurTime() * 45, 90 ), 0.35 )
			surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
			surface.DrawRect( x, y, w, h )

			draw.SimpleTextOutlined( text, font, 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0 ) )
		cam.End3D2D()
	end
end
