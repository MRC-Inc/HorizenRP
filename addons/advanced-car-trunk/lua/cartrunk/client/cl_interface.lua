CarTrunk.VehicleTrunk = CarTrunk.VehicleTrunk or {}

local iScale = 0.01
local menuSize = { x = 2000, y = 740 + 35 }
local tMat = {
	[ "key" ] = Material( "materials/car-trunk/key.png", "smooth" ),
	[ "full-circle" ] = Material( "materials/car-trunk/full-circle.png" ),
	[ "cancel" ] = Material( "materials/car-trunk/cancel.png" ),
	[ "gradient-l" ] = Material( "vgui/gradient-l" ),
	[ "gradient-r" ] = Material( "vgui/gradient-r" ),
}
local tColors = {
	[ "white" ] = Color( 255, 255, 255, 255 ),
	[ "grey-alpha" ] = Color( 40, 40, 40, 200 ),
	[ "grey" ] = Color( 40, 40, 40, 255 ),
	[ "orange-alpha" ] = Color( 255, 109, 16, 200 ),
	[ "orange" ] = Color( 255, 109, 16, 255 ),
	[ "black" ] = Color( 0, 0, 0, 255 ),
	[ "ui-background" ] = Color( 22, 23, 28, 200 ),
	[ "orange-shadow" ] = Color( 105, 47, 12, 100 ),
	[ "white-shadow" ] = Color( 46, 47, 52 ),
	[ "light-white" ] = Color( 200, 200, 200 ),
	[ "content-background" ] = Color( 100, 100, 100, 10 ),
	[ "separation-bar" ] = Color( 69, 69, 73 ),
	[ "model-light" ] = Color( 100, 100, 100 ),
	[ "scrollbar-background" ] = Color( 100, 100, 100, 100 )
}

local tWeightColors = {
	[ 1 ] = Color( 35, 100, 153 ), -- 0 to 50
	[ 2 ] = Color( 90, 146, 41 ), -- 50 to 100
	[ 3 ] = Color( 116, 82, 114 ), -- 100 to 150
	[ 4 ] = Color( 201, 135, 41 ), -- 150 to 200
	[ 5 ] = Color( 192, 57, 43 ), -- 200 and +
}

local function drawCircle( fPosx, fPosy, fSizex, fSizey, tColor )
	surface.SetDrawColor( tColor )
	surface.SetMaterial( tMat[ "full-circle" ] )
	surface.DrawTexturedRect( fPosx, fPosy, fSizex, fSizey )
end

