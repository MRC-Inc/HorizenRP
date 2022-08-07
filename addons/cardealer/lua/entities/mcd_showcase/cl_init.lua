include("shared.lua")

function ENT:Initialize()
	self.sName = ""
	self.iPrice = 0

	self.iTopSpeed = 0
	self.iHorsePower = 0
	self.iBraking = 0
	self.iTorque = 0

	self:MCD_LoadData() -- Fix for NPCs not initialized on connect
end

function ENT:MCD_LoadData()
	if not ModernCarDealer.NPCs then return end

	local tData = ModernCarDealer.Showcases[self:GetNWInt("MCD_Index")]
	if not tData then return end

	self.bData = true 

	self.sName = tData.Name
	self.iPrice = tData.Price
	self.sClass = tData.Class
	self.iID = tData.ID

	self.iTopSpeed = tData.Speed
	self.iHorsePower = tData.HP
	self.iBraking = tData.Braking
	self.iTorque = tData.Torque
end

local iHeight = 450
local iMargin = 4
local cBGcolor = Color(10, 10, 10, 180)
local iTriangleRad = 25
local mCar = Material("moderncardealer/car.png")
local iCarWidth = 120
local iStatDiff = 80
local iBoxDiff = 80
local iBoxWidth = 380

local tTriangle = {
	{ x = iTriangleRad, y = iHeight - 10},
	{ x = 0, y = iHeight + iTriangleRad - 10},
	{ x = iTriangleRad*-1, y = iHeight - 10},
}


function ENT:Draw()
	self:DrawModel()

	local _, vMax = self:GetRenderBounds()

	surface.SetFont("ModernCarDealer.Font.LargeText")
	local iTextW, iTextH = surface.GetTextSize(ModernCarDealer:GetPhrase("top_speed"))
	local iWidth = iTextW + iCarWidth + iBoxWidth
	if iWidth < 800 then iWidth = 800 end

	local iZero = (iWidth/2)*-1
	local iMax = (iWidth/2)
	local iBoxMargins = iMax - iBoxWidth - 10

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 610000 then
		local vPos = self:GetPos()
		local aAng = self:GetAngles()
	 
		cam.Start3D2D(vPos + aAng:Up()*((vMax.z/2) + 85), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1)
			draw.RoundedBox(10, iZero, iCarWidth + iMargin, iWidth + (iMargin*3), iHeight - (iCarWidth + iMargin) - 10, cBGcolor) -- Frame

			draw.RoundedBox(10, iZero, 0, iWidth - iCarWidth - (iMargin*2), iCarWidth, cBGcolor)

			draw.RoundedBox(10, iMax - iCarWidth - iMargin, 0, iCarWidth + (iMargin*4), iCarWidth, cBGcolor)


			surface.SetDrawColor(cBGcolor)
			surface.DrawPoly(tTriangle)

			draw.SimpleText(self.sName, "ModernCarDealer.Font.LargeText", iZero + iMargin + 20, 0, color_white)
			draw.SimpleText(ModernCarDealer:FormatMoney(self.iPrice), "ModernCarDealer.Font.LargeText", iZero + iMargin + 20, iTextH - 5, color_white)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(mCar)
			surface.DrawTexturedRect(iMax - iCarWidth + iMargin + 4, 4, iCarWidth - 8, iCarWidth  - 8)

			-- Top Speed
			draw.SimpleText(ModernCarDealer:GetPhrase("top_speed"), "ModernCarDealer.Font.LargeText", iZero + 20, iCarWidth + iMargin + 5, cTextColor, TEXT_ALIGN_LEFT)
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*0) + 30, iBoxWidth, 12, Color(150, 150, 150, 100))
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*0) + 30, math.Clamp(iBoxWidth*(self.iTopSpeed/140), 1, iBoxWidth), 12, Color(255, 255, 255, 240))

			-- Horsepower
			draw.SimpleText(ModernCarDealer:GetPhrase("horsepower"), "ModernCarDealer.Font.LargeText", iZero + 20, iStatDiff + iCarWidth + iMargin + 5, cTextColor)
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*1) + 30, iBoxWidth, 12, Color(150, 150, 150, 100))
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*1) + 30, math.Clamp(iBoxWidth*(self.iHorsePower/1000), 1, iBoxWidth), 12, Color(255, 255, 255, 240))

			-- Braking
			draw.SimpleText(ModernCarDealer:GetPhrase("braking"), "ModernCarDealer.Font.LargeText", iZero + 20, (iStatDiff*2) + iCarWidth + iMargin + 5, cTextColor)
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*2) + 30, iBoxWidth, 12, Color(150, 150, 150, 100))
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*2) + 30, math.Clamp(iBoxWidth*(self.iBraking/0.7), 1, iBoxWidth), 12, Color(255, 255, 255, 240))
			
			-- Torque
			draw.SimpleText(ModernCarDealer:GetPhrase("torque"), "ModernCarDealer.Font.LargeText", iZero + 20, (iStatDiff*3) + iCarWidth + iMargin + 5, cTextColor)
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*3) + 30, iBoxWidth, 12, Color(150, 150, 150, 100))
			draw.RoundedBox(0, iBoxMargins, iCarWidth + iMargin + (iBoxDiff*3) + 30, math.Clamp(iBoxWidth*(self.iTorque/3300), 1, iBoxWidth), 12, Color(255, 255, 255, 240))

			for ii= 1, 4 do
				for i=1, 5 do
					surface.SetDrawColor(cBGcolor)
					surface.DrawRect((iBoxWidth/6)*i + iBoxMargins, ((iBoxDiff)*(ii-1)) + iCarWidth + iMargin + 30, 4, 12)
				end
			end

		cam.End3D2D()
	end
end