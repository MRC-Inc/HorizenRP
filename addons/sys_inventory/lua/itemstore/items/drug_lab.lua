ITEM.Name = itemstore.Translate( "druglab_name" )
ITEM.Description = itemstore.Translate( "druglab_desc" )
ITEM.Model = "models/props_lab/crematorcase.mdl"
ITEM.HighlightColor = itemstore.config.HighlightColours.Factories
ITEM.Base = "base_darkrp"

function ITEM:SaveData( ent )
	self:SetData( "Price", ent:Getprice() )
	self:SetData( "Owner", ent:Getowning_ent() )
end

function ITEM:LoadData( ent )
	ent:Setprice( self:GetData( "Price" ) )
	
	local owner = self:GetData( "Owner" )
	if not IsValid( owner ) then
		owner = player.GetAll()[ 1 ]
	end

	ent:Setowning_ent( owner )
end