function CarTrunk:OpenTrunk( eVehicle )
	local tTrunk = CarTrunk:GetVehicleTrunk( eVehicle )
	local tListedByType = {}
	local tItemTitles = {}
	local tItems = {}

	local dFrame = vgui.Create( "DFrame")
	surface.PlaySound( "car-trunk/open.mp3" )
	dFrame:SetSize( ScrW(), ScrH() )
	dFrame:SetAlpha( 0 )
	dFrame:AlphaTo( 255, 1 )
	dFrame:ShowCloseButton( false )
	dFrame:MakePopup()
	dFrame:SetTitle( "" )
	function dFrame:OnClose()
		surface.PlaySound( "car-trunk/close.mp3" )
		dFrame:AlphaTo( 0, 0.3, 0, function()
			if IsValid( dFrame ) then
				CarTrunk.LastTrunkClosed = CurTime()
				dFrame:Remove()
			end
		end )
	end
	function dFrame:Paint( w, h )
		Derma_DrawBackgroundBlur( self, CurTime() )
		draw.RoundedBox( 0, 0, 0, w, h, tColors[ "ui-background"] )
	end
	function dFrame:Think()
		if not IsValid( eVehicle ) then
			self:OnClose()
		end
	end
	CarTrunk.TrunkOpened = dFrame

	local dCloseButton = vgui.Create( "DPanel", dFrame )
	dCloseButton:SetSize( ScrW(), ScrH() )
	dCloseButton:SetText( "" )
	function dCloseButton:Paint( w, h )
	end
	function dCloseButton:OnMousePressed( MouseCode )
		if MouseCode == MOUSE_FIRST then
			dFrame:OnClose()
		end
	end

	local sVehicleName = ( IsValid( eVehicle ) and list.Get("Vehicles")[ eVehicle:GetVehicleClass() ] and list.Get("Vehicles")[ eVehicle:GetVehicleClass() ].Name ) or "Vehicle"

	local dHeader = vgui.Create( "DPanel", dFrame )
	dHeader:Dock( TOP )
	dHeader:SetTall( ScrH() * 0.15 )
	function dHeader:Paint( w, h )
		draw.SimpleText( string.upper( sVehicleName ), "CarTrunk:70T", w / 2 + 5, ( h - 40 ) / 2 + 5, tColors[ "orange-shadow" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( string.upper( sVehicleName ), "CarTrunk:70T", w / 2, ( h - 40 ) / 2, tColors[ "orange" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		draw.SimpleText( CarTrunk:L( "CarTrunk" ), "CarTrunk:40T", w / 2 + 5, ( h + 40 ) / 2 + 5, tColors[ "white-shadow" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( CarTrunk:L( "CarTrunk" ), "CarTrunk:40T", w / 2, ( h + 40 ) / 2, tColors[ "white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	function dHeader:OnMousePressed( MouseCode )
		if MouseCode == MOUSE_FIRST then
			dFrame:OnClose()
		end
	end

	if not tTrunk or not istable( tTrunk ) or table.IsEmpty( tTrunk ) then
		local dNothing = vgui.Create( "DLabel", dFrame )
		dNothing:Dock( FILL )
		dNothing:SetText( CarTrunk:L( "NothingInTrunk" ) )
		dNothing:SetFont( "CarTrunk:70T" )
		dNothing:SetContentAlignment( 5 )
		function dNothing:OnMousePressed( MouseCode )
			if MouseCode == MOUSE_FIRST then
				dFrame:OnClose()
			end
		end
		return
	end

	local oSelectedItem
	local dSelected
	local weightLerpValue = math.max( CarTrunk:GetVehicleWeight( eVehicle ) - 40, 0 )

	local function UpdateSelection()
		if not IsValid( eVehicle ) then if IsValid( dFrame ) then dFrame:OnClose() end return end
		if IsValid( dSelected ) then dSelected:Remove() end
		if not oSelectedItem then return end

		local tData = oSelectedItem.Data
		local sClass = oSelectedItem.Class
		local isWeapon = tData.Type == "Weapon"
		local sPrintName = string.Replace( list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ sClass ] and list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ sClass ].PrintName or sClass or "N/A", "_", " " )
		local sCategory = list.Get(  isWeapon and "Weapon" or "SpawnableEntities" )[ sClass ] and list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ sClass ].Category or "N/A"

		dSelected = vgui.Create( "DPanel", dFrame )
		dSelected:Dock( RIGHT )
		dSelected:DockMargin( 25, 25, ( ScrW() * 0.3 > 500 and ScrW() * 0.2 or ScrW() * 0.05), 25 )
		dSelected:SetWide( ( ScrW() * 0.3 > 500 and ScrW() * 0.2 or ScrW() * 0.3 ) )
		function dSelected:OnMousePressed( MouseCode )
			if MouseCode == MOUSE_FIRST then
				dFrame:OnClose()
			end
		end
		dSelected.Paint = nil

		local dInformationWeight = vgui.Create( "DScrollPanel", dSelected )
		dInformationWeight:Dock( TOP )
		dInformationWeight:DockMargin( 0, 0, 0, 20 )
		dInformationWeight:SetTall( 95 )
		function dInformationWeight:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, tColors[ "content-background" ] )
			
			draw.RoundedBox( 0, 0, 0, 2, 2, tColors[ "light-white" ] )
			draw.RoundedBox( 0, 0, h - 2, 2, 2, tColors[ "light-white" ] )

			draw.RoundedBox( 0, w - 2, 0, 2, 2, tColors[ "light-white" ] )
			draw.RoundedBox( 0, w - 2, h - 2, 2, 2, tColors[ "light-white" ] )
		end

		local dTitleWeight = vgui.Create( "DPanel", dInformationWeight )
		dTitleWeight:Dock( TOP )
		dTitleWeight:DockMargin( 5, 10, 5, 0  )
		dTitleWeight:SetTall( 30 )
		function dTitleWeight:Paint( w, h )
			draw.SimpleText( string.upper( CarTrunk:L( "CurrentTrunkWeight" ) ), "CarTrunk:35TB", w / 2 + 5, h / 2 + 5, tColors[ "white-shadow" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( string.upper( CarTrunk:L( "CurrentTrunkWeight" ) ), "CarTrunk:35TB", w / 2, h / 2, tColors[ "white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		local dWeightBox = vgui.Create( "DPanel", dInformationWeight )
		dWeightBox:Dock( TOP )
		dWeightBox:DockMargin( 10, 0, 10, 10  )
		dWeightBox:SetTall( 40 )
		
		function dWeightBox:Paint( w, h )

			if weightLerpValue ~= CarTrunk:GetVehicleWeight( eVehicle ) then
				if weightLerpValue < CarTrunk:GetVehicleWeight( eVehicle ) then
					weightLerpValue = math.Clamp( weightLerpValue + 1, 0, CarTrunk:GetVehicleWeight( eVehicle ) )
				else
					weightLerpValue = math.Clamp( weightLerpValue - 1, CarTrunk:GetVehicleWeight( eVehicle ), CarTrunk:GetVehicleMaxWeight( eVehicle ) )
				end
			end

			draw.SimpleText( weightLerpValue .. "/" .. CarTrunk:GetVehicleMaxWeight( eVehicle ) , "CarTrunk:30T", w / 2, h - 6, tColors[ "light-white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

			draw.RoundedBox( 4, 0, h - 5, w, 5, tColors[ "grey" ] )
			draw.RoundedBox( 4, 0, h - 5, w * weightLerpValue / CarTrunk:GetVehicleMaxWeight( eVehicle ), 5, tColors[ "white" ] )
		end

		local dSelectedContent = vgui.Create( "DScrollPanel", dSelected )
		dSelectedContent:Dock( TOP )
		dSelectedContent:SetTall( math.min( dSelected:GetWide() + 20 + 30 * 2 + 40, ScrH() -  95 - 10 - 20 - 25 - 50 - ScrH() * 0.15 ) )
		function dSelectedContent:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, tColors[ "content-background" ] )
			
			draw.RoundedBox( 0, 0, 0, 2, 2, tColors[ "light-white" ] )
			draw.RoundedBox( 0, 0, h - 2, 2, 2, tColors[ "light-white" ] )

			draw.RoundedBox( 0, w - 2, 0, 2, 2, tColors[ "light-white" ] )
			draw.RoundedBox( 0, w - 2, h - 2, 2, 2, tColors[ "light-white" ] )
		end
		local sbar = dSelectedContent:GetVBar( )
		sbar:SetHideButtons( true )
		function sbar:Paint( w, h )
			draw.RoundedBox( 2, 1, 0, 2, h, tColors[ "scrollbar-background" ] )
		end	
		sbar:SetWide( 5 )
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 4, 0, 0, 4, h, tColors[ "white" ] )
		end
		function dSelectedContent:OnMousePressed( MouseCode )
			if MouseCode == MOUSE_FIRST then
				dFrame:OnClose()
			end
		end

		local dPreviewModel = vgui.Create( "DModelPanel", dSelectedContent )
		dPreviewModel:Dock( TOP )
		dPreviewModel:DockMargin( 10, 10, 10, 10 )
		dPreviewModel:SetTall( dSelected:GetWide() - 20 )
		dPreviewModel:SetModel( tData.Model )

		if tData.Skin then
			dPreviewModel.Entity:SetSkin( tData.Skin )
		end

		if tData.Bodygroups then
			for iID, iBdgr in pairs ( tData.Bodygroups or {} ) do
				dPreviewModel.Entity:SetBodygroup( iID, iBdgr )
			end
		end

		if tData.SubMaterials then
			for iIndex, sSubMat in pairs( tData.SubMaterials or {} ) do
				dPreviewModel.Entity:SetSubMaterial( iIndex, sSubMat )
			end
		end

		if tData.Color then
			dPreviewModel.Entity:SetColor( tData.Color )
		end

		local mn, mx = dPreviewModel.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
		size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
		size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )
		dPreviewModel.LerpPos = isWeapon and -45 or 45
		function dPreviewModel:LayoutEntity(ent)
			if self:IsDown() then
				local xCursPos, yCursPos = self:CursorPos()
				if not self.xAng then self.xAng = xCursPos end

				self.LerpPos = Lerp(RealFrameTime()*4, self.LerpPos, xCursPos - 180)
				ent:SetAngles(Angle( 0, self.LerpPos, 0))
			else
				self.xAng = nil
			end
		end
		dPreviewModel:SetFOV( 50 )
		dPreviewModel:SetCamPos( Vector( size, size, size ) )
		dPreviewModel:SetLookAt( ( mn + mx ) * 0.5 )
		dPreviewModel.Entity:SetAngles( Angle( 0, isWeapon and -45 or 45, 0 ) )
		dPreviewModel:SetDirectionalLight( BOX_TOP, tColors[ "model-light" ] )

		local dItemName = vgui.Create( "DPanel", dSelectedContent )
		dItemName:Dock( TOP )
		dItemName:SetTall( 30 )
		function dItemName:Paint( w, h )
			draw.SimpleText( string.upper( sPrintName ), "CarTrunk:35TB", w / 2 + 5, h / 2 + 5, tColors[ "white-shadow" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( string.upper( sPrintName ), "CarTrunk:35TB", w / 2, h / 2, tColors[ "white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		local dItemCategory = vgui.Create( "DPanel", dSelectedContent )
		dItemCategory:Dock( TOP )
		dItemCategory:SetTall( 30 )
		function dItemCategory:Paint( w, h )
			draw.SimpleText( string.upper( sCategory ), "CarTrunk:30T", w / 2, h / 2, tColors[ "light-white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		local dTakeOutButton = vgui.Create( "DButton", dSelectedContent )
		dTakeOutButton:Dock( TOP )
		dTakeOutButton:DockMargin( 10, 10, 10, 10 )
		dTakeOutButton:SetTall( 40 )
		dTakeOutButton:SetText( "" )
		function dTakeOutButton:Paint( w, h )
			draw.RoundedBox( 3, 0, 0, w, h, ColorAlpha( tColors[ "orange" ], 120 ) )
			draw.SimpleText( CarTrunk:L( "TakeOut" ), "CarTrunk:30TB", w / 2 + 2, h / 2 + 2, tColors[ "white-shadow" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( CarTrunk:L( "TakeOut" ), "CarTrunk:30TB", w / 2, h / 2, tColors[ "white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		function dTakeOutButton:DoClick()
			surface.PlaySound("UI/buttonclick.wav")
			net.Start( "CarTrunk.TakeOutItem" )
				net.WriteEntity( eVehicle )
				net.WriteString( oSelectedItem.RealClass )
				net.WriteInt( oSelectedItem.ID, 32)
			net.SendToServer()

			if IsValid( oSelectedItem ) then
				if oSelectedItem.TableID then
					if tListedByType[ tData.Type ] and tListedByType[ tData.Type ][ oSelectedItem.TableID ] then
						tListedByType[ tData.Type ][ oSelectedItem.TableID ] = nil
					end
				end
				oSelectedItem:Remove()
			end

			if tData.Type then
				if table.IsEmpty( tListedByType[ tData.Type ] ) then
					if IsValid( tItemTitles[ tData.Type ] ) then
						tItemTitles[ tData.Type ]:Remove()
					end
				end
			end

			oSelectedItem = nil
			for k, v in pairs( tItems ) do
				if not IsValid( v ) then continue end
				oSelectedItem = v
				break
			end

			if not oSelectedItem and IsValid( dSelected ) then
				dSelected:Remove()
				local dNothing = vgui.Create( "DLabel", dFrame )
				dNothing:Dock( FILL )
				dNothing:SetText( CarTrunk:L( "NothingInTrunk" ) )
				dNothing:SetFont( "CarTrunk:70T" )
				dNothing:SetContentAlignment( 5 )
			else
				UpdateSelection()
			end
		end
	end

	local dItemList = vgui.Create( "DScrollPanel", dFrame )
	dItemList:Dock( FILL )
	dItemList:DockMargin( ( ScrW() * 0.3 > 500 and ScrW() * 0.2 or ScrW() * 0.05 ), 25, 25, 80 )
	local sbar = dItemList:GetVBar( )
	sbar:SetHideButtons( true )
	function sbar:Paint( w, h )
		draw.RoundedBox( 2, 1, 0, 2, h, tColors[ "scrollbar-background" ] )
	end	
	sbar:SetWide( 5 )
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 4, 0, 0, 4, h, tColors[ "white" ] )
	end
	function dItemList:OnMousePressed( MouseCode )
		if MouseCode == MOUSE_FIRST then
			dFrame:OnClose()
		end
	end

	local animationTime = 0
	local function DrawItem( iID, sClass, tData, isWeapon, iTableID )
		local dItemPanel = vgui.Create( "DButton", dItemList )
		dItemPanel:Dock( TOP )
		dItemPanel:DockMargin( 0, 0, 10, 8 )
		dItemPanel:SetTall( 75 )
		dItemPanel:SetText( "" )
		dItemPanel:SetAlpha( 0 )
		if not IsValid( oSelectedItem ) then
			oSelectedItem = dItemPanel
		end

		dItemPanel.Data = tData
		dItemPanel.ID = iID
		dItemPanel.TableID = iTableID
		dItemPanel.Class = tData.WeaponClass or sClass
		dItemPanel.RealClass = sClass
		dItemPanel.HoverLevel = 0

		local sPrintName = string.Replace( list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ dItemPanel.Class ] and list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ dItemPanel.Class ].PrintName or dItemPanel.Class or "N/A", "_", " " )
		local sCategory = list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ dItemPanel.Class ] and list.Get( isWeapon and "Weapon" or "SpawnableEntities" )[ dItemPanel.Class ].Category or "N/A"

		local dItemModel = vgui.Create( "DModelPanel", dItemPanel )
		dItemModel:Dock( LEFT )
		dItemModel:DockMargin( 10 + 25, 0, 25, 0 )
		dItemModel:SetWide( dItemPanel:GetTall() )
		dItemModel:SetModel( tData.Model )

		if tData.Skin then
			dItemModel.Entity:SetSkin( tData.Skin )
		end

		if tData.Bodygroups then
			for iID, iBdgr in pairs ( tData.Bodygroups or {} ) do
				dItemModel.Entity:SetBodygroup( iID, iBdgr )
			end
		end
		
		if tData.SubMaterials then
			for iIndex, sSubMat in pairs( tData.SubMaterials or {} ) do
				dItemModel.Entity:SetSubMaterial( iIndex, sSubMat )
			end
		end

		if tData.Color then
			dItemModel.Entity:SetColor( tData.Color )
		end

		dItemModel:SetVisible( false )
		local mn, mx = dItemModel.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
		size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
		size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )
		-- dItemModel.LerpPos = 0
		function dItemModel:LayoutEntity(ent)
			-- if self:IsDown() then
			-- 	local xCursPos, yCursPos = self:CursorPos()
			-- 	if not self.xAng then self.xAng = xCursPos end

			-- 	self.LerpPos = Lerp(RealFrameTime()*4, self.LerpPos, xCursPos - 180)
			-- 	ent:SetAngles(Angle(0, self.LerpPos, 0))
			-- else
			-- 	self.xAng = nil
			-- end
		end
		dItemModel:SetFOV( 50 )
		dItemModel:SetCamPos( Vector( size, size, size ) )
		dItemModel:SetLookAt( ( mn + mx ) * 0.5 )
		dItemModel.Entity:SetAngles( Angle( -15, isWeapon and -45 or 45, 0 ) )
		dItemModel:SetDirectionalLight( BOX_TOP, tColors[ "model-light" ] )

		local iWeight = math.Clamp( math.ceil( tData.Weight / 50 ), 1, 5 )

		dItemPanel:AlphaTo( 255, animationTime, #tItems * animationTime, function()
			if IsValid( dItemModel ) then
				dItemModel:SetVisible( true  )
			end
		end )
		local gradientAlpha = 0
		function dItemPanel:Paint( w, h )
			local tColorBack = ( IsValid( oSelectedItem ) and oSelectedItem == self ) and ColorAlpha( tColors[ "orange" ], 100 ) or tColors[ "content-background" ]

			-- Model background
			local modelBackgroundSize = dItemModel:GetWide() + 50 + 10 + 10
			draw.RoundedBox( 0, 0, 0, 5, h, tWeightColors[ iWeight ] )
			draw.RoundedBox( 0, 0, 0, modelBackgroundSize, h, ColorAlpha( tWeightColors[ iWeight ], 70 ) )

			-- Right
			draw.RoundedBox( 0, w - dItemPanel:GetTall(), 0, dItemPanel:GetTall(), h, tColorBack )

			draw.SimpleText( string.upper( CarTrunk:L( "Weight" ) ), "CarTrunk:20T", w - dItemPanel:GetTall()/2, 10, tColors[ "white" ], TEXT_ALIGN_CENTER  )
			draw.SimpleText( tData.Weight, "CarTrunk:40TB", w - dItemPanel:GetTall()/2, h - 10, tColors[ "white" ], TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM  )
			
			-- Main background
			local mainBackgroundSize = w - modelBackgroundSize - dItemPanel:GetTall() - 4
			draw.RoundedBox( 0, modelBackgroundSize + 2, 0, mainBackgroundSize, h, tColorBack )
			
			if ( not IsValid( oSelectedItem ) or oSelectedItem ~= self ) and self:IsHovered() then
				if gradientAlpha == 0 then
					surface.PlaySound("UI/buttonrollover.wav")
				end
				gradientAlpha = math.Clamp( gradientAlpha + 0.1, 0, 1 )
			else
				gradientAlpha = math.Clamp( gradientAlpha - 0.1, 0, 1 )
			end
			surface.SetDrawColor( ColorAlpha( tWeightColors[ iWeight ], 10 * gradientAlpha ) )
			surface.SetMaterial( tMat[ "gradient-l" ] )
			surface.DrawTexturedRect( modelBackgroundSize + 2, 0, 50, h )

			draw.RoundedBox( 0, modelBackgroundSize + mainBackgroundSize, 0, 2, 2, tColors[ "light-white" ] )
			draw.RoundedBox( 0, modelBackgroundSize + mainBackgroundSize, h - 2, 2, 2, tColors[ "light-white" ] )
			
			draw.SimpleText( string.upper( sCategory ), "CarTrunk:20T", modelBackgroundSize + 2 + 10, 10, tColors[ "light-white" ]  )
			draw.SimpleText( string.upper( sPrintName ), "CarTrunk:35T", modelBackgroundSize + 2 + 10, h - 8, tColors[ "white" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM  )
		end
		function dItemPanel:DoClick()
			oSelectedItem = self
			surface.PlaySound("buttons/button15.wav")
			UpdateSelection()
		end

		tItems[ #tItems + 1 ] = dItemPanel
	end


	for sClass, tInfos in pairs( tTrunk ) do
		for iID, tData in pairs( tInfos ) do
			if not tData.Type then continue end
			tListedByType[ tData.Type ] = tListedByType[ tData.Type ] or {}
			table.insert( tListedByType[ tData.Type ], { iID, sClass, tData, tData.Type == "Weapon" } )
		end
	end

	for sType, tItemsList in pairs( tListedByType ) do
		local dItemListTitle = vgui.Create( "DPanel", dItemList )
		dItemListTitle:Dock( TOP )
		dItemListTitle:DockMargin( 0, 0, 10, 10 )
		dItemListTitle:SetTall( 50 )
		function dItemListTitle:Paint( w, h )
			draw.SimpleText( CarTrunk:L( sType ), "CarTrunk:40T", 5, 5, tColors[ "white-shadow" ] )
			local x, y = draw.SimpleText( CarTrunk:L( sType ), "CarTrunk:40T", 0, 0, tColors[ "white" ] )

			draw.RoundedBox( 0, 0, y + 5, w, 2, tColors[ "separation-bar" ] )
		end

		tItemTitles[ sType ] = dItemListTitle

		for k, v in pairs( tItemsList ) do
			table.insert( v, k )
			DrawItem( unpack( v ) )
		end
	end

	UpdateSelection()

end

local function CreateVehicleFrame( eVehicle )
	if not IsValid( eVehicle ) then return end
	if IsValid( eVehicle.TrunkFrame ) then eVehicle.TrunkFrame:Remove() print("removing" ) end

	local dFrame = vgui.Create( "CarTrunk.3DFrame")
	dFrame:SetZPos( -1000 )
	dFrame:SetSize( menuSize.x, menuSize.y )
	dFrame:SetDrawCursor( false )
	dFrame:SetCursorColor( tColors[ "white" ] )
	dFrame:SetCursorRadius( 10 )
	dFrame:SetPaintedManually( true )
	dFrame:ShowCloseButton( false )
	dFrame:SetTitle( "" )
	function dFrame:Paint( w, h )
		draw.SimpleText( string.upper( CarTrunk:L( "CarTrunk" ) ), "CarTrunk:300B", 800 + 10, h / 2 + 10 - 150, tColors[ "black" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( string.upper( CarTrunk:L( "CarTrunk" ) ), "CarTrunk:300B", 800, h / 2 - 150, tColors[ "white" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		draw.SimpleText( CarTrunk:L( "CurrentWeight" ) .. " : " .. CarTrunk:GetVehicleWeight( eVehicle ) .. "/" ..  CarTrunk:GetVehicleMaxWeight( eVehicle ), "CarTrunk:150", 800 + 5, h / 2 + 5, tColors[ "black" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( CarTrunk:L( "CurrentWeight" ) .. " : " .. CarTrunk:GetVehicleWeight( eVehicle ) .. "/" ..  CarTrunk:GetVehicleMaxWeight( eVehicle ), "CarTrunk:150", 800, h / 2, tColors[ "white" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	
		draw.SimpleText( string.format( CarTrunk:L( "PressKey" ), string.upper( input.GetKeyName( CarTrunk.Config.KeyOne ) .. "+" .. input.GetKeyName( CarTrunk.Config.KeyTwo ) ) ), "CarTrunk:150", 800 + 5, h / 2 + 5 + 150, tColors[ "black" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( string.format( CarTrunk:L( "PressKey" ), string.upper( input.GetKeyName( CarTrunk.Config.KeyOne ) .. "+" .. input.GetKeyName( CarTrunk.Config.KeyTwo ) ) ), "CarTrunk:150", 800, h / 2 + 150, tColors[ "white" ], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	function dFrame:Think()
		if not IsValid( eVehicle ) then
			self:Remove()
			return
		end
		if LocalPlayer():GetPos():DistToSqr( eVehicle:GetPos() ) > 70600 then 
			self:Remove()
		end
	end

	local dOpenButton = vgui.Create( "DButton", dFrame )
	dOpenButton:Dock( LEFT )
	dOpenButton:SetText( "" )
	dOpenButton:SetWide( 740 )
	dOpenButton.HoverLevel = 0
	function dOpenButton:Paint( w, h )
		drawCircle( 0, 0, w, h, tColors[ "grey-alpha" ] )

		if self:IsHovered() and (not CarTrunk.LastTrunkClosed or CurTime() - CarTrunk.LastTrunkClosed > 3) then
			dOpenButton.StartHover = dOpenButton.StartHover or CurTime()
			dOpenButton.HoverLevel = math.Clamp( ( CurTime() - dOpenButton.StartHover ) / 1, 0, 1 ) or 0
		else
			dOpenButton.StartHover = nil
			dOpenButton.HoverLevel = math.Clamp( dOpenButton.HoverLevel - 0.01, 0, 1 )
		end

		if dOpenButton.HoverLevel >= 1 and ( not CarTrunk.TrunkOpened or not IsValid( CarTrunk.TrunkOpened.vehicle ) or CarTrunk.TrunkOpened.vehicle ~= eVehicle ) then
			dFrame:Close()
			timer.Simple( 0, function()
				if (not CarTrunk.LastTrunkClosed) or CurTime() - CarTrunk.LastTrunkClosed > 3 then
					net.Start( "CarTrunk.RequestTrunk" )
						net.WriteEntity( eVehicle )
					net.SendToServer()
				end
			end )
			return
		end

		local circleSize = w * dOpenButton.HoverLevel
		drawCircle( ( w - circleSize ) / 2, ( w - circleSize ) / 2, circleSize, circleSize, tColors[ "orange-alpha" ] )

		surface.SetDrawColor( tColors[ "white" ] )
		surface.SetMaterial( tMat[ "key" ] )
		surface.DrawTexturedRectRotated( w / 2, h / 2, 500, 500, -90 * dOpenButton.HoverLevel )
	end

	dFrame:UpdateChildren()
	eVehicle.TrunkFrame = dFrame
end

hook.Add( "PostDrawTranslucentRenderables", "CarTrunk.PostDrawTranslucentRenderables", function()
	if CarTrunk.TrunkOpened and IsValid( CarTrunk.TrunkOpened ) then 
		return
	end

	local tSpecificVehicles = CarTrunk.Config.SpecificVehicles

	for iIndex, eVehicle in pairs( CarTrunk.ServerTrunks or {} ) do 
		if not CarTrunk:HasTrunk( eVehicle ) then 
			if IsValid( eVehicle.TrunkFrame ) then
				eVehicle.TrunkFrame:Remove()
			end
			continue
		end

		if LocalPlayer():InVehicle() then 
			if IsValid( eVehicle.TrunkFrame ) then
				eVehicle.TrunkFrame:Remove()
			end
			continue
		end
		if not CarTrunk:AllowedToUseTrunk( LocalPlayer(), eVehicle ) then
			if IsValid( eVehicle.TrunkFrame ) then
				eVehicle.TrunkFrame:Remove()
			end
			continue
		end

		if not IsValid( eVehicle.TrunkFrame ) then
			CreateVehicleFrame( eVehicle )
			continue
		end

		local aAngle = Angle( 0, 0, 90  )
		local vPosition = Vector( eVehicle:OBBCenter()[1] - menuSize.x / 2 * iScale, eVehicle:OBBMins()[2], 60 )
		
		if tSpecificVehicles[ eVehicle:GetVehicleClass() ] and tSpecificVehicles[ eVehicle:GetVehicleClass() ].trunkAngle then
			aAngle = aAngle + tSpecificVehicles[ eVehicle:GetVehicleClass() ].trunkAngle
		end
		if tSpecificVehicles[ eVehicle:GetVehicleClass() ] and tSpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition then
			vPosition = vPosition + tSpecificVehicles[ eVehicle:GetVehicleClass() ].trunkPosition
		end

		vPosition = eVehicle:LocalToWorld( vPosition )
		aAngle = eVehicle:LocalToWorldAngles( aAngle )
		
		if LocalPlayer():GetPos():DistToSqr( vPosition ) > 70600 then 
			if IsValid( eVehicle.TrunkFrame ) then
				eVehicle.TrunkFrame:Remove()
			end
			continue
		end

		cam.Start3D2D( vPosition, aAngle, iScale )
			eVehicle.TrunkFrame:PaintManual3D( vPosition, aAngle, iScale )
		cam.End3D2D()
	end
end )