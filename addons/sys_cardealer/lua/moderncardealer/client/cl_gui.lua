local i3DOffset = 0

local mLockMaterial = Material("moderncardealer/lock.png")
local mGarageMaterial = Material("moderncardealer/garage.png")
local mPaper = Material("moderncardealer/paper.png")
local mPen = Material("moderncardealer/pen.png")
local mPlane = Material("moderncardealer/plane.png")
local mGradientDown = Material("gui/gradient_down")
local mGradientUp = Material("gui/gradient_up")

local cMainColor = ModernCarDealer.Config.PrimaryColor
local cSecondaryColor = ModernCarDealer.Config.SecondaryColor
local cAccentColor = ModernCarDealer.Config.AccentColor
local cTextColor = ModernCarDealer.Config.TextColor

local cWhiteOnWhiteColor
if ModernCarDealer.Config.Light then
    cWhiteOnWhiteColor = cSecondaryColor
else
    cWhiteOnWhiteColor = cTextColor
end

local iScrW, iScrH = ScrW(), ScrH()

function ModernCarDealer:OpenDealerUI(sDealerName, sDealerSetName) -- PURPOSE: This is the frame of the car dealer, aka the first thing opened.
    local tProps = {
        -- Top Ceiling
        {Model = "models/hunter/plates/plate7x7.mdl", Material = "models/debug/debugwhite", Color = color_white, Angle = Angle(0, 90, 0), Pos = Vector(-11.4375, -161.40625, 113.4375), Scale = 3},
        
        -- Showroom
        {Model = "models/painless/car_showroom.mdl", Material = "", Color = color_white, Angle = Angle(0, 180, 0), Pos = Vector(-20.8125, -190.03125, -71.65625), Scale = 7},

        -- Car
        {Model = "models/lonewolfie/ferrari_458.mdl", Material = "", Color = color_white, Angle = Angle(0, -38, 0), Pos = Vector(-20, -190.03125, -71.65625), Scale = .8, Car = true},
    }

    local tEntities = {}
    local vRenderPos = Vector(0, 0, -5000)
    local aRenderAngle = Angle(6, -70, 0)
    local cLightColor = Color(119, 150, 173)

    local function MCD_CreateFakeEnts()
        for _, eEnt in pairs(tProps) do
            local eClientside = ClientsideModel(eEnt.Model, RENDERGROUP_OPAQUE)

            local vPos = Vector(eEnt.Pos.x + 4, eEnt.Pos.y + 15, eEnt.Pos.z - 5000 + 20)
            if eEnt.Car then
                vPos = Vector(vPos.x, vPos.y, vPos.z + i3DOffset)

                eClientside:SetPos(vPos)
                eClientside.OriginalPos = vPos
            else
                eClientside:SetPos(vPos)
                eClientside.OriginalPos = vPos
            end

            eClientside:SetAngles(eEnt.Angle)
            eClientside.OriginalAngle = eEnt.Angle
            eClientside:SetMaterial(eEnt.Material)
            eClientside.OriginalScale = eClientside:GetModelScale()
            eClientside:SetModelScale(eClientside:GetModelScale() * eEnt.Scale)
            eClientside.Color = eEnt.Color

            eClientside:SetNoDraw(true)
            table.insert(tEntities, eClientside)
        end
    end

    local function MCD_RemoveFakeEnts()
        for _, eEnt in pairs(tEntities) do
            eEnt:Remove()
        end
    end
    
    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetTitle("")
    frame:Dock(FILL)

    MCD_CreateFakeEnts()

    frame.Paint = function()
        cam.Start3D(vRenderPos, aRenderAngle, 100, 0, 0, w, h)
            render.SuppressEngineLighting(true)
            for _, eEnt in pairs(tEntities) do
                render.SetColorModulation(eEnt.Color.r/255, eEnt.Color.g/255, eEnt.Color.b/255)

                render.SetLightingOrigin(eEnt:GetPos())
                render.ResetModelLighting(cLightColor.r / 255, cLightColor.g / 255, cLightColor.b / 255 )
                eEnt:DrawModel()
            end
            render.SuppressEngineLighting(false)
        cam.End3D()
    end

    -- Gather categories
    local tCatalogInfo = ModernCarDealer.Cars[sDealerName]
    local tCatalogCategories = {}
    for _, v in pairs(tCatalogInfo) do if not table.HasValue(tCatalogCategories, v.Category) then table.insert(tCatalogCategories,  v.Category) end end

    frame.OnClose = function()
        MCD_RemoveFakeEnts()
    end
 
    local content = vgui.Create("DPanel", frame) 
    content:SetSize(iScrW/3, iScrH - 100)
    content:SetPos(40, 50)
    content.iHeaderHeight = 30

    local pSkeleton = content

    content.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 1, w, h - 1, cMainColor)

        surface.SetDrawColor(color_black)
        surface.SetMaterial(mGradientDown)
        surface.DrawTexturedRect(0, self.iHeaderHeight * 0.9, w, self.iHeaderHeight * 0.25)

        draw.RoundedBox(5, 0, 0, w, self.iHeaderHeight, cSecondaryColor)
        draw.RoundedBox(0, 0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2, cSecondaryColor)

        if ModernCarDealer.Config.Light then
            surface.SetDrawColor(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25)
            surface.SetMaterial(mGradientUp)
            surface.DrawTexturedRect(0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2)
        end

        draw.SimpleText(ModernCarDealer:GetPhrase("vehicles"), "ModernCarDealer.Font.MediumText", 10, self.iHeaderHeight / 2, cTextColor, 0, 1)
    end

    local closeButton = vgui.Create("DButton", content)
    closeButton:SetPos(content:GetWide() - content.iHeaderHeight*2 + 10, 3)
    closeButton:SetSize(content.iHeaderHeight*2, content.iHeaderHeight + 6)
    closeButton:SetText("")

    closeButton.Paint = function(s, w, h)
        draw.NoTexture()

        surface.SetDrawColor(cTextColor)
        surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 135)
        surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 45)
    end

    closeButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        frame:Remove()
    end

    closeButton.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end

    local contentList = vgui.Create("DCategoryList", content)
    contentList:Dock(FILL)
    if not ModernCarDealer.Config.ShowSortButton then
        contentList:DockMargin(0, 35, 0, 5)
    else
        contentList:DockMargin(0, 0, 0, 5)
    end
    contentList.Paint = function() end
    content.contentList = contentList
    local sBar = contentList:GetVBar()

    local iSize = 8

    function sBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_transparent)
    end

    function sBar.btnUp:Paint(w, h)
        draw.RoundedBox(5, (w - iSize)/2, 0, iSize, iSize, cSecondaryColor)
    end

    function sBar.btnDown:Paint(w, h)
        draw.RoundedBox(5, (w - iSize)/2, 0, iSize, iSize, cSecondaryColor)
    end

    function sBar.btnGrip:Paint(w, h)
        draw.RoundedBox(5, (w - iSize)/2, 0, iSize, h, cSecondaryColor)
    end

    local sSelected
    local bFirstUsed = false
    local iCategoryIndex = 0
    
    local function MCD_CreateCategory(sCategory, sOverride, bHighLow)
        iCategoryIndex = iCategoryIndex + 1

        local contentListCategory = contentList:Add("")
        contentListCategory:DockMargin(0, 0, 0, 5)
        contentListCategory:SetExpanded(false)
        contentListCategory:SetPaintBackground(false)
        surface.SetFont("ModernCarDealer.Font.Text")
        contentListCategory:SetHeaderHeight(50)
        contentListCategory.iHeaderHeight = contentListCategory:GetHeaderHeight()

        
        if ModernCarDealer.Config.CategoryState == 2 then
            if iCategoryIndex == 1 then
                contentListCategory:SetExpanded(true)
            end
        elseif ModernCarDealer.Config.CategoryState == 3 then
            contentListCategory:SetExpanded(true)
        end 
        
        contentListCategory.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, self.iHeaderHeight, Color(cSecondaryColor.r - 5, cSecondaryColor.g - 5, cSecondaryColor.b - 5))

            surface.SetDrawColor(cSecondaryColor)
            surface.SetMaterial(mGradientDown)
            surface.DrawTexturedRect(0, 0, w, self.iHeaderHeight)
        
            draw.SimpleText(sOverride or sCategory, "ModernCarDealer.Font.Text", 10, self.iHeaderHeight/2, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        contentListCategory.OnToggle = function()
            surface.PlaySound("moderncardealer/click.wav")
        end


        local tDisplayVehicles = {}
        local bStartExpanded = false

        if bHighLow == true then -- Sort: High to Low
            for _, tVehicle in SortedPairsByMemberValue(tCatalogInfo, "Price", false) do
                table.insert(tDisplayVehicles, tVehicle)
            end

            bStartExpanded = true
        elseif bHighLow == false then -- Sort: Low to High
            for _, tVehicle in SortedPairsByMemberValue(tCatalogInfo, "Price", true) do
                table.insert(tDisplayVehicles, tVehicle)
            end

            bStartExpanded = true
        else -- Sort: Category
            for _, tVehicle in pairs(tCatalogInfo) do
                if tVehicle.Category == sCategory then
                    table.insert(tDisplayVehicles, tVehicle)
                end
            end
        end


        local vehicleInformation

        for iIndex, tVehicle in pairs(tDisplayVehicles) do
            local sName = tVehicle.Name
            local tSpawnIndex = ModernCarDealer.GamemodeVehicles[tVehicle.Class]

            if not tSpawnIndex then
                ModernCarDealer:ChatMessage(string.format(ModernCarDealer:GetPhrase("content_missing"), tVehicle.Class))
            else
                local sModel = tSpawnIndex.Model
                local iPriceRaw = tVehicle.Price
                local iPrice = ModernCarDealer:FormatMoney(tVehicle.Price) or ""
                if iPriceRaw == 0 then iPrice = string.upper(ModernCarDealer:GetPhrase("free")) end
                local bCheck = true
                if ModernCarDealer.Config.PlayerCheck[tVehicle.Check] then
                    local fCheck = ModernCarDealer.Config.PlayerCheck[tVehicle.Check][1]
                    bCheck = fCheck(LocalPlayer())
                end

                if bStartExpanded then
                    contentListCategory:SetExpanded(true)
                    contentListCategory:SetHeaderHeight(1)
                    contentListCategory.Paint = function() end
                end

                local contentListCategoryButton = contentListCategory:Add("")
                contentListCategoryButton:SetTall(40)
                contentListCategoryButton.iHeaderHeight = 40
                contentListCategoryButton.Lerp = 0

                local iLockIconOffset = 0 
                if not bCheck then iLockIconOffset = 25 end

                contentListCategoryButton.Paint = function(self, w, h)
                    if sSelected and sSelected == sName then
                        draw.RoundedBox(5, 0, 0, w, h, Color(cAccentColor.r, cAccentColor.g, cAccentColor.b, 100))
                    elseif self:IsHovered() then
                        self.Lerp = Lerp(0.075, self.Lerp, 100)
                    else
                        self.Lerp = Lerp(0.05, self.Lerp, 0)
                    end

                    draw.RoundedBox(5, 0, 0, w, h, Color(cSecondaryColor.r, cSecondaryColor.g, cSecondaryColor.b, self.Lerp))

                    draw.SimpleText(sName, "ModernCarDealer.Font.Small", 10 + iLockIconOffset, self.iHeaderHeight/2, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(iPrice, "ModernCarDealer.Font.Small", w - 10, self.iHeaderHeight/2, cWhiteOnWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                    if not bCheck then
                        surface.SetDrawColor(color_white)
                        surface.SetMaterial(mLockMaterial)
                        surface.DrawTexturedRect(10, (h - 16)/2 + 1, 16, 16)
                    end
                end
                
                local bLFS 
                if ModernCarDealer.Planes then
                    bLFS = ModernCarDealer.Planes[tVehicle.Class] -- LFS CHECK 2
                else
                    bLFS = false
                end

                contentListCategoryButton.DoClick = function()
                    local eCar = tEntities[#tEntities]
                    eCar.Color = color_white
                    
                    if bLFS then
                        eCar:SetModelScale(eCar.OriginalScale * 0.4)
                        eCar:SetPos(Vector(eCar.OriginalPos.x, eCar.OriginalPos.y, eCar.OriginalPos.z + 30))
                    else
                        eCar:SetModelScale(eCar.OriginalScale * 0.8)
                        eCar:SetPos(eCar.OriginalPos)
                    end

                    if ModernCarDealer.SimfPhys[tVehicle.Class] then
                        eCar:SetPos(eCar.OriginalPos + Vector(0, 0, (ModernCarDealer.GamemodeVehicles[tVehicle.Class].SpawnOffset and ModernCarDealer.GamemodeVehicles[tVehicle.Class].SpawnOffset.z) or 0))
                        eCar:SetAngles(Angle(eCar.OriginalAngle.p, eCar.OriginalAngle.y + (ModernCarDealer.GamemodeVehicles[tVehicle.Class].SpawnAngleOffset or 0), eCar.OriginalAngle.r))
                    else
                        eCar:SetAngles(eCar.OriginalAngle)
                    end
                    
                    if sSelected == sName then
                        local content = vgui.Create("DPanel", frame) 
                        content:SetSize(iScrW/3, iScrH - 100)
                        content:SetPos(40, 50)
                        content.iHeaderHeight = 30

                        content.Paint = function(self, w, h)
                            draw.RoundedBox(5, 0, 1, w, h - 1, cMainColor)

                            surface.SetDrawColor(color_black)
                            surface.SetMaterial(mGradientDown)
                            surface.DrawTexturedRect(0, self.iHeaderHeight * 0.9, w, self.iHeaderHeight * 0.25)

                            draw.RoundedBox(5, 0, 0, w, self.iHeaderHeight, cSecondaryColor)
                            draw.RoundedBox(0, 0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2, cSecondaryColor)

                            if ModernCarDealer.Config.Light then
                                surface.SetDrawColor(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25)
                                surface.SetMaterial(mGradientUp)
                                surface.DrawTexturedRect(0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2)
                            end

                            draw.SimpleText(ModernCarDealer:GetPhrase("vehicle_information"), "ModernCarDealer.Font.MediumText", 10, self.iHeaderHeight / 2, cTextColor, 0, 1)
                        end

                        local closeButton = vgui.Create("DButton", content)
                        closeButton:SetPos(content:GetWide() - content.iHeaderHeight*2 + 10, 3)
                        closeButton:SetSize(content.iHeaderHeight*2, content.iHeaderHeight + 6)
                        closeButton:SetText("")

                        closeButton.Paint = function(s, w, h)
                            draw.NoTexture()

                            surface.SetDrawColor(cTextColor)
                            surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 135)
                            surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 45)
                        end

                        closeButton.DoClick = function()
                            eCar.Color = color_white
                            
                            content:Remove()

                            surface.PlaySound("moderncardealer/click.wav")
                        end

                        closeButton.OnCursorEntered = function()
                            surface.PlaySound("moderncardealer/rollover.wav")
                        end

                        local finishLabel = vgui.Create("DLabel", content)
                        finishLabel:Dock(TOP)
                        finishLabel:DockMargin(10, 35, 0, 0)
                        finishLabel:SetTall(30)
                        finishLabel:SetFont("ModernCarDealer.Font.MediumText")
                        finishLabel:SetText(ModernCarDealer:GetPhrase("vehicle_finish")..":")
                        finishLabel:SetTextColor(cWhiteOnWhiteColor)
                        local colorScroll = ModernCarDealer.Scroll(content, 0, 0, 0, 0)
                        colorScroll:Dock(FILL)

                        for sName, cColor in pairs(ModernCarDealer.Config.PurchaseableColors) do
                            local finish = vgui.Create("DButton", colorScroll)
                            finish:Dock(TOP)
                            finish:DockMargin(5, 5, 5, 0)
                            finish:SetTall(50)
                            finish:SetText("")
                            finish.Lerp = 0

                            finish.Paint = function(self, w, h)
                                draw.RoundedBox(6, 0, 0, w, h, cColor or cSecondaryColor)
                        
                                if self:IsHovered() then
                                    self.Lerp = Lerp(0.2, self.Lerp, 150)
                                else
                                    self.Lerp = Lerp(0.1, self.Lerp, 50)
                                end
                                
                                draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, self.Lerp))
                            

                                --draw.SimpleTextOutlined(sName, "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1, 1, color_black)
                            end
                        

                            finish.DoClick = function()
                                surface.PlaySound("moderncardealer/click.wav")

                                eCar.Color = cColor
                            end

                            finish.OnCursorEntered = function()
                                surface.PlaySound("moderncardealer/rollover.wav")
                            end
                        end

                        if iPrice == "FREE" then iPrice = ModernCarDealer:GetPhrase("free") end

                        local sUseageText

                        local iInsurancePrice = math.Clamp(tVehicle.Price*ModernCarDealer.Config.InsuranceToCarValuePercentage, ModernCarDealer.Config.InsuranceMinimum, ModernCarDealer.Config.InsuranceMaximum)
                        local sInsurance = string.format("%s (%s)", ModernCarDealer:GetPhrase("insurance"), ModernCarDealer:FormatMoney(iInsurancePrice))
                        local isInsured

                        local purchaseButton = vgui.Create("DButton", content)
                        purchaseButton:Dock(BOTTOM)
                        purchaseButton:DockMargin(5, 5, 5, 5)
                        purchaseButton:SetTall(iScrH/10)
                        purchaseButton:SetText("")
                        purchaseButton.Lerp = 0

                        local function MCD_UpdatePrice()
                            if bCheck then
                                local iPrice = tVehicle.Price

                                if isInsured:GetChecked() then
                                    iPrice = iPrice + iInsurancePrice
                                end

                                if LocalPlayer():canAfford(iPrice) then
                                    sUseageText = string.format("%s (%s)", ModernCarDealer:GetPhrase("purchase"), ModernCarDealer:FormatMoney(iPrice))
                                else
                                    sUseageText = string.format("%s (%s)", ModernCarDealer:GetPhrase("cannot_afford"), ModernCarDealer:FormatMoney(iPrice))
                                end
                            else
                                sUseageText = string.format("%s (%s)", ModernCarDealer:GetPhrase("no_access"), tVehicle.Check)
                            end
                        end
                        
                        purchaseButton.Paint = function(self, w, h)
                            draw.RoundedBox(6, 0, 0, w, h, cColor or cSecondaryColor)
   
                            if self:IsHovered() then
                                self.Lerp = Lerp(0.2, self.Lerp, 25)
                            else
                                self.Lerp = Lerp(0.1, self.Lerp, 0)
                            end
                            
                            draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
                    
                            draw.SimpleText(sUseageText, "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
                        end

                        purchaseButton.DoClick = function() -- Signature content
                            if not bCheck or not LocalPlayer():canAfford(tVehicle.Price) then return end

                            surface.PlaySound("moderncardealer/click.wav")

                            local bIsInsured = isInsured:GetChecked()

                            eCar:SetPos(Vector(0, 0, 0))

                            pSkeleton:Remove()                            
                            content:Remove()

                            local content = vgui.Create("DPanel", frame) 
                            content:SetSize(iScrW/2, iScrH/1.15)
                            content:Center()
                            content.iHeaderHeight = 30
        
                            content.Paint = function(self, w, h)
                                surface.SetDrawColor(cMainColor)
                                surface.SetMaterial(mPaper)
                                surface.DrawTexturedRect(0, 10, w, h)   

                                surface.SetDrawColor(color_black)
                                surface.SetMaterial(mGradientDown)
                                surface.DrawTexturedRect(0, self.iHeaderHeight * 0.9, w, self.iHeaderHeight * 0.25)
        
                                if ModernCarDealer.Config.Light then
                                    surface.SetDrawColor(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25)
                                    surface.SetMaterial(mGradientUp)
                                    surface.DrawTexturedRect(0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2)
                                end

                                draw.RoundedBox(5, 0, 0, w, self.iHeaderHeight, cSecondaryColor)
                                draw.RoundedBox(0, 0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2, cSecondaryColor)
                            end
                
                            local closeButton = vgui.Create("DButton", content)
                            closeButton:SetPos(content:GetWide() - content.iHeaderHeight*2 + 10, 3)
                            closeButton:SetSize(content.iHeaderHeight*2, content.iHeaderHeight + 6)
                            closeButton:SetText("")
        
                            closeButton.Paint = function(s, w, h)
                                draw.NoTexture()
        
                                surface.SetDrawColor(cTextColor)
                                surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 135)
                                surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 45)
                            end
        
                            closeButton.DoClick = function()
                                frame:Remove()

                                ModernCarDealer:OpenDealerUI(sDealerName, sDealerSetName)
        
                                surface.PlaySound("moderncardealer/click.wav")
                            end
        
                            surface.SetFont("ModernCarDealer.Font.Main")
                            local iTextW, iTextH = surface.GetTextSize(string.upper(ModernCarDealer:GetPhrase("dealer_agreement")))
                            iTextW = iTextW + 50
                            
                            local header = vgui.Create("DPanel", content)
                            header:Dock(TOP)
                            header:DockMargin(10, 40, 10, 10)
                            header:SetTall(iTextH  + 25)

                            header.Paint = function(self, w, h)
                                draw.SimpleText(string.upper(ModernCarDealer:GetPhrase("dealer_agreement")), "ModernCarDealer.Font.Main", w/2, 50, cWhiteOnWhiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                                draw.RoundedBox(0, w/2 - iTextW/2, iTextH  + 20, iTextW, 4, cWhiteOnWhiteColor)
                            end

                            local grid1
                
                            if not bLFS then
                                grid1 = vgui.Create("DPanel", content)

                                grid1.Paint = function() end
                                grid1:SetSize(content:GetWide()/3, content:GetWide()/3)
                                grid1:Dock(TOP)

                                local grid1Model = vgui.Create("DModelPanel", grid1)
                                grid1Model:Dock(FILL)
                                grid1Model:DockMargin(2, 2, 2, 2)
                                grid1Model:SetModel(sModel)
                                grid1Model:SetColor(eCar.Color)
                                local mn, mx = grid1Model.Entity:GetRenderBounds()

                                grid1Model:SetCamPos(Vector(-140, mx.y*2, mx.z*0.75))
                                grid1Model:SetFOV(80)
                                grid1Model:SetLookAt(Vector(0, 0, 20))
                                grid1Model:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
                                grid1Model:SetDirectionalLight(BOX_FRONT, Color(40, 40, 40))
                            else
                                --[[
                                grid1:SetSize(mPlane:Height()/5, mPlane:Width()/5)
                                grid1:SetPos(0, iTextH  + 40 + 35 + 10)
                                grid1:CenterHorizontal()
        
                                grid1.Paint = function(self, w, h)
                                    surface.SetMaterial(mPlane)
                                    surface.SetDrawColor(cWhiteOnWhiteColor)
                                    surface.DrawTexturedRect(0, 0, w, h)  
                                end
                                ]]--
                            end

                            local signature = vgui.Create("DPanel", content)
                            signature:SetPos(0, 40)
                            signature:SetSize(content:GetWide(), content:GetTall() - 40)
                            signature:SetCursor("blank")
                            local tPoints = {}
                            local vLastPoint = {}
                            local bDrawing = false
                            
                            signature.Think = function(self)
                                local bDown = input.IsMouseDown(MOUSE_LEFT)
                            
                                if bDown then
                                    local iX, iY = self:ScreenToLocal(input.GetCursorPos())
                                    local vPos = {}
                                    vPos.x = iX
                                    vPos.y = iY
                            
                                    if not bDrawing then
                                        vPos.FirstPoint = true
                                    end
                            
                                    if not table.HasValue(tPoints, vMousePos) then table.insert(tPoints, vPos) end
                            
                                    bDrawing = true
                                else
                                    bDrawing = false
                                end

                            end

                            local purchaseButton = ModernCarDealer.Button(content, ModernCarDealer:GetPhrase("purchase"), 0, 0, 0, 0)
                            purchaseButton:Dock(BOTTOM)
                            purchaseButton:DockMargin(5, 0, 5, 5)
                            purchaseButton:SetTall(iScrH/10)

                            purchaseButton.DoClick = function()
                                if #tPoints > 40 and bCheck and LocalPlayer():canAfford(tVehicle.Price) then
                                    net.Start("ModernCarDealer.Net.PurchaseCar")
                                    local iKey, iValue = ModernCarDealer:GetCarKeyValue(tVehicle.Class, sDealerName)
                                    net.WriteUInt(iKey, 10)
                                    net.WriteUInt(iValue, 10)
                                    net.WriteColor(eCar.Color)
                                    net.WriteBool(bIsInsured)
                                    net.SendToServer()

                                    frame:Remove()
                                end
                            end

                            local sNameAnim = ""
                            for iIndex, sChar in pairs(string.Explode("", sName)) do
                                timer.Simple(3 + (iIndex*0.15), function()
                                    sNameAnim = sNameAnim .. sChar
                                end)
                            end

                            local iPlaneMatWidth, iPlaneMatHeight = mPlane:Width()/2, mPlane:Height()/2

                            signature.Paint = function(self, w, h)
                                draw.SimpleText(string.upper(ModernCarDealer:GetPhrase("sign")..":"), "ModernCarDealer.Font.Main", 15, h - 70 - iScrH/10, cWhiteOnWhiteColor, TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER)
        
                                --surface.SetMaterial(mPlane)
                                --surface.SetDrawColor(cWhiteOnWhiteColor)
                                --surface.DrawTexturedRect((w/2) - (iPlaneMatWidth/2), (content:GetTall()/2) - iPlaneMatHeight - 50, iPlaneMatWidth, iPlaneMatHeight)  

                                if not bLFS then
                                    draw.SimpleText(sNameAnim, "ModernCarDealer.Font.Main", w/2, content:GetTall()/2 + 20, cWhiteOnWhiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                                else
                                    draw.SimpleText(sNameAnim, "ModernCarDealer.Font.Main", w/2, iScrH/5, cWhiteOnWhiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                                end

                                for iIndex, vPoint in pairs(tPoints) do  -- Pen Usage
                                    if not vPoint.FirstPoint and iIndex % 15 then
                                        local iBrushSize = math.Clamp(math.Distance(vPoint.x, vPoint.y, vLastPoint.x, vLastPoint.y)/7.5, 0.25, 3)
                            
                                        local vPos1 = vPoint
                                        local vPos2 = vLastPoint
                                    
                                        local vDirection = Vector(0, 0, 0)
                                        vDirection.x = vPos2.x - vPos1.x
                                        vDirection.y = vPos2.y - vPos1.y
                                        vDirection:Normalize()
                                    
                                        local vOffset1 = {}
                                        vOffset1.x = -vDirection.y * iBrushSize
                                        vOffset1.y = vDirection.x * iBrushSize
                                        
                                        local vOffset2 = {}
                                        vOffset2.x = vDirection.y * iBrushSize
                                        vOffset2.y = -vDirection.x * iBrushSize
                                    
                                        local vPoint1 = {x = vPos1.x + vOffset1.x, y = vPos1.y + vOffset1.y}
                                        local vPoint2 = {x = vPos1.x + vOffset2.x, y = vPos1.y + vOffset2.y} 
                                        local vPoint3 = {x = vPos2.x + vOffset1.x, y = vPos2.y + vOffset1.y} 
                                        local vPoint4 = {x = vPos2.x + vOffset2.x, y = vPos2.y + vOffset2.y} 
                                
                                        surface.SetDrawColor(color_white)
                                        surface.DrawPoly({vPoint1, vPoint2, vPoint4, vPoint3})
                                    end
                            
                                    vLastPoint.x = vPoint.x
                                    vLastPoint.y = vPoint.y
                                end

                                local iX, iY = self:LocalCursorPos()

                                if purchaseButton:IsHovered() then return end
                                
                                surface.SetDrawColor(cWhiteOnWhiteColor)
                                surface.SetMaterial(mPen)
                                surface.DrawTexturedRect(iX, iY - 32, 32, 32)
                            end
                            
                            header:SetAlpha(0)
                            header:AlphaTo(255, 1)

                            signature:SetAlpha(0)
                            signature:AlphaTo(255, 1, 1)

                            purchaseButton:SetAlpha(0)
                            purchaseButton:AlphaTo(255, 1, 2)
                        end 

                        if ModernCarDealer.Config.TestDrivingEnabled and bCheck and not (ModernCarDealer.Planes and ModernCarDealer.Planes[sName]) and not (ModernCarDealer.SimfPhys and ModernCarDealer.SimfPhys[tVehicle.Class]) then -- TEST DRIVE
                            local testDriveButton = ModernCarDealer.Button(content, ModernCarDealer:GetPhrase("test_drive"), 0, 0, 0, 0)
                            testDriveButton:Dock(BOTTOM)
                            testDriveButton:DockMargin(5, 0, 5, 0)
                            testDriveButton:SetTall(iScrH/10)

                            testDriveButton.DoClick = function()
                                surface.PlaySound("moderncardealer/click.wav")
                        
                                frame:Remove()
                    
                                if ModernCarDealer:PriceCheck((tVehicle.Price*ModernCarDealer.Config.TestDrivingPercentMoneyNeeded) - 1, " ("..tostring(ModernCarDealer.Config.TestDrivingPercentMoneyNeeded*100).."% needed)") then
                                    net.Start("ModernCarDealer.Net.TestDrive")
                                    local iKey, iValue = ModernCarDealer:GetCarKeyValue(tVehicle.Class, sDealerName)

                                    net.WriteUInt(iKey, 10)
                                    net.WriteUInt(iValue, 10)
                                    net.SendToServer()
                                end
                            end
                        end

                        local insuranceFrame = vgui.Create("DPanel", content)
                        insuranceFrame:Dock(BOTTOM)
                        insuranceFrame:DockMargin(5, 0, 5, 5)
                        insuranceFrame:SetTall(50)

                        insuranceFrame.Paint = function(self, w, h)
                            draw.SimpleText(sInsurance, "ModernCarDealer.Font.Text", 5, h/2, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        end

                        local isInsuredCheckboxFrame = vgui.Create("DPanel", insuranceFrame)
                        isInsuredCheckboxFrame:Dock(RIGHT)
                        isInsuredCheckboxFrame:DockMargin(0, 0, 0, 0)
                        isInsuredCheckboxFrame:SetSize(50, 50)

                        isInsuredCheckboxFrame.Paint = function() end

                        isInsured = ModernCarDealer.CheckBox(isInsuredCheckboxFrame, 0, 0, 0, 0, false)
                        isInsured:SetChecked(false)
                        isInsured:SetSize(50, 50)

                        isInsured.OnChange = function()
                            MCD_UpdatePrice()
                        end

                        MCD_UpdatePrice()
                    end

                    eCar:SetModel(sModel)

                    sSelected = sName

                    surface.PlaySound("moderncardealer/click.wav")
                end

                if iIndex == 1 and not bFirstUsed then contentListCategoryButton:DoClick() end
                
                bFirstUsed = true 

                contentListCategoryButton.OnCursorEntered = function()
                    surface.PlaySound("moderncardealer/rollover.wav")
                end
            end
        end
    end

    if ModernCarDealer.Config.ShowSortButton then
        local sort = ModernCarDealer.ComboBox(content, 0, 0, 0, 0, ModernCarDealer:GetPhrase("sort_category"), {ModernCarDealer:GetPhrase("sort_category"), ModernCarDealer:GetPhrase("sort_low_high"), ModernCarDealer:GetPhrase("sort_high_low")})
        sort:Dock(TOP)
        sort:SetTall(35)
        sort:DockMargin(5, content.iHeaderHeight + 8, 5, 5)

        sort.OnSelect = function(_, _, sText)
            content.contentList:Clear()

            if sText == ModernCarDealer:GetPhrase("sort_category") then
                local bHasNone = false
                for iIndex, sCategory in SortedPairsByValue(tCatalogCategories) do
                    if not (sCategory == "None") then
                        MCD_CreateCategory(sCategory)
                    else
                        bHasNone = true
                    end
                end
            
                if bHasNone then
                    MCD_CreateCategory("None", ModernCarDealer:GetPhrase("miscellaneous"))
                end
            elseif sText == ModernCarDealer:GetPhrase("sort_low_high") then
                MCD_CreateCategory("", nil, true)
            elseif sText == ModernCarDealer:GetPhrase("sort_high_low") then
                MCD_CreateCategory("", nil, false)
            end

        end
    end
    
    local bHasNone = false
    for iIndex, sCategory in SortedPairsByValue(tCatalogCategories) do
        if not (sCategory == "None") then
            MCD_CreateCategory(sCategory)
        else
            bHasNone = true
        end
    end

    if bHasNone then
        MCD_CreateCategory("None", ModernCarDealer:GetPhrase("miscellaneous"))
    end
end

function ModernCarDealer:OpenGarageUI(sGarageName, tGarageParams, tAvailable) -- PURPOSE: This is the frame of the garage, aka the first thing opened.
    local tVehicles = {}

    for _, tCar in pairs(ModernCarDealer.MyCars or {}) do
        if table.HasValue(tGarageParams, tCar.Dealer) then
            if ModernCarDealer.Config.PlayerCheck[tCar.Check] then
                if ModernCarDealer.Config.PlayerCheck[tCar.Check][1](LocalPlayer()) or not ModernCarDealer.Config.PlayerCheck[tCar.Check][3] then
                    table.insert(tVehicles, tCar)
                end
            else
                table.insert(tVehicles, tCar)
            end
        end
    end

    local frame = ModernCarDealer.Frame(0, 0, iScrW/1.15, iScrH/1.15, sGarageName) 
    frame:Center()

    local tCarScroll = ModernCarDealer.Scroll(frame, 0, 0, 0, 0)
    tCarScroll:Dock(FILL)
   
    local tCarPanels = {}
    local bShowNoVehiclesMessage = false

    for iIndex, tCar in pairs(tVehicles) do
        local tSpawnIndex = ModernCarDealer.GamemodeVehicles[tCar.Class]

        if tSpawnIndex then
            bShowNoVehiclesMessage = true

            local sModel = tSpawnIndex.Model
            local iHealth = tCar.Health
            local sCost

            if tCar.Insured then
                sCost = ModernCarDealer:FormatMoney(0)
            else
                sCost = ModernCarDealer:FormatMoney(ModernCarDealer.Config.RepairPrice)
            end

            local bAvailable = true
            local bIsJobCar = tCar.JobCar
            for _, tOutCar in pairs(tAvailable) do
                if tOutCar[1] == tCar.CID then
                    bAvailable = false
                end
            end
    
            local tCarPanel = tCarScroll:Add("DPanel")
            tCarPanel:Dock(TOP)
            tCarPanel:DockMargin(0, 0, 0, 5)
            tCarPanel:SetTall(iScrH/6)
            tCarPanel.Name = tCar.Name
            table.insert(tCarPanels, tCarPanel)
            local iOffset = iScrH/60
            local cDiffColor
      
            if ModernCarDealer.Config.Light then
                cDiffColor = Color(cMainColor.r - 25, cMainColor.g - 25, cMainColor.b - 25, 50)
            else
                cDiffColor = Color(cMainColor.r + 60, cMainColor.g + 60, cMainColor.b + 60, 50)
            end
    
            tCarPanel.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, cDiffColor)
    
                surface.SetFont("ModernCarDealer.Font.LargeText")
                local iTextW, iTextH = surface.GetTextSize(self.Name)
                draw.SimpleText(self.Name, "ModernCarDealer.Font.LargeText", tCarPanel:GetTall()/1.2 + 57, (h/2) + iOffset, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
                
                draw.RoundedBox(0, tCarPanel:GetTall()/1.2 + 60, (h/2) + iOffset, iTextW, 3, cWhiteOnWhiteColor)
                
                draw.SimpleText(ModernCarDealer:GetPhrase("health")..": "..tostring(iHealth).."%", "ModernCarDealer.Font.Category", tCarPanel:GetTall()/1.2 + 60, (h/2) + 8 + iOffset, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
    
            tCarPanel:SetAlpha(0)
    
            local grid1 = vgui.Create("DPanel", tCarPanel)
            grid1:SetSize(tCarPanel:GetTall()/1.2, tCarPanel:GetTall()/1.2)
            grid1:SetPos((tCarPanel:GetTall()-tCarPanel:GetTall()/1.2)/2, (tCarPanel:GetTall()-tCarPanel:GetTall()/1.2)/2)
            
            grid1.Paint = function(self, w, h) end
    
            local tCarPanelModel = vgui.Create("DModelPanel", grid1)
            tCarPanelModel:Dock(FILL)
            tCarPanelModel:SetTall(grid1:GetTall())
            tCarPanelModel:SetModel(sModel)
    
            local mn, mx = tCarPanelModel.Entity:GetRenderBounds()
    
            if bIsJobCar then
                tCarPanelModel.Entity:SetSkin(tCar.Skin)
            end

            if ModernCarDealer.Config.ShowCarSpecificsInGarage then
                tCarPanelModel.Entity:SetSkin(tCar.Skin)
                tCarPanelModel:SetColor(tCar.Color)

                for iKey, iValue in pairs(tCar.Bodygroups) do
                    tCarPanelModel.Entity:SetBodygroup(iKey, iValue)
                end
            end
            
            tCarPanelModel:SetCamPos(Vector(-140, mx.y*2, mx.z*0.75))
            tCarPanelModel:SetFOV(42)
            tCarPanelModel:SetLookAt(Vector(20,1000,20))
    
            tCarPanelModel:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
            tCarPanelModel:SetDirectionalLight(BOX_FRONT, Color(40, 40, 40))
           
            function tCarPanelModel:LayoutEntity(Entity) return end
    
            local tCarPanelOverlay = vgui.Create("DPanel", grid1)
            tCarPanelOverlay:Dock(FILL)
            tCarPanelOverlay.Paint = function() end
            
            local iTime = math.Clamp((iIndex*0.075), 0, 0.75)
        
            timer.Simple(iTime*2, function() if IsValid(tCarPanelModel) then tCarPanel:AlphaTo(255, 0.2) tCarPanelModel:SetLookAt(Vector(20,0,30)) end end)
    
            local buttonArea = vgui.Create("DPanel", tCarPanel)
            buttonArea:Dock(RIGHT)
            buttonArea:SetSize(iScrH/4, tCarPanel:GetTall()-20)
            buttonArea:SetText("")
            buttonArea.Paint = function() end
    
            local retrieveButton
            
            local cButtonColor
            if ModernCarDealer.Config.Light then
                cButtonColor = cSecondaryColor
            else
                cButtonColor = cMainColor
            end
    
            if bAvailable then
                retrieveButton = ModernCarDealer.Button(buttonArea, ModernCarDealer:GetPhrase("retrieve"), 0, 0, 0, 0, cButtonColor)
            else
                retrieveButton = ModernCarDealer.Button(buttonArea, ModernCarDealer:GetPhrase("return_garage"), 0, 0, 0, 0, cButtonColor)
            end
    
            retrieveButton:Dock(FILL)
            retrieveButton:DockMargin(5, 5, 5, 5)
    
            retrieveButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
                
                if bIsJobCar and bAvailable and tCar.AllowCustomizing then
                    ModernCarDealer:JobDealerCustomize(frame, tCar)
                else
                    net.Start("ModernCarDealer.Net.RetrieveCar")
                    net.WriteUInt(tCar.CID, 8)
                    net.SendToServer()
    
                    frame:Remove()
                end
            end
    
            local repairButton
    
            if VC and ModernCarDealer.Config.AllowRepairInDealer and iHealth < 100 and bAvailable then
                repairButton = ModernCarDealer.Button(buttonArea, string.format(ModernCarDealer:GetPhrase("fix"), sCost), 0, 0, 0, 0, cMainColor)
    
                repairButton.DoClick = function()
                    surface.PlaySound("moderncardealer/click.wav")
                    frame:Remove()
        
                    net.Start("ModernCarDealer.Net.FixCar")
                    net.WriteUInt(tCar.CID, 8)
                    net.SendToServer()
                end
            elseif bAvailable then
                if not (tCar.Price == 0) and not tCar.JobCar then 
                    repairButton = ModernCarDealer.Button(buttonArea, string.format("%s (%s)", ModernCarDealer:GetPhrase("sell"), ModernCarDealer:FormatMoney(tCar.Price/2)), 0, 0, 0, 0, cMainColor)
                
                    local function MCD_ButtonFunc()
                        surface.PlaySound("moderncardealer/click.wav")
                        frame:Remove()
            
                        net.Start("ModernCarDealer.Net.SellCar")
                        net.WriteUInt(tCar.CID, 8)
                        net.SendToServer()
                    end
    
                    repairButton.DoClick = function()
                        ModernCarDealer.Query(ModernCarDealer:GetPhrase("unsaved_notice"), "Modern Car Dealer", ModernCarDealer:GetPhrase("yes"), MCD_ButtonFunc, ModernCarDealer:GetPhrase("no"))
                    end
                end
            end
    
            if IsValid(repairButton) then  
                repairButton:Dock(BOTTOM)
                repairButton:DockMargin(5, 0, 5, 5)
                repairButton:SetTall(60)
            end
        end
    end

    if not bShowNoVehiclesMessage then 
        local noVehicles = vgui.Create("DPanel", frame)
        noVehicles:Dock(FILL)
        noVehicles:Center()

        noVehicles.Paint = function(self, w, h)
            draw.SimpleText(ModernCarDealer:GetPhrase("no_vehicles"), "ModernCarDealer.Font.Main", w/2, h/2, cWhiteOnWhiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        return
    end

    local search = vgui.Create("EditablePanel", frame)
    search:Dock(TOP)
    search:DockMargin(0, 7, 0, 3)

    local searchButton = vgui.Create("DButton", search)
    searchButton:Dock(RIGHT)
    searchButton:SetTextColor(color_white)
    searchButton:SetText(ModernCarDealer:GetPhrase("search"))
    searchButton:SetFont("ModernCarDealer.Font.Small")
    searchButton.Lerp = 0

    searchButton.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, cSecondaryColor)

        if self:IsHovered() then
            self.Lerp = Lerp(0.2, self.Lerp, 25)
        else
            self.Lerp = Lerp(0.1, self.Lerp, 0)
        end
        draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
    end
    searchButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        for _, tPanel in pairs(tCarPanels) do
            if tPanel.Name:lower():find(search.textEntry:GetValue()) ~= nil then
                tCarScroll:ScrollToChild(tPanel)
                break
            end
        end
    end

    search.textEntry = ModernCarDealer.TextEntry(search, "")
    search.textEntry:Dock(FILL)
    search.textEntry:DockMargin(0, 2, 5, 2)
    search.textEntry.OnEnter = searchButton.DoClick
end

function ModernCarDealer:OpenMechanicUI(pModelPanel, pFrame, pRetrieveMenu, iCID, iUpgrade) -- PURPOSE: This is the frame of the mechanic, aka the first thing opened.
    local pPlayer = LocalPlayer()
    local eVehicle
    local bJobUsage = IsValid(pFrame)
    local iSelectedEngineUpgrade = iUpgrade
    local iSelectedEngineUpgradePrice

    if bJobUsage then
        eVehicle = pModelPanel.Entity
    else
        eVehicle = LocalPlayer():GetVehicle()
    end

    if not IsValid(eVehicle) then return end
    
    local sClass = eVehicle:GetClass()
    local cInitialColor = eVehicle:GetColor()
    local iInitialSkin = eVehicle:GetSkin()

    local vInitialUnderglow = eVehicle:GetNWVector("MCD_Underglow")
    local iInitialBGSequence = nil
    local cSelectedColor
    local cSelectedUnderglow

    local iUnderglowPrice = ModernCarDealer:FormatMoney(ModernCarDealer.Config.UnderglowPrice or 6500)
    local iBodygroupPrice = ModernCarDealer:FormatMoney(ModernCarDealer.Config.BodygroupPrice or 1000)
    local iSkinPrice = ModernCarDealer:FormatMoney(ModernCarDealer.Config.SkinPrice or 3000)
    local iColorPrice = ModernCarDealer:FormatMoney(ModernCarDealer.Config.ColorPrice or 2500)

    if bJobUsage then
        pFrame.tActivePreset = {}
        pFrame.tActivePreset.Skin = eVehicle:GetSkin()
        pFrame.tActivePreset.Color = eVehicle:GetColor()
        pFrame.tActivePreset.Bodygroups = {}

        for iIndex, _ in pairs(eVehicle:GetBodyGroups()) do
            pFrame.tActivePreset.Bodygroups[iIndex - 1] = eVehicle:GetBodygroup(iIndex - 1)
        end
    end

    if not bJobUsage then
        surface.PlaySound("doors/door_latch1.wav")
    end

    local vehicleRender = vgui.Create("DPanel")
    vehicleRender:SetPos(0, 0)
    vehicleRender:SetSize(iScrW, iScrH)
    vehicleRender.Paint = function(self, w, h) end

    local sUseageText
    local garageFrame
    if bJobUsage then
        sUseageText = ModernCarDealer:GetPhrase("apply")
        garageFrame = vgui.Create("DFrame", pFrame)
        garageFrame:SetSize(600, pFrame:GetTall())

    else
        sUseageText = ModernCarDealer:GetPhrase("purchase")
        garageFrame = vgui.Create("DFrame")
        garageFrame:SetSize(600, iScrH)
    end

    garageFrame:SetPos(0, 0)
    garageFrame:SetAlpha(0)
    garageFrame:SetTitle("")
    if not bJobUsage then
        garageFrame:MakePopup()
    end
    garageFrame:ShowCloseButton(false)
    garageFrame:SetDraggable(false)
    
    surface.SetFont("ModernCarDealer.Font.Main")
    local iTextW, iTextH = surface.GetTextSize("Mechanic")
    local iTextW = iTextW + 50

    garageFrame.Paint = function(self, w, h)
        if not bJobUsage then
            -- Background
            surface.SetDrawColor(cMainColor)
            surface.DrawRect(0, 0, w, h)

            -- Title
        
            draw.SimpleText(ModernCarDealer:GetPhrase("mechanic"), "ModernCarDealer.Font.Main", w/2, 20, cWhiteOnWhiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_DOWN)
            draw.RoundedBox(0, (w/2)-(iTextW/2), 20 + iTextH, iTextW, 3, cWhiteOnWhiteColor)

            if not IsValid(eVehicle) then
                self:Remove()
            end
        end
    end

    garageFrame.pButtons = {}

    local function MCD_SubMenu(dontMakeReturnButton)
        local bodyFrame = vgui.Create("DPanel", garageFrame)
        bodyFrame:SetPos(0, 150)
        bodyFrame:SetSize(garageFrame:GetWide(), garageFrame:GetTall() - 150)
    
        bodyFrame.Paint = function(self, w, h) end

        for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(0) end

        if not dontMakeReturnButton then
            local pButton = ModernCarDealer.Button(bodyFrame, ModernCarDealer:GetPhrase("return_mechanic"), 0, 0, 0, 0)
            pButton:SetSize(iScrW/8, iScrH/13 + 5)
            pButton:Dock(BOTTOM)
            pButton:DockMargin(5, 5, 5, 5)

            pButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")

                bodyFrame:Remove()

                if not bUnderGlowBegin then
                    eVehicle:SetNWBool("MCD_HasUnderglow", false)
                end

                if not bJobUsage then
                    eVehicle:SetColor(cInitialColor)
                    ModernCarDealer.UnderglowList[eVehicle:EntIndex()] = {eVehicle, vInitialUnderglow:ToColor()}
                else
                    pModelPanel:SetColor(cInitialColor)
                end

                eVehicle:SetSkin(iInitialSkin)
                eVehicle.MCD_UnderglowState = false

                for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(255) end
            end
        end
        return bodyFrame
    end

    local function MCD_CreateColor()
        local bodyFrame = MCD_SubMenu()
    
        local carColorLabel = vgui.Create("DLabel", bodyFrame)
        carColorLabel:Dock(TOP)
        carColorLabel:DockMargin(10, 5, 10, 0)
        carColorLabel:Center()
        carColorLabel:SetFont("ModernCarDealer.Font.Text")
        carColorLabel:SetText(ModernCarDealer:GetPhrase("vehicle_finish"))
        carColorLabel:SetTextColor(cWhiteOnWhiteColor)

        local carColor = vgui.Create("DColorMixer", bodyFrame)
        carColor:Dock(TOP)
        carColor:DockMargin(10, 5, 10, 0)
        carColor:SetAlphaBar(false)

        carColor:SetColor(cSelectedColor or cInitialColor)

        carColor.ValueChanged = function(self, cColor)
            if not bJobUsage then
                eVehicle:SetColor(cColor)
            else
                pModelPanel:SetColor(cColor)
            end

            cSelectedColor = cColor
        end
        

        local sText
        if bJobUsage then
            sText = sUseageText
        else
            sText = string.format("%s (%s)", sUseageText, iColorPrice)
        end
        
        local purchase = ModernCarDealer.Button(bodyFrame, sText, 0, 0, 0, 0)
        purchase:SetSize(iScrW/8, iScrH/13 + 5)
        purchase:Dock(BOTTOM)
        purchase:DockMargin(5, 5, 5, 0)


        purchase.DoClick = function()
            surface.PlaySound("moderncardealer/click.wav")
 
            if not cSelectedColor then
                ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("color_notice"))
            else
                if bJobUsage then -- JOB DEALER FUNCTION
                    pFrame.tActivePreset.Color = cSelectedColor

                    cInitialColor = cSelectedColor
                    return
                end

                if not ModernCarDealer:PriceCheck(ModernCarDealer.Config.ColorPrice) then return end

                cInitialColor = cSelectedColor

                net.Start("ModernCarDealer.Net.UpgradeCar")
                net.WriteUInt(1, 3)
                net.WriteColor(Color(cSelectedColor.r, cSelectedColor.g, cSelectedColor.b))
                net.SendToServer()


                surface.PlaySound("buttons/button14.wav")

                if not bJobUsage then -- JOB DEALER FUNCTION
                    bodyFrame:Remove()
                end

                for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(255) end
            end
        end
    end

    local function MCD_CreateSkin()
        local bodyFrame = MCD_SubMenu()
        bodyFrame.iSelectedSkin = eVehicle:GetSkin()

        local skinScroll = ModernCarDealer.Scroll(bodyFrame, 0, 0, 0, 0)
        skinScroll:Dock(FILL)
        
        for i = 0, eVehicle:SkinCount() do
            local checkbox = vgui.Create("DButton", skinScroll)
            checkbox.iSkinNum = i
            checkbox:Dock(TOP)
            checkbox:DockMargin(5, 5, 5, 0)
            checkbox:SetTall(30)
            checkbox:SetTextColor(cTextColor)
            checkbox:SetText("Skin: " .. tostring(i))
            checkbox:SetFont("ModernCarDealer.Font.Small")
            checkbox.Lerp = 0

            checkbox.Paint = function(self, w, h)
                if self.iSkinNum == bodyFrame.iSelectedSkin then
                    draw.RoundedBox(6, 0, 0, w, h, cAccentColor)
                else
                    draw.RoundedBox(6, 0, 0, w, h, cSecondaryColor)

                    if self:IsHovered() then
                        self.Lerp = Lerp(0.2, self.Lerp, 25)
                    else
                        self.Lerp = Lerp(0.1, self.Lerp, 0)
                    end
                    draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
                end
            end

            checkbox.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                bodyFrame.iSelectedSkin = checkbox.iSkinNum
                eVehicle:SetSkin(checkbox.iSkinNum)
            end

            checkbox.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end
        end

        local sText
        if bJobUsage then
            sText = sUseageText
        else
            sText = string.format("%s (%s)", sUseageText, iSkinPrice)
        end

        local purchase = ModernCarDealer.Button(bodyFrame, sText, 0, 0, 0, 0)
        purchase:SetSize(iScrW/8, iScrH/13 + 5)
        purchase:Dock(BOTTOM)
        purchase:DockMargin(5, 5, 5, 0)

        purchase.DoClick = function()
            surface.PlaySound("moderncardealer/click.wav")

            if bJobUsage then -- JOB DEALER FUNCTION
                pFrame.tActivePreset.Skin = bodyFrame.iSelectedSkin

                iInitialSkin = bodyFrame.iSelectedSkin
                return
            end

            if not ModernCarDealer:PriceCheck(ModernCarDealer.Config.SkinPrice) then return end

            iInitialSkin = bodyFrame.iSelectedSkin

            net.Start("ModernCarDealer.Net.UpgradeCar")
            net.WriteUInt(2, 3)
            net.WriteUInt(bodyFrame.iSelectedSkin, 5)
            net.SendToServer()

            surface.PlaySound("buttons/button14.wav")

            if not bJobUsage then -- JOB DEALER FUNCTION
                bodyFrame:Remove()

                for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(255) end
            end  
        end
    end

    local function MCD_CreateBodyGroups()
        local tUpdatedBG = {}
        local tDataToSend = {}
        
        local bodyFrame = MCD_SubMenu(true)

        local pButton = ModernCarDealer.Button(bodyFrame, ModernCarDealer:GetPhrase("return_mechanic"), 0, 0, 0, 0)
        pButton:SetSize(iScrW/8, iScrH/13 + 5)
        pButton:Dock(BOTTOM)
        pButton:DockMargin(5, 5, 5, 5)

        pButton.DoClick = function()
            surface.PlaySound("moderncardealer/click.wav")
 
            bodyFrame:Remove()

            if not bJobUsage then
                eVehicle:SetColor(cInitialColor)
            else
                pModelPanel:SetColor(cInitialColor)
            end

            eVehicle:SetSkin(iInitialSkin)

            for iKey, tData in pairs(tUpdatedBG) do
                local iValue
                if isnumber(tData) then iValue = tData else iValue = tData.ovalue end

                eVehicle:SetBodygroup(iKey, iValue)
            end

            for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(255) end
        end

        local bgScroll = ModernCarDealer.Scroll(bodyFrame, 0, 0, 0, 0)
        bgScroll:SetPos(0, 0)
        bgScroll:Dock(FILL)



        for iIndex, tBG in pairs(eVehicle:GetBodyGroups()) do
            if not iIndex == 1 or #tBG.submodels == 0 then continue end

            local tBGInfo = {}
            tBGInfo.name = tBG.name
            tBGInfo.ovalue = eVehicle:GetBodygroup(iIndex - 1)
            tBGInfo.value = eVehicle:GetBodygroup(iIndex - 1)
            tBGInfo.modelnumber = #tBG.submodels + 1

            tDataToSend[iIndex - 1] = eVehicle:GetBodygroup(iIndex - 1)
            tUpdatedBG[iIndex - 1] = tBGInfo
        end

        local function MCD_ModifyBGCL(iKey, iValue)
            surface.PlaySound("buttons/button14.wav")

            eVehicle:SetBodygroup(iKey, iValue)
        end

        for iIndex, tData in pairs(tUpdatedBG) do
            local sName = tData.name

            if ModernCarDealer.Language[sName:lower()] then
                sName = ModernCarDealer.Language[sName:lower()]
            end

            sName = sName:gsub("^%l", string.upper) -- Capitalize

            local bgFrame = vgui.Create("DPanel", bgScroll)
            bgFrame:Dock(TOP)
            bgFrame:DockMargin(5, 0, 5, 50)
            bgFrame:SetTall(100)
            bgFrame.Paint = function(self, w, h)
                surface.SetFont("ModernCarDealer.Font.Text")
                local iHeaderWidth, iHeaderHeight = surface.GetTextSize(tData.name)
                iHeaderWidth = iHeaderWidth + 50

                draw.SimpleText(sName, "ModernCarDealer.Font.Text", w/2, 4, cWhiteOnWhiteColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_DOWN)

                draw.RoundedBox(0, w/2 - (iHeaderWidth/2), iHeaderHeight + 5, iHeaderWidth, 2, cWhiteOnWhiteColor)
            end

            local sBGText
            if bJobUsage then
                sBGText = sUseageText
            else
                sBGText = string.format("%s (%s)", sUseageText, iBodygroupPrice)
            end

            local purchaseButton = ModernCarDealer.Button(bgFrame, sBGText, 0, 0, 0, 0)
            purchaseButton:Dock(FILL)
            purchaseButton:DockMargin(15, iScrH/20, 5, 0)
            
            purchaseButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                tDataToSend[iIndex] = tData.value

                if bJobUsage then -- JOB DEALER FUNCTION
                    pFrame.tActivePreset.Bodygroups = tDataToSend
                    tUpdatedBG = tDataToSend
                    return
                end

                if not ModernCarDealer:PriceCheck(ModernCarDealer.Config.BodygroupPrice) then return end

                net.Start("ModernCarDealer.Net.UpgradeCar")
                net.WriteUInt(3, 3)

                net.WriteUInt(iIndex, 5)
                net.WriteUInt(tData.value, 5)
                net.SendToServer()

                tData.ovalue = tData.value 
            end

            local leftArrow = ModernCarDealer.Button(bgFrame, "⇦", 0, 0, 0, 0)
            leftArrow:Dock(LEFT)
            leftArrow:DockMargin(0, iScrH/20, 0, 0)
            leftArrow:SetWide(55)

            leftArrow.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                tData.value = tData.value - 1

                if tData.value > tData.modelnumber - 1 then -- Checks if it goes over max models
                    tData.value = 0
                elseif tData.value < 0 then -- Checks if it's being set to -1 (Goes to max model number)
                    tData.value = tData.modelnumber - 1
                end

                MCD_ModifyBGCL(iIndex, tData.value)
            end

            leftArrow.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end            

            local rightArrow = ModernCarDealer.Button(bgFrame, "⇨", 0, 0, 0, 0)
            rightArrow:Dock(RIGHT)
            rightArrow:DockMargin(0, iScrH/20, 0, 0)
            rightArrow:SetWide(55)
        
            rightArrow.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                tData.value = tData.value + 1
                
                if tData.value > tData.modelnumber - 1 then -- Checks if it goes over max models
                    tData.value = 0
                elseif tData.value < 0 then -- Checks if it's being set to -1 (Goes to max model number)
                    tData.value = tData.modelnumber - 1
                end

                MCD_ModifyBGCL(iIndex, tData.value)
            end

            rightArrow.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end
            
        end
    end 

    local function MCD_CreateUnderglow()
        local bodyFrame = MCD_SubMenu()
    
        vInitialUnderglow = eVehicle:GetNWVector("MCD_Underglow")
        
        local carColorLabel = vgui.Create("DLabel", bodyFrame)
        carColorLabel:Dock(TOP)
        carColorLabel:DockMargin(10, 5, 10, 0)
        carColorLabel:Center()
        carColorLabel:SetFont("ModernCarDealer.Font.Text")
        carColorLabel:SetText(ModernCarDealer:GetPhrase("vehicle_underglow"))
        carColorLabel:SetTextColor(cWhiteOnWhiteColor)

        local carColor = vgui.Create("DColorMixer", bodyFrame)
        carColor:Dock(TOP)
        carColor:DockMargin(10, 5, 10, 0)
        carColor:SetAlphaBar(false)

        if vInitialUnderglow then
            carColor:SetColor(vInitialUnderglow:ToColor())
        end

        eVehicle.MCD_UnderglowState = true

        carColor.ValueChanged = function(self, cColor)
            ModernCarDealer.UnderglowList[eVehicle:EntIndex()] = {eVehicle, cColor}

            cSelectedUnderglow = cColor
        end

        local purchase = ModernCarDealer.Button(bodyFrame, string.format("%s (%s)", sUseageText, iUnderglowPrice), 0, 0, 0, 0)
        purchase:SetSize(iScrW/8, iScrH/13 + 5)
        purchase:Dock(BOTTOM)
        purchase:DockMargin(5, 5, 5, 0)

        purchase.DoClick = function()
            surface.PlaySound("moderncardealer/click.wav")
 
            if not ModernCarDealer:PriceCheck(ModernCarDealer.Config.UnderglowPrice) then return end

            cSelectedUnderglow = cSelectedUnderglow or color_white

            net.Start("ModernCarDealer.Net.UpgradeCar")
            net.WriteUInt(4, 3)
            net.WriteColor(Color(cSelectedUnderglow.r, cSelectedUnderglow.g, cSelectedUnderglow.b))
            net.SendToServer()

            local vColor = Color(cSelectedUnderglow.r, cSelectedUnderglow.g, cSelectedUnderglow.b):ToVector()

            eVehicle:SetNWVector("MCD_Underglow", vColor)
            vInitialUnderglow = vColor

            bodyFrame:Remove()

            for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(255) end
        end
    end

    local function MCD_CreateUpgrades()  -- 76561198845136653
        local bodyFrame = MCD_SubMenu()
       
        for sName, tUpgrade in SortedPairs(ModernCarDealer.Config.EngineUpgrades) do
            local checkbox = vgui.Create("DButton", bodyFrame)
            checkbox:Dock(TOP)
            checkbox:DockMargin(0, 5, 0, 0)
            checkbox:SetTall(60)
            checkbox:SetTextColor(cTextColor)
            checkbox:SetText(string.format("%s (%s)", sName, ModernCarDealer:FormatMoney(tUpgrade.price)))
            checkbox:SetFont("ModernCarDealer.Font.Small")
            checkbox.Lerp = 0

            checkbox.Paint = function(self, w, h)
                if tUpgrade.index == iSelectedEngineUpgrade then
                    draw.RoundedBox(0, 0, 0, w, h, cMainColor)

                    draw.RoundedBox(6, 0, 0, w, h, Color(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25, 25))
                else
                    draw.RoundedBox(0, 0, 0, w, h, cSecondaryColor)

                    if self:IsHovered() then
                        self.Lerp = Lerp(0.2, self.Lerp, 25)
                    else
                        self.Lerp = Lerp(0.1, self.Lerp, 0)
                    end
                    draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
                end
            end

            checkbox.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                iSelectedEngineUpgrade = tUpgrade.index
                iSelectedEngineUpgradePrice = tUpgrade.price
            end

            checkbox.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end
        end

        local purchase = ModernCarDealer.Button(bodyFrame, ModernCarDealer:GetPhrase("purchase"), 0, 0, 0, 0)
        purchase:SetSize(iScrW/8, iScrH/13 + 5)
        purchase:Dock(BOTTOM)
        purchase:DockMargin(5, 5, 5, 0)
    
        purchase.DoClick = function()
            surface.PlaySound("moderncardealer/click.wav")
 
            if iSelectedEngineUpgrade == iUpgrade then
                ModernCarDealer:AlreadyOwned()
                return
            end
            if not ModernCarDealer:PriceCheck(iSelectedEngineUpgradePrice) then return end

            net.Start("ModernCarDealer.Net.UpgradeCar")
            net.WriteUInt(5, 3)
            net.WriteUInt(iSelectedEngineUpgrade, 5)
            net.SendToServer()

            bodyFrame:Remove()
            
            for _, pPanel in pairs(garageFrame.pButtons) do pPanel:SetAlpha(255) end
        end
    end

    local tOptions

    if bJobUsage then -- JOB DEALER FUNCTION
        tOptions = {ModernCarDealer:GetPhrase("cancel"), ModernCarDealer:GetPhrase("upgrades"), ModernCarDealer:GetPhrase("underglow"), ModernCarDealer:GetPhrase("bodygroups"), ModernCarDealer:GetPhrase("skin"), ModernCarDealer:GetPhrase("color"), ModernCarDealer:GetPhrase("retrieve")}
    else
        tOptions = {ModernCarDealer:GetPhrase("exit"), ModernCarDealer:GetPhrase("upgrades"), ModernCarDealer:GetPhrase("underglow"), ModernCarDealer:GetPhrase("bodygroups"), ModernCarDealer:GetPhrase("skin"), ModernCarDealer:GetPhrase("color")}
    end
    
    local retrieveExitFrame

    if bJobUsage then
        retrieveExitFrame = vgui.Create("DPanel", garageFrame)
        retrieveExitFrame:Dock(BOTTOM)
        retrieveExitFrame:SetTall(iScrH/13 + 5)
        retrieveExitFrame:DockMargin(0, 5, 0, 0)

        retrieveExitFrame.Paint = function() end
    end

    local function MCD_CreateMechanicSubInterface()
        for iIndex, sCategory in pairs(tOptions) do
            if bJobUsage then
                if sCategory == ModernCarDealer:GetPhrase("upgrades") or sCategory == ModernCarDealer:GetPhrase("underglow") then continue end
            end

            local pButton
            
            if (iIndex ==  1 or iIndex == 7) and bJobUsage then -- CASE: Retriever & Cancel Button
                pButton = ModernCarDealer.Button(retrieveExitFrame, sCategory, 0, 0, 0, 0)
                pButton:SetSize(garageFrame:GetWide()/2 - 7, iScrH/13 + 5)

                if iIndex == 1 then -- Cancel Button: LEFT
                    pButton:Dock(LEFT)
                else -- Retrieve Button: RIGHT
                    pButton:Dock(RIGHT)
                end
            else -- CASE: Evey other button
                pButton = ModernCarDealer.Button(garageFrame, sCategory, 0, 0, 0, 0)
                pButton:SetSize(iScrW/8, iScrH/13 + 5)
                pButton:Dock(BOTTOM)
                pButton:DockMargin(0, 5, 0, 0)
            end
           
            pButton.sText = sCategory
        
            pButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                local function MCD_RemoveUI()
                    if bJobUsage then
                        pFrame:Remove()
                        pRetrieveMenu:Remove()
                    else  
                        net.Start("ModernCarDealer.Net.ResetOpenMechanicUI")
                        net.SendToServer()
                    end
                    
                    garageFrame:Remove()
                end

                -- COMMENT OUT ANYTHING YOU DON'T WANT HERE
                
                if iIndex == 1 then -- Exit
                    MCD_RemoveUI()
                end
                if iIndex == 2 then
                    MCD_CreateUpgrades()
                end
                if iIndex == 3 then
                    MCD_CreateUnderglow()
                end
                if iIndex == 4 then
                    MCD_CreateBodyGroups()
                end
                if iIndex == 5 then
                    MCD_CreateSkin()
                end
                if iIndex == 6 then
                    MCD_CreateColor()
                end
                if iIndex == 7 then -- This is if there is a job dealer hence a retrieve button
                    MCD_RemoveUI()

                    pFrame.tActivePreset = {}
                    pFrame.tActivePreset.Skin = eVehicle:GetSkin()
                    pFrame.tActivePreset.Color = pModelPanel:GetColor()
                    pFrame.tActivePreset.Bodygroups = {}

                    for iIndex, _ in pairs(eVehicle:GetBodyGroups()) do
                        pFrame.tActivePreset.Bodygroups[iIndex - 1] = eVehicle:GetBodygroup(iIndex - 1)
                    end
                   
                    net.Start("ModernCarDealer.Net.RetrieveCar")
                    net.WriteUInt(iCID, 8)

                    local tTableToSend = util.Compress(util.TableToJSON(pFrame.tActivePreset))
                    net.WriteUInt(#tTableToSend, 22)
                    net.WriteData(tTableToSend, #tTableToSend)
                    net.SendToServer() 

                    pRetrieveMenu:Remove()
                end
            end

            table.insert(garageFrame.pButtons, pButton)
        end
    end
    
    MCD_CreateMechanicSubInterface()

    if not bJobUsage then
        -- Transitions

        local garageTransition  = vgui.Create("DPanel")
        garageTransition:SetAlpha(0)
        garageTransition:AlphaTo(255, 1)
        garageTransition:SetPos(0, 0)
        garageTransition:SetSize(iScrW, iScrH)
        garageTransition.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h,  color_black)
        end
        
        timer.Simple(2, function() 
            garageTransition:AlphaTo(0, 1)

            local iDegree = math.rad(25)
            local iChange = math.rad(1.5)
            local iRadius = 220 
            local cos, sin = math.cos, math.sin

        
            local arrowFrame = vgui.Create("DPanel", frame)
            arrowFrame:Dock(BOTTOM)
            arrowFrame:DockMargin(605, 0, 5, 5)
            arrowFrame:SetTall(48)
            arrowFrame.Paint = function()
             end
            
            local leftArrow = ModernCarDealer.Button(arrowFrame, "⇦", 0, 0, 0, 0)
            leftArrow:Dock(LEFT)
            leftArrow:SetWide(55)
        
            leftArrow.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
            end
        
            leftArrow.Think = function(self)
                if self:IsDown() then
                    iDegree = iDegree - iChange
                end
            end
        
            leftArrow.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end            
        
            local rightArrow = ModernCarDealer.Button(arrowFrame, "⇨", 0, 0, 0, 0)
            rightArrow:Dock(RIGHT)
            rightArrow:SetWide(55)
        
            rightArrow.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
            end
        
            rightArrow.Think = function(self)
                if self:IsDown() then
                    iDegree = iDegree + iChange
                end
            end
        
            rightArrow.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end
     

            local mn, mx = eVehicle:GetRenderBounds()

            vehicleRender.Paint = function(self, w, h)
                local vPos = eVehicle:LocalToWorld(Vector(iRadius*cos(iDegree), iRadius*sin(iDegree), mx.z))
                local vAngle = Angle(20, math.deg(iDegree) + LocalPlayer():GetVehicle():GetAngles().y - 180, 0)

                render.RenderView({
                    origin = vPos,
                    angles = vAngle,
                    x = 300, y = 0,
                    w = w, h = h
                })
            end
    
            garageFrame.OnRemove = function()
                hook.Remove("CalcView", "ModernCarDealer.Hook.CalcView")
                if IsValid(vehicleRender) then vehicleRender:Remove() end
                if IsValid(arrowFrame) then arrowFrame:Remove() end
            end

            garageFrame:SetAlpha(255)
        end)

        timer.Simple(4, function() garageTransition:Remove() end)
    else
        garageFrame:SetAlpha(255)
    end

    return garageFrame
end

local mechanicTriggerButton = mechanicTriggerButton or nil

net.Receive("ModernCarDealer.Net.OpenMechanicUI", function() 
    local sButtonText = string.format("%s (Key: %s)", ModernCarDealer:GetPhrase("mechanic"), string.upper(input.GetKeyName(ModernCarDealer.Config.MechanicKey)))
    local sKey = ModernCarDealer.Config.MechanicKey
    
    if ModernCarDealer.Config.TriggerBasedMechanicUI then
        ModernCarDealer:OpenMechanicUI(LocalPlayer():GetVehicle(), nil, nil, nil, net.ReadUInt(4))
    else
        if IsValid(mechanicTriggerButton) then return end

        mechanicTriggerButton = vgui.Create("DPanel")
        mechanicTriggerButton:Dock(BOTTOM)
        mechanicTriggerButton:SetTall(80)
        mechanicTriggerButton:DockMargin(iScrW/4, 0, iScrW/4, 20)

        mechanicTriggerButton.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, cColor or cSecondaryColor)
            draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, 25))
    
            surface.SetAlphaMultiplier(math.abs(math.sin(CurTime()*2)))
            draw.SimpleText(sButtonText, "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
            surface.SetAlphaMultiplier(1)

            if input.IsKeyDown(sKey) then
                ModernCarDealer:OpenMechanicUI(LocalPlayer():GetVehicle(), nil, nil, nil, net.ReadUInt(4))

                net.Start("ModernCarDealer.Net.MechanicTriggerButtonPress")
                net.SendToServer()

                self:Remove()
            end
        end
    end
end)

net.Receive("ModernCarDealer.Net.CloseMechanicUI", function() 
    if IsValid(mechanicTriggerButton) then mechanicTriggerButton:Remove() end
end)

function ModernCarDealer:JobDealerCustomize(content, tCar, sGarageName) -- PURPOSE: This is what shows when you try to retrieve a job car.
    local sCurrentVehicleName = tCar.Name

    if sGarageName then
        content = ModernCarDealer.Frame(0, 0, iScrW/1.15, iScrH/1.15, sGarageName) 
        content:Center()    
    end
    
    local frame = vgui.Create("DPanel", content)
    frame:SetPos(0, iScrH/30)
    frame:SetSize(iScrW/1.15, iScrH/1.15 - iScrH/30)
    
    frame.Paint = function(self, w, h)
        -- Background
        draw.RoundedBox(0, 0, 0, w, h, cMainColor)

        surface.SetDrawColor(cSecondaryColor)
        surface.DrawOutlinedRect(-3, -500, 606, iScrH + 500, 3) -- Surrounding mechanic
        draw.SimpleText(ModernCarDealer:GetPhrase("modify_vehicle"), "ModernCarDealer.Font.Small", 6, 0, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.DrawOutlinedRect(600, -500, iScrW, iScrH + 500, 3) -- Surrounding presets
        draw.SimpleText(ModernCarDealer:GetPhrase("presets").." ("..sCurrentVehicleName..")", "ModernCarDealer.Font.Small", 609, 0, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        surface.DrawOutlinedRect(600, iScrH/2 - 120, iScrW, iScrH, 3) -- Surrounding modelframe
        draw.SimpleText(ModernCarDealer:GetPhrase("preview"), "ModernCarDealer.Font.Small", 609, iScrH/2 + 3 - 120, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local iDegree = math.rad(135)
    local iChange = math.rad(1)
    local iRadius = 320 
    local cos, sin = math.cos, math.sin

    local mainGrid = vgui.Create("DPanel", frame)
    mainGrid:SetSize(iScrW/2, iScrW/2)
    mainGrid:SetPos(((frame:GetWide()/2)-mainGrid:GetWide())/2 + frame:GetWide()/2)
    mainGrid:CenterVertical(0.75)
    mainGrid.Paint = function() end

    local tCarPanelModel = vgui.Create("DModelPanel", mainGrid)
    tCarPanelModel:Dock(FILL)
    tCarPanelModel:SetTall(mainGrid:GetTall())
    tCarPanelModel:SetModel(ModernCarDealer.GamemodeVehicles[tCar.Class].Model)

    local mn, mx = tCarPanelModel.Entity:GetRenderBounds()

    tCarPanelModel.Entity:SetSkin(tCar.Skin)

    tCarPanelModel:SetFOV((mx.y-mn.y)/5)
    tCarPanelModel:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
    tCarPanelModel:SetDirectionalLight(BOX_FRONT, Color(40, 40, 40))
   
    function tCarPanelModel:LayoutEntity(Entity) return end

    tCarPanelModel.Think = function()
        tCarPanelModel:SetCamPos(Vector(iRadius*cos(iDegree), iRadius*sin(iDegree), mx.z*0.75))
        tCarPanelModel:SetLookAt(Vector(0,0,30))
    end

    local arrowFrame = vgui.Create("DPanel", frame)
    arrowFrame:Dock(BOTTOM)
    arrowFrame:DockMargin(608, 0, 5, 5)
    arrowFrame:SetTall(48)
    arrowFrame.Paint = function() end
    
    local leftArrow = ModernCarDealer.Button(arrowFrame, "⇦", 0, 0, 0, 0)
    leftArrow:Dock(LEFT)
    leftArrow:SetWide(55)

    leftArrow.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
    end

    leftArrow.Think = function(self)
        if self:IsDown() then
            iDegree = iDegree + iChange
        end
    end

    leftArrow.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end            

    local rightArrow = ModernCarDealer.Button(arrowFrame, "⇨", 0, 0, 0, 0)
    rightArrow:Dock(RIGHT)
    rightArrow:SetWide(55)

    rightArrow.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
    end

    rightArrow.Think = function(self)
        if self:IsDown() then
            iDegree = iDegree - iChange
        end
    end

    rightArrow.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end
    
    local tCarPanelOverlay = vgui.Create("DPanel", mainGrid)
    tCarPanelOverlay:Dock(FILL)
    tCarPanelOverlay.Paint = function() end

    local garageFrame = ModernCarDealer:OpenMechanicUI(tCarPanelModel, frame, content, tCar.CID)

    local sSelectedPreset

    -- Presets

    local presetFrame = ModernCarDealer.Scroll(frame, 0, 0, 0, 0)
    presetFrame:Dock(TOP)
    presetFrame:DockMargin(603, 30, 0, 0)
    presetFrame:SetTall((iScrH/2) - 148)

    local function MCD_RefreshPresets()
        local tPresets = util.JSONToTable(file.Read("moderncardealer/presets.json", "DATA") or "")
        tPresets = tPresets or {}

        presetFrame:Clear()

        local createPreset = presetFrame:Add("DButton")
        createPreset:Dock(TOP)
        createPreset:DockMargin(5, 0, 5, 5)
        createPreset:SetTall(30)
        createPreset:SetTextColor(cTextColor)
        createPreset:SetText(ModernCarDealer:GetPhrase("create_preset"))
        createPreset:SetFont("ModernCarDealer.Font.Small")
        createPreset.Lerp = 0

        createPreset.Paint = function(self, w, h)
            draw.RoundedBox(6, 0, 0, w, h, cSecondaryColor)
        
            if self:IsHovered() then
                self.Lerp = Lerp(0.2, self.Lerp, 25)
            else
                self.Lerp = Lerp(0.1, self.Lerp, 0)
            end

            draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
        end

        local function CreatePreset(sInput, iForceAtID, bDelete)
            local tPreset = tPresets[sCurrentVehicleName] or {}

            local tExistingCIDs = {}
            local iUsableCID 
            for _, tPresetSpecific in pairs(tPreset) do
                table.insert(tExistingCIDs, tPresetSpecific[1])
            end
            for i = 1, 256 do 
                if not table.HasValue(tExistingCIDs, i) then
                    iUsableCID = i
                    break
                end
            end

            if iForceAtID then
                table.remove(tPreset, iForceAtID)

                if not bDelete then
                    table.insert(tPreset, iUsableCID, {#tPreset + 1, sInput, frame.tActivePreset})
                end
            else
                table.insert(tPreset, {iUsableCID, sInput, frame.tActivePreset})
            end

            tPresets[sCurrentVehicleName] = tPreset

            file.Write("moderncardealer/presets.json", util.TableToJSON(tPresets))

            for iKey, iValue in pairs(frame.tActivePreset.Bodygroups) do
                tCarPanelModel.Entity:SetBodygroup(iKey, iValue)
            end

            tCarPanelModel:SetSkin(frame.tActivePreset.Skin)

            tCarPanelModel:SetColor(Color(frame.tActivePreset.Color.r, frame.tActivePreset.Color.g, frame.tActivePreset.Color.b))

            garageFrame:Remove()
            garageFrame = ModernCarDealer:OpenMechanicUI(tCarPanelModel, frame, content, tCar.CID)

            MCD_RefreshPresets()
        end

        createPreset.DoClick = function() ModernCarDealer.StringRequest("Modern Car Dealer", ModernCarDealer:GetPhrase("choose_name"), "Preset 1", function(sInput) CreatePreset(sInput) end) end

        for _, tPreset in pairs(tPresets[sCurrentVehicleName] or {}) do
            local iID = tPreset[1]
            local sName = tPreset[2]
            local tData = tPreset[3]
            local preset = presetFrame:Add("DButton")
            preset:Dock(TOP)
            preset:DockMargin(5, 0, 5, 5)
            preset:SetTall(30)
            preset:SetTextColor(cTextColor)
            preset:SetText(sName)
            preset:SetFont("ModernCarDealer.Font.Small")
            preset.Lerp = 0

            preset.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, cSecondaryColor)
        
                if self:IsHovered() then
                    self.Lerp = Lerp(0.2, self.Lerp, 25)
                else
                    self.Lerp = Lerp(0.1, self.Lerp, 0)
                end

                draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))

                if sSelectedPreset == iID then
                    draw.RoundedBox(6, 0, 0, w, h, Color(cAccentColor.r, cAccentColor.g, cAccentColor.b, 100))
                end
            end

            preset.DoClick = function()
                sSelectedPreset = iID

                for iKey, iValue in pairs(tData.Bodygroups) do
                    tCarPanelModel.Entity:SetBodygroup(iKey, iValue)
                end

                tCarPanelModel.Entity:SetSkin(tData.Skin)

                tCarPanelModel:SetColor(Color(tData.Color.r, tData.Color.g, tData.Color.b))

                garageFrame:Remove()
                garageFrame = ModernCarDealer:OpenMechanicUI(tCarPanelModel, frame, content, tCar.CID)
            
                MCD_RefreshPresets()
            end

            preset.DoRightClick = function()
                local menu = DermaMenu() 

                local load = menu:AddOption("Load", function() preset:DoClick()  end)
                load:SetIcon("icon16/connect.png")

                local save = menu:AddOption("Save", function() CreatePreset(sName, iID) end)
                save:SetIcon("icon16/disk.png")

                local delete = menu:AddOption(ModernCarDealer:GetPhrase("remove"), function() CreatePreset(sName, iID, "XXX") end)
                delete:SetIcon("icon16/delete.png")

                menu:Open()
            end
        end
    end

    MCD_RefreshPresets()
end

net.Receive("ModernCarDealer.Net.TestDriveCheckSuccessful", function()
    local iStartTime = CurTime() + ModernCarDealer.Config.TestDriveTime
    local testDriveFrame = vgui.Create("DPanel")
    testDriveFrame:SetSize(iScrW/3, iScrH/6)
    testDriveFrame:Dock(TOP)
    testDriveFrame:CenterHorizontal()
    testDriveFrame.Paint = function(self, w, h)
        if not LocalPlayer():InVehicle() then self:Remove() end
        surface.SetTextColor(cTextColor)
        surface.SetFont("ModernCarDealer.Font.Main")
        surface.SetTextPos(iScrW/2, 100)

        draw.SimpleText(ModernCarDealer:GetPhrase("test_drive"),"ModernCarDealer.Font.Main", iScrW/2, 50, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)

        local iTextW, iTextH = surface.GetTextSize(ModernCarDealer:GetPhrase("test_drive"))

        draw.RoundedBox(0, (iScrW/2)-(iTextW/2), 50 + (iTextH/2), iTextW, 3, cTextColor)

        -- Information

        draw.SimpleText(string.format(ModernCarDealer:GetPhrase("test_drive_hud"), math.Round((iStartTime - CurTime()))),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 30, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
    end

    timer.Simple(ModernCarDealer.Config.TestDriveTime, function() if IsValid(testDriveFrame) then testDriveFrame:Remove() end end)
end)

function ModernCarDealer:OpenExperimentalGarageUI(sGarageName, tGarageParams, tAvailable) -- PURPOSE: This is the frame of the garage, aka the first thing opened.
    local bSpecificCar = false
    local iStartTime = RealTime()
    local sJobCars = "_personal"
    local iIndex = 0
    local iGarages = 1
    local iVehiclesPerGarge = 4
    local iDistBetweenCars = 200
    local iXOffset = 30
    local iYOffset = 50
    local iZOffset = -20
    local iFloorHeight = 0

    local tVehicles = {}
    for _, tCar in pairs(ModernCarDealer.MyCars or {}) do
        if table.HasValue(tGarageParams, tCar.Dealer) then
            if ModernCarDealer.Config.PlayerCheck[tCar.Check] then
                if ModernCarDealer.Config.PlayerCheck[tCar.Check][1](LocalPlayer()) or not ModernCarDealer.Config.PlayerCheck[tCar.Check][3] then
                    if tCar.JobCar then sJobCars = "" iXOffset = 60 end
                    table.insert(tVehicles, tCar)
                end
            else
                if tCar.JobCar then sJobCars = "" iXOffset = 60 end
                table.insert(tVehicles, tCar)
            end
        end
    end

    local tProps = {
        {Model = "models/painless/cd_garage" .. sJobCars .. "_main.mdl", Material = "", Color = color_white, Angle = Angle(0, 0, 0), Pos = Vector(250, 0, -75), Scale = 8.5},   
        {Model = "models/painless/cd_garage" .. sJobCars .. "_wall.mdl", Material = "", Color = color_white, Angle = Angle(0, 0, 0), Pos = Vector(450, 0, -75), Scale = 8.5},   
    }

    for iIndexAll, tCar in pairs(tVehicles) do
        iIndex = iIndex + 1

        if iIndex > iVehiclesPerGarge then -- Add a new garage when we go over the max vehicles per garage
            iIndex = 1
            iGarages = iGarages + 1
        end

        if iIndex == 1 and iGarages > 1 then -- Adds the wall to each new garage
            table.insert(tProps, {Model = "models/painless/cd_garage" .. sJobCars .. "_wall.mdl", Material = "", Color = color_white, Angle = Angle(0, 0, 0), Pos = Vector(250 + (iGarages*200), 0, -75), Scale = 8.5})
        end

        local tSpawnIndex = ModernCarDealer.GamemodeVehicles[tCar.Class]

        if tSpawnIndex then
            if iIndex == 1 or iIndex == 2 then -- Left Side
                local iSpawnPosOffset = 0
                tCar.FakeAng = Angle(0, 150, 0)

                if ModernCarDealer.SimfPhys[tCar.Class] then
                    tCar.FakeAng = Angle(0, 150 + (ModernCarDealer.GamemodeVehicles[tCar.Class].SpawnAngleOffset or 0), 0)
                    iSpawnPosOffset = (ModernCarDealer.GamemodeVehicles[tCar.Class].SpawnOffset and ModernCarDealer.GamemodeVehicles[tCar.Class].SpawnOffset.z) or 0 
                end

                local vPos = Vector((iDistBetweenCars*iIndex) + ((iGarages - 1)*(iDistBetweenCars*2)) + 30, 125, -65 + iSpawnPosOffset)
                table.insert(tProps, {Model = tSpawnIndex.Model, Material = "", Color = tCar.Color, Angle = tCar.FakeAng, Pos = vPos, Scale = .8, Bodygroups = tCar.Bodygroups, Skin = tCar.Skin, Car = true})
            
                tCar.FakePos = Vector(vPos.x + iXOffset - 200, iYOffset, iZOffset)
            end

            if iIndex == 3 or iIndex == 4 then -- Right Side
                local iSpawnPosOffset = 0
                tCar.FakeAng = Angle(0, 30, 0)
                
                if ModernCarDealer.SimfPhys[tCar.Class] then
                    tCar.FakeAng = Angle(0, 30 + (ModernCarDealer.GamemodeVehicles[tCar.Class].SpawnAngleOffset or 0), 0)
                    iSpawnPosOffset = (ModernCarDealer.GamemodeVehicles[tCar.Class].SpawnOffset and ModernCarDealer.GamemodeVehicles[tCar.Class].SpawnOffset.z) or 0 
                end

                local vPos = Vector((iDistBetweenCars*(iIndex - 2)) + ((iGarages - 1)*(iDistBetweenCars*2)) + 30, -125, -65 + iSpawnPosOffset)
                table.insert(tProps, {Model = tSpawnIndex.Model, Material = "", Color = tCar.Color, Angle = tCar.FakeAng, Pos = vPos, Scale = .8, Bodygroups = tCar.Bodygroups, Skin = tCar.Skin, Car = true})
            
                tCar.FakePos = Vector(vPos.x + iXOffset - 200, -iYOffset, iZOffset)
            end
        end
    end

    if #tVehicles > 4 then -- Extra space because why not...
        iGarages = iGarages + 1
    end

    table.insert(tProps, {Model = "models/painless/cd_garage" .. sJobCars .. "_wall.mdl", Material = "", Color = color_white, Angle = Angle(0, 0, 0), Pos = Vector(250 + (iGarages*200), 0, -75), Scale = 8.5})
    table.insert(tProps, {Model = "models/painless/cd_garage" .. sJobCars .. "_main.mdl", Material = "", Color = color_white, Angle = Angle(0, 180, 0), Pos = Vector((250 + ((iGarages)*200)) - 50, 0, -75), Scale = 8.5})

    local tEntities = {}
    local vRenderPos = Vector(iXOffset, 0, 0)
    local aRenderAngle = Angle(20, 0, 0)
    local cLightColor = Color(107, 132, 151)

    local function MCD_CreateFakeEnts()
        for _, eEnt in pairs(tProps) do
            local eClientside = ClientsideModel(eEnt.Model, RENDERGROUP_OPAQUE)

            if eEnt.Car then
                local mn, mx = eClientside:GetRenderBounds()
                local iDiff = (mx.z - mn.z)/2

                eClientside:SetPos(Vector(eEnt.Pos.x, eEnt.Pos.y, eEnt.Pos.z - (iDiff*0.25) + i3DOffset))
            else
                eClientside:SetPos(Vector(eEnt.Pos.x, eEnt.Pos.y, eEnt.Pos.z))
            end

            eClientside:SetAngles(eEnt.Angle)
            eClientside:SetMaterial(eEnt.Material)
            eClientside:SetModelScale(eClientside:GetModelScale() * eEnt.Scale)
            eClientside.Color = eEnt.Color

            if eEnt.Bodygroups then
                for iKey, iValue in pairs(eEnt.Bodygroups) do
                    eClientside:SetBodygroup(iKey, iValue)
                end
            end

            if eEnt.Skin then
                eClientside:SetSkin(eEnt.Skin)
            end

            eClientside:SetNoDraw(true) -- Change
            table.insert(tEntities, eClientside)
        end
    end

    local function MCD_RemoveFakeEnts()
        for _, eEnt in pairs(tEntities) do
            eEnt:Remove()
        end
    end
    
    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetTitle("")
    frame:SetSize(iScrW, iScrH)

    MCD_CreateFakeEnts()

    frame.Paint = function()
        cam.Start3D(vRenderPos, aRenderAngle, 100, 0, 0, w, h)
            render.SuppressEngineLighting(true)
            for _, eEnt in pairs(tEntities) do
                render.SetColorModulation(eEnt.Color.r/255, eEnt.Color.g/255, eEnt.Color.b/255)

                render.SetLightingOrigin(eEnt:GetPos())
                render.ResetModelLighting(cLightColor.r / 255, cLightColor.g / 255, cLightColor.b / 255 )
                eEnt:DrawModel()
            end
            render.SuppressEngineLighting(false)
        cam.End3D()
    end

    frame.OnClose = function()
        MCD_RemoveFakeEnts()
    end

    local content = vgui.Create("DPanel", frame) 
    content:SetSize(iScrW/2.5, iScrH/3)
    content:SetPos(0, iScrH - (iScrH/3) - 5)
    content:CenterHorizontal()

    content.iHeaderHeight = 30
    content.Paint = function(self, w, h)
        if not bSpecificCar then
            local iLerp = math.EaseInOut(math.min(1, RealTime() - iStartTime), 0.4, 0.8)
            vRenderPos = LerpVector(iLerp, vRenderPos, Vector(iXOffset, 0, 0))
        end

        draw.RoundedBox(5, 0, 1, w, h - 1, cMainColor)

        surface.SetDrawColor(color_black)
        surface.SetMaterial(mGradientDown)
        surface.DrawTexturedRect(0, self.iHeaderHeight * 0.9, w, self.iHeaderHeight * 0.25)

        draw.RoundedBox(5, 0, 0, w, self.iHeaderHeight, cSecondaryColor)
        draw.RoundedBox(0, 0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2, cSecondaryColor)

        if ModernCarDealer.Config.Light then
            surface.SetDrawColor(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25)
            surface.SetMaterial(mGradientUp)
            surface.DrawTexturedRect(0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2)
        end

        draw.SimpleText(ModernCarDealer:GetPhrase("vehicles"), "ModernCarDealer.Font.MediumText", 10, self.iHeaderHeight / 2, cTextColor, 0, 1)
    end

    local closeButton = vgui.Create("DButton", content)
    closeButton:SetPos(content:GetWide() - content.iHeaderHeight*2 + 10, 3)
    closeButton:SetSize(content.iHeaderHeight*2, content.iHeaderHeight + 6)
    closeButton:SetText("")

    closeButton.Paint = function(s, w, h)
        draw.NoTexture()

        surface.SetDrawColor(cTextColor)
        surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 135)
        surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 45)
    end

    closeButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        frame:Remove()
    end

    closeButton.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end

    local vehicleList = ModernCarDealer.Scroll(content, 0, 0, 0, 0)
    vehicleList:Dock(FILL)
    vehicleList:DockMargin(5, 40, 5, 0)

    for _, tCar in pairs(tVehicles) do
        local iHealth = tCar.Health
        local bIsJobCar = tCar.JobCar
        local sCost

        if tCar.Insured then
            sCost = ModernCarDealer:FormatMoney(0)
        else
            sCost = ModernCarDealer:FormatMoney(ModernCarDealer.Config.RepairPrice)
        end

        local bAvailable = true
        for _, tOutCar in pairs(tAvailable) do
            if tOutCar[1] == tCar.CID then
                bAvailable = false
            end
        end

        local vehiclePanel = vgui.Create("DButton", vehicleList)
        vehiclePanel:Dock(TOP)
        vehiclePanel:SetTall(40)
        vehiclePanel:SetText("")
        vehiclePanel.Lerp = 0
        vehiclePanel.iHeaderHeight = 40

        vehiclePanel.Paint = function(self, w, h)
            if sSelected and sSelected == sName then
                draw.RoundedBox(5, 0, 0, w, h, Color(cAccentColor.r, cAccentColor.g, cAccentColor.b, 100))
            elseif self:IsHovered() then
                self.Lerp = Lerp(0.075, self.Lerp, 100)
            else
                self.Lerp = Lerp(0.05, self.Lerp, 0)
            end

            draw.RoundedBox(5, 0, 0, w, h, Color(cSecondaryColor.r, cSecondaryColor.g, cSecondaryColor.b, self.Lerp))

            draw.SimpleText(tCar.Name, "ModernCarDealer.Font.Small", 10, self.iHeaderHeight/2, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            
            if bAvailable then
                draw.SimpleText(ModernCarDealer:GetPhrase("available"), "ModernCarDealer.Font.Small", w - 10, self.iHeaderHeight/2, cWhiteOnWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(ModernCarDealer:GetPhrase("unavailable"), "ModernCarDealer.Font.Small", w - 10, self.iHeaderHeight/2, cWhiteOnWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end

        vehiclePanel.DoClick = function() -- Specific Vehicle Frame
            iStartTime = RealTime()
            bSpecificCar = true

            local content = vgui.Create("DPanel", frame) 
            content:SetSize(iScrW/2.5, iScrH/3)
            content:SetPos(0, iScrH - (iScrH/3) - 5)
            content:CenterHorizontal()

            content.iHeaderHeight = 30
            content.Paint = function(self, w, h)
                local iLerp = math.EaseInOut(math.min(1, RealTime() - iStartTime), 0.4, 0.8)
                vRenderPos = LerpVector(iLerp, Vector(iXOffset, 0, 0), tCar.FakePos)

                draw.RoundedBox(5, 0, 1, w, h - 1, cMainColor)

                surface.SetDrawColor(color_black)
                surface.SetMaterial(mGradientDown)
                surface.DrawTexturedRect(0, self.iHeaderHeight * 0.9, w, self.iHeaderHeight * 0.25)

                draw.RoundedBox(5, 0, 0, w, self.iHeaderHeight, cSecondaryColor)
                draw.RoundedBox(0, 0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2, cSecondaryColor)

                if ModernCarDealer.Config.Light then
                    surface.SetDrawColor(cSecondaryColor.r + 25, cSecondaryColor.g + 25, cSecondaryColor.b + 25)
                    surface.SetMaterial(mGradientUp)
                    surface.DrawTexturedRect(0, self.iHeaderHeight / 2, w, self.iHeaderHeight / 2)
                end

                draw.SimpleText(ModernCarDealer:GetPhrase("vehicles") .. " - " .. tCar.Name, "ModernCarDealer.Font.MediumText", 10, self.iHeaderHeight / 2, cTextColor, 0, 1)
            end

            local closeButton = vgui.Create("DButton", content)
            closeButton:SetPos(content:GetWide() - content.iHeaderHeight*2 + 10, 3)
            closeButton:SetSize(content.iHeaderHeight*2, content.iHeaderHeight + 6)
            closeButton:SetText("")

            closeButton.Paint = function(s, w, h)
                draw.NoTexture()

                surface.SetDrawColor(cTextColor)
                surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 135)
                surface.DrawTexturedRectRotated(w / 2, h * 0.425 - 3, 3, h - 9, 45)
            end

            closeButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")

                content:Remove()

                iStartTime = RealTime()
                bSpecificCar = false
            end

            closeButton.OnCursorEntered = function()
                surface.PlaySound("moderncardealer/rollover.wav")
            end

            local buttonArea = vgui.Create("DPanel", content)
            buttonArea:Dock(FILL)
            buttonArea:DockMargin(0, 30, 0, 0)
            buttonArea:SetText("")
            buttonArea.Paint = function() end
    
            local retrieveButton
            
            local cButtonColor
            if ModernCarDealer.Config.Light then
                cButtonColor = cMainColor
            else
                cButtonColor = cSecondaryColor
            end
    
            if bAvailable then
                retrieveButton = ModernCarDealer.Button(buttonArea, ModernCarDealer:GetPhrase("retrieve"), 0, 0, 0, 0, cButtonColor)
            else
                retrieveButton = ModernCarDealer.Button(buttonArea, ModernCarDealer:GetPhrase("return_garage"), 0, 0, 0, 0, cButtonColor)
            end
    
            retrieveButton:Dock(FILL)
            retrieveButton:DockMargin(5, 5, 5, 5)
    
            retrieveButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
                
                if bIsJobCar and bAvailable and tCar.AllowCustomizing then
                    ModernCarDealer:JobDealerCustomize(frame, tCar, sGarageName)

                    frame:Remove()
                else
                    net.Start("ModernCarDealer.Net.RetrieveCar")
                    net.WriteUInt(tCar.CID, 8)
                    net.SendToServer()
    
                    frame:Remove()
                end
            end
    
            local repairButton
    
            if VC and ModernCarDealer.Config.AllowRepairInDealer and iHealth < 100 and bAvailable then
                repairButton = ModernCarDealer.Button(buttonArea, string.format(ModernCarDealer:GetPhrase("fix"), sCost), 0, 0, 0, 0, cButtonColor)
    
                repairButton.DoClick = function()
                    surface.PlaySound("moderncardealer/click.wav")
                    frame:Remove()
        
                    net.Start("ModernCarDealer.Net.FixCar")
                    net.WriteUInt(tCar.CID, 8)
                    net.SendToServer()
                end
            elseif bAvailable then
                if not (tCar.Price == 0) then 
                    repairButton = ModernCarDealer.Button(buttonArea, string.format("%s (%s)", ModernCarDealer:GetPhrase("sell"), ModernCarDealer:FormatMoney(tCar.Price*ModernCarDealer.Config.SellPercentage)), 0, 0, 0, 0, cButtonColor)
                
                    local function MCD_ButtonFunc()
                        surface.PlaySound("moderncardealer/click.wav")
                        frame:Remove()
            
                        net.Start("ModernCarDealer.Net.SellCar")
                        net.WriteUInt(tCar.CID, 8)
                        net.SendToServer()
                    end
    
                    repairButton.DoClick = function()
                        ModernCarDealer.Query(ModernCarDealer:GetPhrase("unsaved_notice"), "Modern Car Dealer", ModernCarDealer:GetPhrase("yes"), MCD_ButtonFunc, ModernCarDealer:GetPhrase("no"))
                    end
                elseif not tCar.JobCar then
                    repairButton = ModernCarDealer.Button(buttonArea, string.format("%s (%s)", ModernCarDealer:GetPhrase("remove"), ModernCarDealer:FormatMoney(0)), 0, 0, 0, 0, cButtonColor)
                
                    local function MCD_ButtonFunc()
                        surface.PlaySound("moderncardealer/click.wav")
                        frame:Remove()
            
                        net.Start("ModernCarDealer.Net.SellCar")
                        net.WriteUInt(tCar.CID, 8)
                        net.SendToServer()
                    end  
    
                    repairButton.DoClick = function()
                        ModernCarDealer.Query(ModernCarDealer:GetPhrase("vehicle_sold_confirm"), "Modern Car Dealer", ModernCarDealer:GetPhrase("yes"), MCD_ButtonFunc, ModernCarDealer:GetPhrase("no"))
                    end
                end
            end
    
            if IsValid(repairButton) then  
                repairButton:Dock(BOTTOM)
                repairButton:DockMargin(5, 0, 5, 5)
                repairButton:SetTall(60)
            end
        end
    end
end