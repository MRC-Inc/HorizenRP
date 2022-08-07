include("shared.lua")

local bUse2d3d = ModernCarDealer.Config.Use3d2d
local cMainColor = ModernCarDealer.Config.PrimaryColor
local cSecondaryColor = ModernCarDealer.Config.SecondaryColor
local cAccentColor = ModernCarDealer.Config.AccentColor

function ENT:Initialize()
	self.sName = nil
	self.bComputer = false

	self:MCD_LoadData() -- Fix for NPCs not initialized on connect
end

function ENT:MCD_LoadData()
	if not ModernCarDealer.NPCs then return end

	local tData = ModernCarDealer.NPCs[self:GetNWInt("MCD_Index")]
	if not tData then return end

	self.sName = tData.Name

	local iType = tData.Type
	if iType == 1 then
		self.bGarage = true
	else
		self.bGarage = false
	end

	self.iType = tData.Type
	self.tData = tData.Data
	self.bComputer = tData.Computer or false
end

local iHeight = 60
local iMargin = 4
local iCarWidth = 60
local cBGcolor = Color(10, 10, 10, 180)	
local mIconGarage = Material("moderncardealer/garage.png")
local mIconStore = Material("moderncardealer/store.png")

function ENT:Draw()
	self:DrawModel()
	local vPos = self:GetPos()
	
	if bUse2d3d and LocalPlayer():GetPos():DistToSqr(vPos) < 210000 and self.sName then
		surface.SetFont("ModernCarDealer.Font.LargeText")
		local iTextW, iTextH = surface.GetTextSize(self.sName)
		local iWidth = (iMargin*4) + iTextW + iCarWidth
		local iZero = (iWidth/2)*-1
		local iMax = (iWidth/2)

		local aAng = self:GetAngles()

		if self.bComputer then
				
			local dlight = DynamicLight(self:EntIndex())
            if (dlight) then
                dlight.pos = vPos
                dlight.r = cAccentColor.r
                dlight.g = cAccentColor.g
                dlight.b = cAccentColor.b
                dlight.brightness = 5
                dlight.Decay = 1000
                dlight.Size = 100
                dlight.DieTime = CurTime() + 1
            end 

			cam.Start3D2D(vPos + aAng:Up()*37.5 + aAng:Right()*22 + aAng:Forward()*-2, Angle(0, self:GetAngles().y + 90, 90), 0.1)		
		    draw.RoundedBox(0, 9, 0, 426, 250, cSecondaryColor)

			if self.bGarage then
				surface.SetMaterial(mIconGarage)
			else
				surface.SetMaterial(mIconStore)
			end

			surface.SetDrawColor(cMainColor)
			surface.DrawTexturedRect(213 - 62.5, 125 - 62.5, 125, 125)
			cam.End3D2D()
		else
			cam.Start3D2D(vPos + aAng:Up()*78, Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1)		
			draw.RoundedBox(10, iZero, 0, iWidth - iCarWidth, iHeight, cBGcolor)

			draw.RoundedBox(10, iMax - iCarWidth + iMargin, 0, iCarWidth, iHeight, cBGcolor)

			draw.SimpleText(self.sName, "ModernCarDealer.Font.LargeText", iZero + iMargin, 0, color_white)

			surface.SetDrawColor(color_white)

			if self.bGarage then
				surface.SetMaterial(mIconGarage)
			else
				surface.SetMaterial(mIconStore)
			end

			surface.DrawTexturedRect(iMax - iCarWidth + iMargin + 4, 4, iCarWidth - 8, iCarWidth - 8)

			cam.End3D2D()
		end
	end
end

