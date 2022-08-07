local mLogo = Material("moderncardealer/logo.png")
local iLogoW, iLogoH = mLogo:Width()/2.5, mLogo:Height()/2.5

local cMainColor = ModernCarDealer.Config.PrimaryColor
local cSecondaryColor = ModernCarDealer.Config.SecondaryColor
local cAccentColor = ModernCarDealer.Config.AccentColor
local cTextColor = ModernCarDealer.Config.TextColor

local iMenuW, iMenuH = ScrW()/1.45, ScrH()/1.05
local iScrW, iScrH = ScrW(), ScrH()

local tSelectedPoints = {}

local cWhiteOnWhiteColor
if ModernCarDealer.Config.Light then
    cWhiteOnWhiteColor = cSecondaryColor
else
    cWhiteOnWhiteColor = cTextColor
end

function ModernCarDealer:ClearPanel(pPanelToClear)
    for _, pPanel in pairs(pPanelToClear:GetChildren()) do
        pPanel:Remove()
    end
end

function ModernCarDealer:AdminMenu() -- PURPOSE: This is the first opened UI. It contains all options.
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    surface.PlaySound("moderncardealer/notify.wav")

    local frame = ModernCarDealer.Frame(0, 0, iMenuW, iMenuH, "Modern Car Dealer - "..ModernCarDealer:GetPhrase("admin_configuration")) 
    frame:Center()

    local sidebar = vgui.Create("DPanel", frame)
    sidebar:SetPos(0, frame.iHeaderHeight)
    sidebar:SetSize(iMenuW/6, frame:GetTall() - frame.iHeaderHeight)
    sidebar.Paint = function(self, w, h)
        draw.RoundedBox(0, w-3, 0, 3, h, cSecondaryColor)
    end

    local content = vgui.Create("DPanel", frame)
    content:Dock(FILL)
    content:DockMargin(iMenuW/6, 6, 0, 0)
    content.frame = frame

    local cLogoColor

    if ModernCarDealer.Config.Light then
        cLogoColor = Color(cMainColor.r + 8, cMainColor.g + 8, cMainColor.b + 8)
    else
        cLogoColor = Color(cMainColor.r - 2, cMainColor.g - 2, cMainColor.b - 2)
    end

    
    content.Paint = function(self, w, h)
        surface.SetDrawColor(cLogoColor)
        surface.SetMaterial(mLogo)
        surface.DrawTexturedRect(w/2 - iLogoW/2, h/2 - iLogoH/2, iLogoW, iLogoH)
    end

    local modifyCButton = ModernCarDealer.Button(sidebar, ModernCarDealer:GetPhrase("dealers"), 0, 0, 0, 0)
    modifyCButton:SetSize(iMenuW/4, iMenuH/12)
    modifyCButton:Dock(TOP)
    modifyCButton:DockMargin(5, 5, 8, 0)

    modifyCButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:AdminCarDealer(content)
    end

    local modifyNPCButton = ModernCarDealer.Button(sidebar, ModernCarDealer:GetPhrase("npcs"), 0, 0, 0, 0)
    modifyNPCButton:SetSize(iMenuW/4, iMenuH/12)
    modifyNPCButton:Dock(TOP)
    modifyNPCButton:DockMargin(5, 5, 8, 0)

    modifyNPCButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:NPCManager(content)
    end

    local modifyAreaButton = ModernCarDealer.Button(sidebar, ModernCarDealer:GetPhrase("area_manager"), 0, 0, 0, 0)
    modifyAreaButton:SetSize(iMenuW/4, iMenuH/12)
    modifyAreaButton:Dock(TOP)
    modifyAreaButton:DockMargin(5, 5, 8, 0)

    modifyAreaButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:AreaManager(content)
    end

    local playerManager = ModernCarDealer.Button(sidebar, ModernCarDealer:GetPhrase("player_manager"), 0, 0, 0, 0)
    playerManager:SetSize(iMenuW/4, iMenuH/12)
    playerManager:Dock(TOP)
    playerManager:DockMargin(5, 5, 8, 0)

    playerManager.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        frame:Remove()

        ModernCarDealer.StringRequest("Modern Car Dealer", "SteamID:", "", function(sInput)
            net.Start("ModernCarDealer.Net.RequestPlayerData")
            net.WriteString(tostring(util.SteamIDTo64(sInput)))
            net.SendToServer()
        end)
    end

    
    local transferButton = ModernCarDealer.Button(sidebar, ModernCarDealer:GetPhrase("transfer_data"), 0, 0, 0, 0)
    transferButton:SetSize(iMenuW/4, iMenuH/12)
    transferButton:Dock(BOTTOM)
    transferButton:DockMargin(5, 5, 8, 5)

    transferButton.DoClick = function()
        frame:Remove()

        RunConsoleCommand("cardealer_transfer")
    end

    return content
end

function ModernCarDealer:AdminCarDealer(content) -- PURPOSE: This is the creating/modifying car dealers menu.
    -- Add Car Dealer

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuH/12)
    buttonFrame.Paint = function(self, w, h) end


    local addDealerButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("create_dealer"), 0, 0, 0, 0)
    addDealerButton:Dock(LEFT)
    addDealerButton:SetWide(iMenuW/5)


    addDealerButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        ModernCarDealer:ClearPanel(content)
 
        ModernCarDealer:CreateCarDealerInfos(content)
    end

    -- Modify Car Dealers

    local modifyCButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("modify_dealer"), 0, 0, 0, 0)
    modifyCButton:Dock(RIGHT)
    modifyCButton:SetWide(iMenuW/5)

    modifyCButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:ModifyCarDealersMenu(content)
    end
end

function ModernCarDealer:ModifyCarDealersMenu(content) -- PURPOSE: This is the modifying car dealers menu.
    local tCarCategories = {}

    for ent, v in pairs(ModernCarDealer.GamemodeVehicles) do if not (v.Category == "Chairs") then if not tCarCategories[v.Category] then tCarCategories[v.Category] = {} end table.insert(tCarCategories[v.Category] , {v.Name, ent}) end end
    
 
    local carDealersLabel = vgui.Create("DLabel", content) -- What is the name of the dealer?
    carDealersLabel:Dock(TOP)
    carDealersLabel:SetTall(30)
    carDealersLabel:SetFont("ModernCarDealer.Font.BoldText")
    carDealersLabel:SetText(ModernCarDealer:GetPhrase("dealer_name")..":")
    carDealersLabel:SetTextColor(cWhiteOnWhiteColor)

    local tDealers = {}
    for sDealerName, _ in pairs(ModernCarDealer.Cars) do
        table.insert(tDealers, sDealerName)
    end

    local carDealers = ModernCarDealer.ComboBox(content, 0, 0, 0, 0, "", tDealers)
    carDealers:Dock(TOP)
    carDealers:DockMargin(0, 10, 0, 20)
    carDealers:SetTall(40)
    carDealers:SetValue("")

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuH/12)
    buttonFrame.Paint = function(self, w, h) end

    local nextButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("next"), 0, 0, 0, 0)
    nextButton:Dock(RIGHT)
    nextButton:SetWide(iMenuW/5)

    nextButton.DoClick = function()
        if carDealers:GetValue() == "" then
            ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("dealer_set_notice"))            
            return
        end

        surface.PlaySound("moderncardealer/click.wav")
 
        local bIsJobDealer = false
        for _, tCar in pairs(ModernCarDealer.Cars[carDealers:GetValue()]) do 
            if tCar.JobDealer then bIsJobDealer = true end
        end

        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:CreateCarDealer(content, tostring(carDealers:GetValue()), ModernCarDealer.Cars[carDealers:GetValue()], bIsJobDealer)
    end

    local backButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
    backButton:Dock(LEFT)
    backButton:SetWide(iMenuW/5)

    backButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:AdminCarDealer(content)
    end
end

function ModernCarDealer:CreateCarDealerInfos(content, sReturnName) -- PURPOSE: This is the creating car dealers menu. (First Step)
    ModernCarDealer:UpdateVehicles()

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuH/12)
    buttonFrame.Paint = function(self, w, h) end

    local carDealersLabel = vgui.Create("DLabel", content) -- What is the name of the dealer?
    carDealersLabel:Dock(TOP)
    carDealersLabel:SetTall(30)
    carDealersLabel:SetFont("ModernCarDealer.Font.BoldText")
    carDealersLabel:SetText(ModernCarDealer:GetPhrase("dealer_name")..":")
    carDealersLabel:SetTextColor(cWhiteOnWhiteColor)

    local carDealerName = ModernCarDealer.TextEntry(content, ModernCarDealer:GetPhrase("default_dealer_name"))
    carDealerName:Dock(TOP)
    carDealerName:DockMargin(0, 10, 0, 20)
    carDealerName:SetTall(40)

    local isJobDealerLabel = vgui.Create("DLabel", content) -- Is it a job dealer?
    isJobDealerLabel:Dock(TOP)
    isJobDealerLabel:SetTall(30)
    isJobDealerLabel:SetFont("ModernCarDealer.Font.BoldText")
    isJobDealerLabel:SetText((ModernCarDealer:GetPhrase("job_dealer")..":"))
    isJobDealerLabel:SetTextColor(cWhiteOnWhiteColor)

    local isJobDealerFrame = vgui.Create("DPanel", content)
    isJobDealerFrame:Dock(TOP)
    isJobDealerFrame:DockMargin(0, 10, 0, 20)
    isJobDealerFrame:SetSize(50, 50)

    isJobDealerFrame.Paint = function() end

    local isJobDealer = ModernCarDealer.CheckBox(isJobDealerFrame, 0, 0, 0, 0, false)
    isJobDealer:SetChecked(false)
    isJobDealer:SetSize(50, 50)

    if sReturnName then carDealerName:SetValue(sReturnName) end

    local nextButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("next"), 0, 0, 0, 0)
    nextButton:Dock(RIGHT)
    nextButton:SetWide(iMenuW/5)

    nextButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        if carDealerName:GetValue() == "" then
            ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("input_name_notice"))
            return
        end

        if not (tonumber(carDealerName:GetValue()) == nil) then
            ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("input_integer_notice"))
            return
        end

        if ModernCarDealer.Cars[carDealerName:GetValue()] then
            ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("exists"))
            return
        end

        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:CreateCarDealer(content, tostring(carDealerName:GetValue()), nil, isJobDealer:GetChecked())
    end

    local backButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
    backButton:Dock(LEFT)
    backButton:SetWide(iMenuW/5)

    backButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:AdminCarDealer(content)
    end
end

function ModernCarDealer:CreateCarDealer(content, sCarDealerName, tModifyData, bIsJobDealer) -- PURPOSE: This is the creating car dealers menu. (Second Step)
    local tCarCategories = {}
    local tFinal = {}

    for ent, v in pairs(ModernCarDealer.GamemodeVehicles) do
        local sCategory = v.Category or "Other"

        if not (sCategory == "Chairs") then
            if not tCarCategories[sCategory] then
   
                tCarCategories[sCategory] = {} 
            end 
            
            table.insert(tCarCategories[sCategory] , {v.Name, ent}) 
        end 
    end

    tFinal["Name"] = sCarDealerName

    local pPlayer = LocalPlayer()

    content.selectedtype = ModernCarDealer:GetPhrase("completed")
    content.Queue = {}
    content.Completed = {}
    content.tChooserCategories = {} -- These are the categorys in the car chooser (not specific creator)
    content.tSpecificCategories = {} -- These are the categorys in the car creator (specific)
    content.MainVehicleButtons = {}
    
    if tModifyData then 
        for _, v in pairs(tModifyData) do if not table.HasValue(tModifyData, v.Category) then table.insert(content.tSpecificCategories, v.Category) end end
    end

    local rightbuttonFrame = vgui.Create("DPanel", content)
    rightbuttonFrame:Dock(RIGHT)
    rightbuttonFrame:SetSize(iMenuW/7, iMenuH/3)
    rightbuttonFrame.Paint = function() end

    -- Create Button
    local createButton = ModernCarDealer.Button(rightbuttonFrame, ModernCarDealer:GetPhrase("create"), 0, 0, 0, 0)
    createButton:Dock(BOTTOM)
    createButton:DockMargin(0, 5, 0, 0)
    createButton:SetTall(iMenuH/12)
    
    createButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
        
        -- FINAL FUNCTION
        ModernCarDealer.Query(ModernCarDealer:GetPhrase("finalize_notice"), "Modern Car Dealer", ModernCarDealer:GetPhrase("yes"), function() ModernCarDealer:ClientAddCarDealer(content.Completed, tFinal["Name"]) ModernCarDealer:ClearPanel(content) ModernCarDealer:AdminCarDealer(content) end, ModernCarDealer:GetPhrase("no"))
    end

    
    -- Back Button

    local backButton = ModernCarDealer.Button(content, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
    backButton:Dock(LEFT)
    backButton:SetSize(iMenuW/7, iMenuH/12)
    backButton:DockMargin(0, content:GetTall() - iMenuH/12 + 1, 0, 0) -- BUG FIX

    backButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer.Query(ModernCarDealer:GetPhrase("unsaved_notice"), "Modern Car Dealer", ModernCarDealer:GetPhrase("yes"), function() if not tModifyData then ModernCarDealer:ClearPanel(content) ModernCarDealer:CreateCarDealerInfos(content, tFinal["Name"]) else ModernCarDealer:ClearPanel(content) ModernCarDealer:AdminCarDealer(content, false) end end,ModernCarDealer:GetPhrase("no"))
    end


    -- Delete Button

    if tModifyData then
        local deleteButton = ModernCarDealer.Button(rightbuttonFrame, ModernCarDealer:GetPhrase("remove"), 0, 0, 0, 0)
        deleteButton:Dock(BOTTOM)
        deleteButton:DockMargin(0, 5, 0, 0)
        deleteButton:SetTall(iMenuH/12 - 4)

        deleteButton.DoClick = function()
            surface.PlaySound("moderncardealer/click.wav")
 
            ModernCarDealer.Query(ModernCarDealer:GetPhrase("delete_notice"), "Modern Car Dealer", ModernCarDealer:GetPhrase("yes"), function()

            local content = ModernCarDealer:AdminMenu()
            timer.Simple(0.002, function() ModernCarDealer:ClearPanel(content) ModernCarDealer:AdminCarDealer(content) end)

            ModernCarDealer:ClientDeleteCarDealer(sCarDealerName)
            
            end,ModernCarDealer:GetPhrase("no"))
        end
    
    end

    -- Refresh Functions

    local function MCD_RefreshQueue(bottomScroll)
        content.selectedtype = ModernCarDealer:GetPhrase("queue")

        bottomScroll:Clear()

        local queue = bottomScroll:Add("DCollapsibleCategory")
        queue:Dock(TOP)
        queue:SetTall(45)
        queue:DockMargin(6, 0, 0, 10)
        queue:SetExpanded(1)
        queue:SetLabel("")

        queue.Paint = function(self, w, h)
            surface.SetDrawColor(Color(cMainColor.r - 3, cMainColor.g - 3, cMainColor.b - 3))
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(cSecondaryColor)
            surface.DrawRect(0, 0, w, 22)

            draw.SimpleText(ModernCarDealer:GetPhrase("queue"), "ModernCarDealer.Font.BoldTextSmall", 3, 0, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    
        for _, tCarInfo in pairs(content.Queue) do
            local queueSubInfo = queue:Add(tCarInfo)
            queueSubInfo:SetFont("ModernCarDealer.Font.Small")
            queueSubInfo:SetTextColor(cWhiteOnWhiteColor)
            queueSubInfo:SetTall(25)

            queueSubInfo.DoClick = function(self, w, h)
                queueSubInfo:Remove()
                table.RemoveByValue(content.Queue, tCarInfo)

                local tVehicleInfo = ModernCarDealer.GamemodeVehicles[tCarInfo]

                local vehicleButton = content.tChooserCategories[tVehicleInfo.Category]:Add(tVehicleInfo.Name)
                vehicleButton:SetFont("ModernCarDealer.Font.Small")
                vehicleButton:SetTextColor(cTextColor)
                vehicleButton:SetTall(25)

                vehicleButton.DoClick = function()
                    surface.PlaySound("moderncardealer/click.wav")
 
                    table.insert(content.Queue, tCarInfo)
                
                    if content.selectedtype == ModernCarDealer:GetPhrase("queue") then
                        MCD_RefreshQueue(bottomScroll)
                    end

                    vehicleButton:Remove()

                end

                vehicleButton.DoRightClick = function()
                    ModernCarDealer:CreateSpecific(content, bIsJobDealer, tCarInfo, vehicleButton, content)
                end
            end

            queueSubInfo.DoRightClick = function()
                ModernCarDealer:CreateSpecific(content, bIsJobDealer, tCarInfo, queueSubInfo, content)
            end
        end
    end

    local function MCD_RefreshCompleted(bottomScroll)
        content.selectedtype = ModernCarDealer:GetPhrase("completed")

        bottomScroll:Clear()

        local completed = bottomScroll:Add("DCollapsibleCategory")
        completed:Dock(TOP)
        completed:SetTall(45)
        completed:DockMargin(6, 0, 0, 10)
        completed:SetExpanded(1)
        completed:SetLabel("")

        completed.Paint = function(self, w, h)
            surface.SetDrawColor(Color(cMainColor.r - 3, cMainColor.g - 3, cMainColor.b - 3))
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(cSecondaryColor)
            surface.DrawRect(0, 0, w, 22)

            draw.SimpleText(ModernCarDealer:GetPhrase("completed"), "ModernCarDealer.Font.BoldTextSmall", 3, 0, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        content.CompletedPanel = completed

        for _, tCarInfo in pairs(content.Completed) do
            local completedSubInfo = completed:Add(tCarInfo.Class)
            completedSubInfo:SetFont("ModernCarDealer.Font.Small")
            completedSubInfo:SetTextColor(cWhiteOnWhiteColor)
            completedSubInfo:SetTall(25)

            completedSubInfo.DoClick = function(self, w, h)

                completedSubInfo:Remove()
                table.RemoveByValue(content.Completed, tCarInfo)

                local tVehicleInfo = ModernCarDealer.GamemodeVehicles[tCarInfo.Class]

                local vehicleButton = content.tChooserCategories[tVehicleInfo.Category]:Add(tVehicleInfo.Name)
                vehicleButton:SetFont("ModernCarDealer.Font.Small")
                vehicleButton:SetTextColor(cWhiteOnWhiteColor)
                vehicleButton:SetTall(25)

                vehicleButton.DoClick = function()
                    surface.PlaySound("moderncardealer/click.wav")
 
                    table.insert(content.Queue, tCarInfo.Class)
                
                    if content.selectedtype == ModernCarDealer:GetPhrase("queue") then
                        MCD_RefreshQueue(bottomScroll)
                    end

                    vehicleButton:Remove()
                end

                vehicleButton.DoRightClick = function()
                    ModernCarDealer:CreateSpecific(content, bIsJobDealer, tCarInfo.Class, vehicleButton, content)
                end
            end

            completedSubInfo.DoRightClick = function() -- Context: Right clicking in the completed section
                local tVehicleInfo = ModernCarDealer.GamemodeVehicles[tCarInfo.Class]

                local vehicleButton = content.tChooserCategories[tVehicleInfo.Category]:Add(tVehicleInfo.Name)
                vehicleButton:SetFont("ModernCarDealer.Font.Small")
                vehicleButton:SetTextColor(cWhiteOnWhiteColor)
                vehicleButton:SetTall(25)

                vehicleButton.DoClick = function()
                    surface.PlaySound("moderncardealer/click.wav")
 
                    table.insert(content.Queue, tCarInfo.Class)
                
                    if content.selectedtype == ModernCarDealer:GetPhrase("queue") then
                        MCD_RefreshQueue(bottomScroll)
                    end

                    vehicleButton:Remove()
                end

                vehicleButton.DoRightClick = function()
                    ModernCarDealer:CreateSpecific(content, bIsJobDealer, tCarInfo.Class, vehicleButton)
                end

                ModernCarDealer:CreateSpecific(content, bIsJobDealer, tCarInfo.Class, vehicleButton, content, nil, completedSubInfo, tCarInfo) -- Here is the actually important part
            end
        end
    end
    

    -- Completed/Queue Box

    local queuecompletedcontent = vgui.Create("DPanel", content)
    queuecompletedcontent:SetSize(iMenuW/2, iMenuH/5)
    queuecompletedcontent:SetPos(0, iMenuH/2 + 10 + 40 + 5)
    queuecompletedcontent:CenterHorizontal()

    queuecompletedcontent.Paint = function(self, w, h)
        surface.SetDrawColor(cSecondaryColor)
        surface.DrawOutlinedRect(0, 0, w, h, 3)
    end


    local bottomScroll = ModernCarDealer.Scroll(queuecompletedcontent, 0, 0, 0, 0)
    bottomScroll:SetSize(queuecompletedcontent:GetWide(), queuecompletedcontent:GetTall() - 9)
    bottomScroll:SetPos(queuecompletedcontent:GetWide() - queuecompletedcontent:GetWide() - 3, 3)

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:SetPos(0, iMenuH/2 + 10)
    buttonFrame:SetSize(400, 40)
    buttonFrame:CenterHorizontal()

    buttonFrame.Paint = function() end

    -- Completed

    local completedBox = vgui.Create("DButton", buttonFrame)

    completedBox:Dock(LEFT)
    completedBox:SetWide(buttonFrame:GetWide()/2 - 2.5)
    completedBox:SetFont("ModernCarDealer.Font.BoldText")
    completedBox:SetText("")
    completedBox:SetTextColor(cTextColor)
    completedBox:SetContentAlignment(4)
    completedBox.Lerp = 0

    completedBox.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, cSecondaryColor)
    
        if self:IsHovered() then
            self.Lerp = Lerp(0.2, self.Lerp, 25)
        else
            self.Lerp = Lerp(0.1, self.Lerp, 0)
        end
        
        draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))

        draw.SimpleText(ModernCarDealer:GetPhrase("completed"), "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
    end

    completedBox.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        MCD_RefreshCompleted(bottomScroll)
    end

    completedBox.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end
    

    -- Queue

    local queueBox = vgui.Create("DButton", buttonFrame)
    queueBox:Dock(RIGHT)
    queueBox:SetWide(buttonFrame:GetWide()/2 - 2.5)
    queueBox:SetFont("ModernCarDealer.Font.BoldText")
    queueBox:SetText("")
    queueBox:SetTextColor(cTextColor)
    queueBox:SetContentAlignment(4)
    queueBox.Lerp = 0

    queueBox.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, cSecondaryColor)
    
        if self:IsHovered() then
            self.Lerp = Lerp(0.2, self.Lerp, 25)
        else
            self.Lerp = Lerp(0.1, self.Lerp, 0)
        end
        
        draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))

        draw.SimpleText(ModernCarDealer:GetPhrase("queue"), "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
    end

    queueBox.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        MCD_RefreshQueue(bottomScroll)
    end

    queueBox.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end

    -- Scroll Panel

    local closeButtonMarginScroll = 7.5

    local categoriescontent = vgui.Create("DPanel", content)
    categoriescontent:SetSize(content:GetWide(), iMenuH/2)
    categoriescontent:SetPos(0, 0)

    categoriescontent.Paint = function(self, w, h)
        surface.SetDrawColor(cSecondaryColor)
        surface.DrawOutlinedRect(0, 0, w, h, 3)
    end

    local catScroll = ModernCarDealer.Scroll(categoriescontent, 0, 0, 0, 0)
    catScroll:SetSize(categoriescontent:GetWide() - 6, categoriescontent:GetTall())
    catScroll:SetPos(categoriescontent:GetWide() - catScroll:GetWide() - 3, 3)


    -- Categories
    for sCategoryName, tCarTable in SortedPairs(tCarCategories) do
        local massEdit = vgui.Create("DCollapsibleCategory", catScroll)
        massEdit:Dock(TOP)
        massEdit:SetTall(45)
        massEdit:DockMargin(0, 0, 0, 10)
        massEdit:SetExpanded(0)
        massEdit:SetLabel("")

        content.tChooserCategories[sCategoryName] = massEdit

        massEdit.Paint = function(self, w, h) 
            surface.SetDrawColor(Color(cMainColor.r - 3, cMainColor.g - 3, cMainColor.b - 3))
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(cSecondaryColor)
            surface.DrawRect(0, 0, w, 22)

            draw.SimpleText(sCategoryName, "ModernCarDealer.Font.BoldTextSmall", 3, 0, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        for _, sCarName in SortedPairsByMemberValue(tCarTable, 1) do
            local vehicleButton = massEdit:Add(sCarName[1])
            vehicleButton:SetFont("ModernCarDealer.Font.Small")
            vehicleButton:SetTextColor(cWhiteOnWhiteColor)
            vehicleButton:SetTall(25)

            content.MainVehicleButtons[sCarName[1]] = vehicleButton

            vehicleButton.DoClick = function()
                surface.PlaySound("moderncardealer/click.wav")
 
                table.insert(content.Queue, sCarName[2])
            
                if content.selectedtype == ModernCarDealer:GetPhrase("queue") then
                    MCD_RefreshQueue(bottomScroll)
                end

                vehicleButton:Remove()
            end

            vehicleButton.DoRightClick = function()
                ModernCarDealer:CreateSpecific(content, bIsJobDealer, sCarName[2], vehicleButton, content)
            end
        end
    end

    function ModernCarDealer:Complete(tInformationToSubmit, vehicleButtonPanel)
        table.insert(content.Completed, tInformationToSubmit)
        table.RemoveByValue(content.Queue, tInformationToSubmit.Class)

        if IsValid(vehicleButtonPanel) then
            vehicleButtonPanel:Remove()
        end

        MCD_RefreshCompleted(bottomScroll)
    end


    -- Process the Queue

    local processButton = ModernCarDealer.Button(rightbuttonFrame, ModernCarDealer:GetPhrase("process_queue"), 0, 0, 0, 0)
    processButton:Dock(BOTTOM)
    processButton:DockMargin(0, 5, 0, 0)
    processButton:SetTall(iMenuH/12)
    
    processButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        if #content.Queue == 0 then ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("empty_queue_notice")) return end

        pPlayer.MCD_iQueueIndex = 1
        
        ModernCarDealer:CreateSpecific(content, bIsJobDealer, content.Queue[#content.Queue], nil, content, content.Queue)
    end

    if tModifyData then
        for iIndex, tDataInfo in pairs(tModifyData) do
            local tModifyDataSubmit = {}
            tModifyDataSubmit.Name = tDataInfo.Name
            tModifyDataSubmit.Class = tDataInfo.Class
            tModifyDataSubmit.Price = tDataInfo.Price
            tModifyDataSubmit.Check = tDataInfo.Check
            tModifyDataSubmit.Category = tDataInfo.Category
            tModifyDataSubmit.AllowCustomizing = tDataInfo.AllowCustomizing
            tModifyDataSubmit.ForcedSkin = tDataInfo.ForcedSkin

            ModernCarDealer:Complete(tModifyDataSubmit, vehicleButtonPanel)
            if IsValid(content.MainVehicleButtons[tModifyDataSubmit.Name]) then content.MainVehicleButtons[tModifyDataSubmit.Name]:Remove() end
        end
    end

    MCD_RefreshCompleted(bottomScroll)
end

function ModernCarDealer:CreateSpecific(content, bIsJobDealer, sGivenName, vehicleButtonPanel, framePanel, tQueue, sModify, tCarTable) -- PURPOSE: This is the UI you see when you are creating/changing a specific car.
    local tVehicleInfo = ModernCarDealer.GamemodeVehicles[sGivenName]
    local sModel = tVehicleInfo.Model
    local sName = tVehicleInfo.Name

    surface.SetFont("ModernCarDealer.Font.Main")
    local iNameW, iNameH = surface.GetTextSize(sName)

    local tInformationToSubmit = {}

    local pPlayer = LocalPlayer()

    local frame = vgui.Create("DFrame", content)
    frame:SetSize(content:GetWide(), content:GetTall())
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    local sPrice = ModernCarDealer:GetPhrase("price")..":"
    local sCustomCheck = ModernCarDealer:GetPhrase("custom_check")..":"
    local sCategoryText = ModernCarDealer:GetPhrase("category")..":"
    local sAllowCustomizing = ModernCarDealer:GetPhrase("allow_customizing")..":"
    local sForceSkin = ModernCarDealer:GetPhrase("force_skin")..":"

    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, cMainColor)
        draw.SimpleText(sName, "ModernCarDealer.Font.Main", 0, 0, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
        draw.RoundedBox(0, 0, iNameH, iNameW, 2, cWhiteOnWhiteColor)

        if not bIsJobDealer then
            draw.SimpleText(sPrice, "ModernCarDealer.Font.Main", 0, 80, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
            draw.SimpleText(sCustomCheck, "ModernCarDealer.Font.Main", 0, 220, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
            draw.SimpleText(sCategoryText, "ModernCarDealer.Font.Main", 0, 360, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
        else
            draw.SimpleText(sCustomCheck, "ModernCarDealer.Font.Main", 0, 80, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
            draw.SimpleText(sCategoryText, "ModernCarDealer.Font.Main", 0, 220, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
            draw.SimpleText(sAllowCustomizing, "ModernCarDealer.Font.Main", 0, 360, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
            draw.SimpleText(sForceSkin, "ModernCarDealer.Font.Main", 0, 480, cWhiteOnWhiteColor, TEXT_ALIGN_LEFT)
        end
    end
    
    -- Back Button
    local buttonFrame = vgui.Create("DPanel", frame)
    buttonFrame:SetSize(frame:GetWide(), iMenuH/12)
    buttonFrame:SetPos(0, frame:GetTall() - iMenuH/12 + 1)
    buttonFrame.Paint = function() end

    local backButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
    backButton:SetWide(iMenuW/8)
    backButton:Dock(LEFT)

    backButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        frame:Remove()
    end

    -- Input
    local carPrice
    if not bIsJobDealer then
        carPrice = ModernCarDealer.TextEntry(frame, "0")
        carPrice:Dock(TOP)
        carPrice:DockMargin(0, 120, iMenuW/2.5, 0)
        carPrice:SetTall(48)
        if tCarTable then
            carPrice:SetValue(tCarTable.Price)
        end
        carPrice:SetNumeric(true)
    end

    local carUserGroups = ModernCarDealer.ComboBox(frame, 0, 0, 0, 0, "None", {})
    carUserGroups:Dock(TOP)
    carUserGroups:DockMargin(0, 90, iMenuW/2.5, 0)
    if bIsJobDealer then
        carUserGroups:DockMargin(0, 120, iMenuW/2.5, 0)
    end
    carUserGroups:SetTall(48)
    carUserGroups:AddChoice("None Selected")
    carUserGroups:SetValue("None Selected")
    if tCarTable then
        carUserGroups:SetValue(tCarTable.Check)
    end

    for fCheck, fCheckData in pairs(ModernCarDealer.Config.PlayerCheck) do
        carUserGroups:AddChoice(fCheck)
    end


    local carSpecificCategory = ModernCarDealer.ComboBox(frame, 0, 0, 0, 0, "None", {})
    carSpecificCategory.Options = {}
    carSpecificCategory:Dock(TOP)
    carSpecificCategory:DockMargin(0, 95, iMenuW/2.5, 0)
    carSpecificCategory:SetTall(48)

    if tCarTable then
        carSpecificCategory:SetValue(tCarTable.Category)
    end
    carSpecificCategory:SetFont("ModernCarDealer.Font.Text")

    carSpecificCategory:AddChoice("Create Category")
    for _, sSpecificCategory in pairs(framePanel.tSpecificCategories) do
        
        if not table.HasValue(carSpecificCategory.Options, sSpecificCategory) then
            carSpecificCategory:AddChoice(sSpecificCategory)
            table.insert(carSpecificCategory.Options, sSpecificCategory)
        end
    end

    carSpecificCategory.OnSelect = function(_, _, sText)
        if sText == "Create Category" then
            ModernCarDealer.StringRequest("Modern Car Dealer", ModernCarDealer:GetPhrase("choose_name"), ModernCarDealer:GetPhrase("category"), function(sInput)
                table.insert(framePanel.tSpecificCategories, sInput)
                carSpecificCategory:Clear()
                carSpecificCategory.Options = {}

                carSpecificCategory:AddChoice("Create Category")
                for _, sSpecificCategory in pairs(framePanel.tSpecificCategories) do
                    if not table.HasValue(carSpecificCategory.Options, sSpecificCategory) then
                        carSpecificCategory:AddChoice(sSpecificCategory)
                        table.insert(carSpecificCategory.Options, sSpecificCategory)
                    end
                end
                carSpecificCategory:SetValue(sInput)

            end, nil, "Add", "Cancel")
        end
    end

    local displayPanel = vgui.Create("DPanel", frame)
    displayPanel:SetSize(frame:GetWide()/2.5, frame:GetWide()/3)
    displayPanel:SetPos(frame:GetWide() - displayPanel:GetWide() - 5, 0)
    displayPanel:CenterVertical()

    displayPanel.Paint = function() end

    -- Main Grid

    local grid1 = vgui.Create("DPanel", displayPanel)
    grid1:SetSize(displayPanel:GetWide(), displayPanel:GetTall())
    grid1:SetPos(0, 0)
    
    grid1.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200))
    end


    local grid1Model = vgui.Create("DModelPanel", grid1)
    grid1Model:Dock(FILL)
    grid1Model:SetTall(grid1:GetTall() - 30)

    grid1Model:SetModel(sModel)
    local mn, mx = grid1Model.Entity:GetRenderBounds()

    grid1Model:SetCamPos(Vector(-140, mx.y*2, mx.z*0.75))
    grid1Model:SetFOV(40)
    grid1Model:SetLookAt(Vector(20,0,30))
    grid1Model:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
    grid1Model:SetDirectionalLight(BOX_FRONT, Color(40, 40, 40))

    grid1Model.Think = function()
        
        grid1Model:SetColor(frame.SelectedColor or color_white)

    end

    function grid1Model:LayoutEntity(Entity) return end
    grid1Model.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
    end

    -- Grid Overlay

    local gridOverlay = vgui.Create("DPanel", frame)
    gridOverlay:SetSize(frame:GetWide()/2.2, frame:GetWide()/2)
    gridOverlay:SetPos(frame:GetWide() - gridOverlay:GetWide(), iMenuH/8)
    gridOverlay.Paint = function() end

    local allowCustomizing
    local forceSkin
    local forceSkinCheckbox
    if bIsJobDealer then
        allowCustomizing = ModernCarDealer.CheckBox(frame, 0, 0, 0, 0)
        allowCustomizing:SetSize(50, 50)
        allowCustomizing:SetPos(5, 360 + 70)

        if tCarTable then
            allowCustomizing:SetChecked(tCarTable.AllowCustomizing)
        end

        if not (grid1Model.Entity:SkinCount() == 0) then
            forceSkinCheckbox = ModernCarDealer.CheckBox(frame, 0, 0, 0, 0)
            forceSkinCheckbox:SetSize(50, 50)
            forceSkinCheckbox:SetPos(5, 480 + 70)

            if tCarTable and tCarTable.ForcedSkin then
                forceSkinCheckbox:SetValue(true)
            end

            forceSkin = ModernCarDealer.ComboBox(frame, 0, 0, 0, 0, "None", {})
            forceSkin:SetSize(frame:GetWide()-(iMenuW/1.75 + 50) - 110, 48)
            forceSkin:SetPos(100, 480 + 70)
            
            for i = 0, grid1Model.Entity:SkinCount() do
                if i == 0 and tCarTable and not tCarTable.ForcedSkin then
                    forceSkin:SetValue("Skin "..tostring(i))
                end
                forceSkin:AddChoice("Skin "..tostring(i), i)
            end

            forceSkin.OnSelect = function(_, _, _, iSkin)
                grid1Model.Entity:SetSkin(iSkin)
            end

            if tCarTable and tCarTable.ForcedSkin then
                forceSkin:SetValue("Skin "..tostring(tCarTable.ForcedSkin))
                grid1Model.Entity:SetSkin(tCarTable.ForcedSkin)
            end
        end
    end

    -- Create Button

    local createButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("create"), 0, 0, 0, 0)
    createButton:SetSize(iMenuW/8, iMenuH/3)
    createButton:Dock(RIGHT)

    createButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
        frame:Remove()

        if sModify then
            sModify:Remove()
            table.RemoveByValue(framePanel.Completed, tCarTable)
        end
        
        if tQueue and #framePanel.Queue == 0 then return end

        tInformationToSubmit.Name = tVehicleInfo.Name
        tInformationToSubmit.Class = sGivenName
        if bIsJobDealer then
            tInformationToSubmit.Price = 0
            tInformationToSubmit.AllowCustomizing = allowCustomizing:GetChecked()
            tInformationToSubmit.JobDealer = bIsJobDealer
            if forceSkinCheckbox:GetChecked() == true then
                tInformationToSubmit.ForcedSkin = forceSkin:GetOptionData(forceSkin:GetSelectedID())
            end
        else
            tInformationToSubmit.Price = tonumber(carPrice:GetValue()) or 0 
        end
        tInformationToSubmit.Check = carUserGroups:GetValue() or "None"
        tInformationToSubmit.Category = carSpecificCategory:GetValue() or "None"
 
        if (ModernCarDealer.SimfPhys and ModernCarDealer.SimfPhys[sGivenName]) or (ModernCarDealer.Planes and ModernCarDealer.Planes[sGivenName]) then
            tInformationToSubmit.SimfPhys = true -- LFS CHECK 1
        end 

        ModernCarDealer:Complete(tInformationToSubmit, vehicleButtonPanel)

        if tQueue and not (framePanel.Queue[1] == nil) then ModernCarDealer:CreateSpecific(content, bIsJobDealer, framePanel.Queue[1], vehicleButtonPanel, framePanel, framePanel.Queue) end
    end
end
function ModernCarDealer:ClientAddCarDealer(tSubmitTable, sDealerName) -- PURPOSE: Boring compression and net message shenanigans.
    local tTableToSend = util.Compress(util.TableToJSON({tSubmitTable, sDealerName}))

    net.Start("ModernCarDealer.Net.ClientAddCarDealer")
    net.WriteUInt(#tTableToSend, 22)
    net.WriteData(tTableToSend, #tTableToSend)
    net.SendToServer()
end

function ModernCarDealer:ClientDeleteCarDealer(sDealerName) -- PURPOSE: Boring compression and net message shenanigans.
    net.Start("ModernCarDealer.Net.ClientDeleteCarDealer")
    net.WriteString(tostring(sDealerName))
    net.SendToServer()
end

function ModernCarDealer:NPCManager(content) -- PURPOSE: This is the tool creation menu.
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end
   
    local tDealers = {}
    local tGarages = {}
    for iIndex, tNPC in pairs(ModernCarDealer.NPCs) do
        tNPC.Index = iIndex
        if tNPC.Type == 1 then
            table.insert(tGarages, tNPC)
        else
            table.insert(tDealers, tNPC)
        end
    end
  
    local iDealerLen = 0 for _, _ in pairs(tDealers) do iDealerLen = iDealerLen + 1 end

    local iGarageLen = 0 for _, _ in pairs(tGarages) do iGarageLen = iGarageLen + 1 end


    if not (iDealerLen == 0) then
        local dealersLabel = vgui.Create("DLabel", content)
        dealersLabel:Dock(TOP)
        dealersLabel:DockMargin(0, 10, 0, 0)
        dealersLabel:SetTall(30)
        dealersLabel:SetFont("ModernCarDealer.Font.MediumText")
        dealersLabel:SetText(ModernCarDealer:GetPhrase("dealer_npcs")..":")
        dealersLabel:SetTextColor(cWhiteOnWhiteColor)

        local dealersFrame = ModernCarDealer.Scroll(content, 0, 0, 0, 0)
        dealersFrame:Dock(TOP)
        dealersFrame:DockMargin(0, 10, 0, 0)
        dealersFrame:SetTall(iScrH/5)
        dealersFrame.Paint = function(self, w, h) end

        for iIndex, tData in pairs(tDealers) do
            local preset = dealersFrame:Add("DButton")
            preset:Dock(TOP)
            preset:DockMargin(0, 0, 0, 5)
            preset:SetTall(30)
            preset:SetTextColor(cTextColor)
            preset:SetText(tData.Name)
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
            end

            preset.DoClick = function()
                local menu = DermaMenu() 

                local save = menu:AddOption(ModernCarDealer:GetPhrase("move_here"), function()
                    net.Start("ModernCarDealer.Net.ClientModifyEntity")
                    net.WriteUInt(tData.Index, 32)
                    net.WriteBool(true)
                    net.SendToServer()
                end)
                save:SetIcon("icon16/disk.png")

                local delete = menu:AddOption(ModernCarDealer:GetPhrase("remove"), function()
                    net.Start("ModernCarDealer.Net.ClientDeleteEntity")
                    net.WriteUInt(tData.Index, 32)
                    net.SendToServer()

                    iDealerLen = iDealerLen - 1
                    if iDealerLen == 0 then dealersFrame:Remove() dealersLabel:Remove() end

                    preset:Remove()
                end)
                delete:SetIcon("icon16/delete.png")

                menu:Open()
            end
        end
    end

    if not (iGarageLen == 0) then
        local garageLabel = vgui.Create("DLabel", content)
        garageLabel:Dock(TOP)
        garageLabel:DockMargin(0, 10, 0, 0)
        garageLabel:SetTall(30)
        garageLabel:SetFont("ModernCarDealer.Font.MediumText")
        garageLabel:SetText(ModernCarDealer:GetPhrase("garage_npcs")..":")
        garageLabel:SetTextColor(cWhiteOnWhiteColor)

        local garageFrame = ModernCarDealer.Scroll(content, 0, 0, 0, 0)
        garageFrame:Dock(TOP)
        garageFrame:DockMargin(0, 10, 0, 0)
        garageFrame:SetTall(iScrH/5)
        garageFrame.Paint = function(self, w, h) end

        for iIndex, tData in pairs(tGarages) do
            local preset = garageFrame:Add("DButton")
            preset:Dock(TOP)
            preset:DockMargin(0, 0, 0, 5)
            preset:SetTall(30)
            preset:SetTextColor(cTextColor)
            preset:SetText(tData.Name)
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
            end

            preset.DoClick = function()
                local menu = DermaMenu() 

                local save = menu:AddOption(ModernCarDealer:GetPhrase("move_here"), function()
                    net.Start("ModernCarDealer.Net.ClientModifyEntity")
                    net.WriteUInt(tData.Index, 32)
                    net.WriteBool(true)
                    net.SendToServer()
                end)
                save:SetIcon("icon16/disk.png")

                local delete = menu:AddOption(ModernCarDealer:GetPhrase("remove"), function()
                    net.Start("ModernCarDealer.Net.ClientDeleteEntity")
                    net.WriteUInt(tData.Index, 32)
                    net.SendToServer()

                    iGarageLen = iGarageLen - 1
                    if iGarageLen == 0 then garageFrame:Remove() garageLabel:Remove() end

                    preset:Remove()
                end)
                delete:SetIcon("icon16/delete.png")

                menu:Open()
            end
        end
    end

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuH/12)
    buttonFrame.Paint = function(self, w, h) end

    local dealerButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("create_dealer_npc"), 0, 0, 0, 0)
    dealerButton:Dock(LEFT)
    dealerButton:SetWide(iMenuW/5)

    dealerButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)
        
        ModernCarDealer:ToolCreateDealer(content)
    end

    local retrieverButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("create_garage_npc"), 0, 0, 0, 0)
    retrieverButton:Dock(RIGHT)
    retrieverButton:SetWide(iMenuW/5)

    retrieverButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)
        
        ModernCarDealer:ToolCreateGarage(content)
    end
end

function ModernCarDealer:AreaManager(content)
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuH/12)
    buttonFrame:CenterHorizontal()
    buttonFrame.Paint = function(self, w, h) end

    --[[
    local spawnPointButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("vehicle_spawn_points"), 0, 0, 0, 0)
    spawnPointButton:Dock(LEFT)
    spawnPointButton:SetWide(iMenuW/5)
    
    spawnPointButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        content.frame:Remove()
        
        ModernCarDealer:SpawnPointCreator()

        hook.Call("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown")
    end
    ]]--

    local mechanicButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("upgrade_area"), 0, 0, 0, 0)
    mechanicButton:Dock(FILL)

    mechanicButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        content.frame:Remove()

        ModernCarDealer:MechanicPointCreator(content)
    end
end

function ModernCarDealer:PlayerManager(tData, iID)
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    local frame = ModernCarDealer.Frame(0, 0, iMenuW/1.5, iMenuH/1.5, "Modern Car Dealer - "..ModernCarDealer:GetPhrase("player_manager")) 
    frame:Center()

    local vehiclesLabel = vgui.Create("DLabel", frame) -- What is the name of the dealer?
    vehiclesLabel:Dock(TOP)
    vehiclesLabel:DockMargin(5, 5, 5, 5)
    vehiclesLabel:SetTall(30)
    vehiclesLabel:SetFont("ModernCarDealer.Font.BoldText")
    vehiclesLabel:SetText(ModernCarDealer:GetPhrase("vehicles")..":")
    vehiclesLabel:SetTextColor(cMainColor)

    local vehiclesFrame = ModernCarDealer.Scroll(frame, 0, 0, 0, 0)
    vehiclesFrame:Dock(TOP)
    vehiclesFrame:DockMargin(5, 5, 5, 5)
    vehiclesFrame:SetTall(frame:GetTall()/1.5)

    vehiclesFrame:Clear()

    local bHasCars = false

    for iIndex, tCar in pairs(tData) do
        if not tCar.JobCar then
            bHasCars = true

            local vehicle = vehiclesFrame:Add("DButton")
            vehicle:Dock(TOP)
            vehicle:DockMargin(5, 0, 5, 5)
            vehicle:SetTall(30)
            vehicle:SetTextColor(cTextColor)
            vehicle:SetText(tCar.Name)
            vehicle:SetFont("ModernCarDealer.Font.Small")
            vehicle.Lerp = 0

            vehicle.Paint = function(self, w, h)
                draw.RoundedBox(6, 0, 0, w, h, cSecondaryColor)
            
                if self:IsHovered() then
                    self.Lerp = Lerp(0.2, self.Lerp, 25)
                else
                    self.Lerp = Lerp(0.1, self.Lerp, 0)
                end

                draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))
            end

            vehicle.DoClick = function(self)
                local menu = DermaMenu() 

                local delete = menu:AddOption(ModernCarDealer:GetPhrase("remove"), function() 
                    net.Start("ModernCarDealer.Net.DeletePlayerCar")
                    net.WriteUInt(tCar.CID, 8)
                    net.WriteString(iID)
                    net.SendToServer()

                    surface.PlaySound("moderncardealer/notify.wav")

                    table.remove(tData, iIndex)

                    if #tData == 0 then
                        vehiclesLabel:SetTextColor(cMainColor)
                    end

                    self:Remove()
                end)
                
                delete:SetIcon("icon16/delete.png")

                menu:Open()
            end
        end
    end

    if bHasCars == true then
        vehiclesLabel:SetColor(cWhiteOnWhiteColor)
    end

    local giveVehicles = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
end

function ModernCarDealer:ToolCreateDealer(content) -- PURPOSE: This is the tool creation menu's dealer entity menu..
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end
  
    local iMenuHo = iMenuH -- Everyone loves spacing
    local iMenuWo = iMenuW
    local iMenuH = content:GetTall()
    local iMenuW = content:GetWide()

    local vPlayerPos = LocalPlayer():GetPos()
    local vPlayerAngle = LocalPlayer():GetAngles()

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuHo/12)
    buttonFrame.Paint = function(self, w, h) end

    local backButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
    backButton:Dock(LEFT)
    backButton:SetWide(iMenuWo/5)

    backButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:NPCManager(content)
    end

    -- Input

    local formcontent = ModernCarDealer.Scroll(content, 0, 0, 0, 0)
    formcontent:SetPos(0, 0)
    formcontent:SetSize(iMenuW/2 - 50, iMenuH/1.25)
    formcontent.Paint = function() end
 
    local dealerNameLabel = vgui.Create("DLabel", formcontent) -- What is the name of the dealer?
    dealerNameLabel:Dock(TOP)
    dealerNameLabel:SetTall(30)
    dealerNameLabel:SetFont("ModernCarDealer.Font.BoldText")
    dealerNameLabel:SetText(ModernCarDealer:GetPhrase("dealer_name")..":")
    dealerNameLabel:SetTextColor(cWhiteOnWhiteColor)

    local dealerName = ModernCarDealer.TextEntry(formcontent, ModernCarDealer:GetPhrase("default_dealer_name"))
    dealerName:Dock(TOP)
    dealerName:DockMargin(0, 10, 0, 20)
    dealerName:SetValue(ModernCarDealer:GetPhrase("default_dealer_name"))
    dealerName:SetFont("ModernCarDealer.Font.Text")
    dealerName:SetTall(40)

    local dealerCheckLabel = vgui.Create("DLabel", formcontent) -- What check should the dealer use?
    dealerCheckLabel:Dock(TOP)
    dealerCheckLabel:SetTall(30)
    dealerCheckLabel:SetFont("ModernCarDealer.Font.BoldText")
    dealerCheckLabel:SetText(ModernCarDealer:GetPhrase("custom_check")..":")
    dealerCheckLabel:SetTextColor(cWhiteOnWhiteColor)
   
    local dealerCheck = ModernCarDealer.ComboBox(formcontent, x, y, w, h, "None Selected", {})
    dealerCheck:Dock(TOP)
    dealerCheck:DockMargin(0, 10, 0, 20)
    dealerCheck:SetTall(40)
    dealerCheck:AddChoice("None Selected")
    dealerCheck:SetValue("None Selected")

    for fCheck, fCheckData in pairs(ModernCarDealer.Config.PlayerCheck) do
        dealerCheck:AddChoice(fCheck)
    end

    local dealerCategoryLabel = vgui.Create("DLabel", formcontent) -- What dealer should the dealer use?
    dealerCategoryLabel:Dock(TOP)
    dealerCategoryLabel:SetTall(30)
    dealerCategoryLabel:SetFont("ModernCarDealer.Font.BoldText")
    dealerCategoryLabel:SetText(ModernCarDealer:GetPhrase("dealer_name"),":")
    dealerCategoryLabel:SetTextColor(cWhiteOnWhiteColor)

    local dealerCategory = ModernCarDealer.ComboBox(formcontent, x, y, w, h, "None Selected", {})
    dealerCategory:Dock(TOP)
    dealerCategory:DockMargin(0, 10, 0, 20)
    dealerCategory:SetTall(40)
    dealerCategory:SetValue("")

    for iDealerName, iDealerInfo in pairs(ModernCarDealer.Cars) do
        local isJobDealer = false
        for iIndex, tSpecificInfo in pairs(iDealerInfo) do
            if tSpecificInfo.JobDealer then
                isJobDealer = true

                break
            end
        end
        if not isJobDealer then
            dealerCategory:AddChoice(iDealerName)
        end
    end

    local dealerModelLabel = vgui.Create("DLabel", formcontent)
    dealerModelLabel:Dock(TOP)
    dealerModelLabel:SetTall(40)
    dealerModelLabel:SetFont("ModernCarDealer.Font.BoldText")
    dealerModelLabel:SetText(ModernCarDealer:GetPhrase("dealer_model")..":")
    dealerModelLabel:SetTextColor(cWhiteOnWhiteColor)
    

    local dealerModel = ModernCarDealer.TextEntry(formcontent, "models/Humans/Group02/Female_04.mdl")
    dealerModel:Dock(TOP)
    dealerModel:DockMargin(0, 10, 0, 20)
    dealerModel:SetTall(40)

    local isComputerLabel = vgui.Create("DLabel", formcontent)
    isComputerLabel:Dock(TOP)
    isComputerLabel:SetTall(30)
    isComputerLabel:SetFont("ModernCarDealer.Font.BoldText")
    isComputerLabel:SetText((ModernCarDealer:GetPhrase("computer_model")))
    isComputerLabel:SetTextColor(cWhiteOnWhiteColor)

    local isComputerFrame = vgui.Create("DPanel", formcontent)
    isComputerFrame:Dock(TOP)
    isComputerFrame:DockMargin(0, 10, 0, 20)
    isComputerFrame:SetSize(50, 50)

    isComputerFrame.Paint = function() end

    local isComputer = ModernCarDealer.CheckBox(isComputerFrame, 0, 0, 0, 0, false)
    isComputer:SetChecked(false)
    isComputer:SetSize(50, 50)
    isComputer.Think = function(self)
        if self:GetChecked() then
            dealerModel:SetValue("models/painless/monitor.mdl")
        end
    end
    isComputer.OnChange = function(self, bValue)
        if not bValue then 
            dealerModel:SetValue("models/Humans/Group02/Female_04.mdl")
        end
    end


    local dealerModelPanel = vgui.Create("DPanel", content)
    dealerModelPanel:SetSize(content:GetWide()/4, content:GetTall()/1.5)
    dealerModelPanel:SetPos(iMenuW/1.75, iMenuH/4)
    dealerModelPanel:CenterVertical()
    
    dealerModelPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200))
    end


    local displayPanelModel = vgui.Create("DModelPanel", dealerModelPanel)
    displayPanelModel:Dock(FILL)
    displayPanelModel:SetTall(dealerModelPanel:GetTall() - 30)
    displayPanelModel:SetCamPos(Vector(50, 0, 40))
    displayPanelModel:SetFOV(60)
    displayPanelModel:SetLookAt(Vector(0,0,40))

    displayPanelModel.Think = function()
        displayPanelModel:SetModel(dealerModel:GetValue())
    end

    function displayPanelModel:LayoutEntity(Entity) return end

    -- Create Button

    local createButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("create"), 0, 0, 0, 0)
    createButton:Dock(RIGHT)
    createButton:SetWide(iMenuWo/5)

    createButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        if dealerCategory:GetValue() == "" then ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("dealer_set_notice")) return end
        
        for _, tNPC in pairs(ModernCarDealer.NPCs) do
            if tNPC.Name == dealerName:GetValue() then
                ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("exists"))
                return
            end
        end

        local tInformationToSubmit = {}
        tInformationToSubmit[dealerName:GetValue()] = {
            ["Check"] = dealerCheck:GetValue(),
            ["Dealer"] = dealerCategory:GetValue(),
            ["Model"] = dealerModel:GetValue(),
            ["Position"] = vPlayerPos,
            ["Angles"] = vPlayerAngle
        }
        
        
        local tTableToSend = util.Compress(util.TableToJSON(tInformationToSubmit))

        net.Start("ModernCarDealer.Net.ClientCreateEntity")
        net.WriteUInt(0, 2)
        net.WriteUInt(#tTableToSend, 22)
        net.WriteData(tTableToSend, #tTableToSend)
        net.SendToServer()

        timer.Simple(0.01, function() if IsValid(content) then ModernCarDealer:ClearPanel(content) ModernCarDealer:NPCManager(content) end end)
        timer.Simple(0.5, function() if IsValid(content) then ModernCarDealer:ClearPanel(content) ModernCarDealer:NPCManager(content) end end)
    end
end

function ModernCarDealer:ToolCreateGarage(content) -- PURPOSE: This is the tool creation menu's dealer entity menu.
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    local iMenuHo = iMenuH -- Everyone loves spacing
    local iMenuWo = iMenuW
    local iMenuH = content:GetTall()
    local iMenuW = content:GetWide()

    local vPlayerPos = LocalPlayer():GetPos()
    local vPlayerAngle = LocalPlayer():GetAngles()

    local buttonFrame = vgui.Create("DPanel", content)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iMenuHo/12)
    buttonFrame.Paint = function(self, w, h) end

    -- Back Button

    local backButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("back"), 0, 0, 0, 0)
    backButton:Dock(LEFT)
    backButton:SetWide(iMenuWo/5)

    backButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        ModernCarDealer:ClearPanel(content)

        ModernCarDealer:NPCManager(content)
    end

    -- INPUT

    local formcontent = ModernCarDealer.Scroll(content, 0, 0, 0, 0)
    formcontent:SetPos(0, 0)
    formcontent:SetSize(iMenuW/2 - 50, iMenuH/1.2)
    formcontent.Paint = function() end

    local garageNameLabel = vgui.Create("DLabel", formcontent) -- What is the name of the garage?
    garageNameLabel:Dock(TOP)
    garageNameLabel:SetTall(30)
    garageNameLabel:SetFont("ModernCarDealer.Font.BoldText")
    garageNameLabel:SetText(ModernCarDealer:GetPhrase("garage_name"))
    garageNameLabel:SetTextColor(cWhiteOnWhiteColor)
  
    local garageName = ModernCarDealer.TextEntry(formcontent, ModernCarDealer:GetPhrase("default_garage_name"))
    garageName:Dock(TOP)
    garageName:DockMargin(0, 10, 0, 20)
    garageName:SetTall(40)

    local garageModelLabel = vgui.Create("DLabel", formcontent) -- What is the model of the garage?
    garageModelLabel:Dock(TOP)
    garageModelLabel:SetTall(30)
    garageModelLabel:SetFont("ModernCarDealer.Font.BoldText")
    garageModelLabel:SetText(ModernCarDealer:GetPhrase("garage_model"))
    garageModelLabel:SetTextColor(cWhiteOnWhiteColor)

    local garageModel = ModernCarDealer.TextEntry(formcontent, "models/odessa.mdl")
    garageModel:Dock(TOP)
    garageModel:DockMargin(0, 10, 0, 20)
    garageModel:SetTall(40)

    local garageCategoryLabel = vgui.Create("DLabel", formcontent) -- What are the categories the garage uses?
    garageCategoryLabel:Dock(TOP)
    garageCategoryLabel:SetTall(30)
    garageCategoryLabel:SetFont("ModernCarDealer.Font.BoldText")
    garageCategoryLabel:SetText(ModernCarDealer:GetPhrase("categories"))
    garageCategoryLabel:SetTextColor(cWhiteOnWhiteColor)

    local garageCategoryContent = vgui.Create("DPanel", formcontent) 
    garageCategoryContent:Dock(TOP)
    garageCategoryContent:DockMargin(0, 10, 0, 20)
    garageCategoryContent:SetTall(200)
    garageCategoryContent.Paint = function() end

    local garageCategoryFrame = vgui.Create("DPanel", garageCategoryContent)
    garageCategoryFrame:Dock(TOP)
    garageCategoryFrame:SetTall(garageCategoryContent:GetTall()/2)
    garageCategoryFrame.Paint = function(self, w, h) end

    local garageCategoryHeader = vgui.Create("DPanel", garageCategoryFrame)
    garageCategoryHeader:Dock(TOP)
    garageCategoryHeader:SetTall(20)
    garageCategoryHeader.Paint = function(self, w, h)
        surface.SetDrawColor(cSecondaryColor)
        surface.DrawRect(0, 0, w, h)
    
        draw.SimpleText(ModernCarDealer:GetPhrase("queue"), "ModernCarDealer.Font.BoldTextSmall", 3, 0, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local garageCategory = vgui.Create("DListView", garageCategoryFrame)
    garageCategory:Dock(FILL)
    garageCategory:SetHideHeaders(true)
    garageCategory:AddColumn("")

    garageCategory.Paint = function(self, w, h)
        surface.SetDrawColor(Color(cTextColor.r, cTextColor.g, cTextColor.b, 250))
        surface.DrawRect(0, 0, w, h)
    end

    local garageCategoryUseFrame = vgui.Create("DPanel", garageCategoryContent)
    garageCategoryUseFrame:Dock(TOP)
    garageCategoryUseFrame:DockMargin(0, 10, 0, 0)
    garageCategoryUseFrame:SetTall(garageCategoryContent:GetTall()/2)
    garageCategoryUseFrame.Paint = function(self, w, h) end

    local garageCategoryUseHeader = vgui.Create("DPanel", garageCategoryUseFrame)
    garageCategoryUseHeader:Dock(TOP)
    garageCategoryUseHeader:SetTall(20)
    garageCategoryUseHeader.Paint = function(self, w, h)
        surface.SetDrawColor(cSecondaryColor)
        surface.DrawRect(0, 0, w, h)
    
        draw.SimpleText(ModernCarDealer:GetPhrase("use"), "ModernCarDealer.Font.BoldTextSmall", 3, 0, cTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local garageCategoryUse = vgui.Create("DListView", garageCategoryUseFrame)
    garageCategoryUse:Dock(FILL)
    garageCategoryUse:AddColumn("")
    garageCategoryUse:SetHideHeaders(true)

    garageCategoryUse.Paint = function(self, w, h)
        surface.SetDrawColor(Color(cTextColor.r, cTextColor.g, cTextColor.b, 250))
        surface.DrawRect(0, 0, w, h)
    end
    
    for igarageName, iDealerInfo in pairs(ModernCarDealer.Cars) do
        local line = garageCategory:AddLine(igarageName)
        line:SetTall(25)

        local label = line:SetColumnText(1, igarageName)
        label:SetFont("ModernCarDealer.Font.Small")
        label:SetTextColor(color_black)
    end

    garageCategory.OnRowSelected = function(_, iIndex, pDealer)
        garageCategory:RemoveLine(iIndex)

        local line = garageCategoryUse:AddLine(pDealer:GetColumnText(1))
        line:SetTall(25)

        local label = line:SetColumnText(1, pDealer:GetColumnText(1))
        label:SetFont("ModernCarDealer.Font.Small")
        label:SetTextColor(color_black)
    end

    garageCategoryUse.OnRowSelected = function(_, iIndex, pDealer)
        garageCategoryUse:RemoveLine(iIndex)


        local line = garageCategory:AddLine(pDealer:GetColumnText(1))
        line:SetTall(25)

        local label = line:SetColumnText(1, pDealer:GetColumnText(1))
        label:SetFont("ModernCarDealer.Font.Small")
        label:SetTextColor(color_black)        
    end

    local garageCheckLabel = vgui.Create("DLabel", formcontent) -- What check should the dealer use?
    garageCheckLabel:Dock(TOP)
    garageCheckLabel:SetTall(30)
    garageCheckLabel:SetFont("ModernCarDealer.Font.BoldText")
    garageCheckLabel:SetText(ModernCarDealer:GetPhrase("custom_check")..":")
    garageCheckLabel:SetTextColor(cWhiteOnWhiteColor)
   
    local garageCheck = ModernCarDealer.ComboBox(formcontent, x, y, w, h, "None Selected", {})
    garageCheck:Dock(TOP)
    garageCheck:DockMargin(0, 10, 0, 20)
    garageCheck:SetTall(40)
    garageCheck:AddChoice("None Selected")
    garageCheck:SetValue("None Selected")

    for fCheck, fCheckData in pairs(ModernCarDealer.Config.PlayerCheck) do
        garageCheck:AddChoice(fCheck)
    end

    local spawnPointsLabel = vgui.Create("DLabel", formcontent)
    spawnPointsLabel:Dock(TOP)
    spawnPointsLabel:SetTall(30)
    spawnPointsLabel:SetFont("ModernCarDealer.Font.BoldText")
    spawnPointsLabel:SetText(ModernCarDealer:GetPhrase("vehicles") .. " Spawn")
    spawnPointsLabel:SetTextColor(cWhiteOnWhiteColor)
   
    local spawnPointsButton = vgui.Create("DButton", formcontent)
    spawnPointsButton:SetText("")
    spawnPointsButton.Lerp = 0

    spawnPointsButton.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, cColor or cSecondaryColor)
   
        if self:IsHovered() then
            self.Lerp = Lerp(0.2, self.Lerp, 25)
        else
            self.Lerp = Lerp(0.1, self.Lerp, 0)
        end
        
        draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))

        if #tSelectedPoints > 0 then
            draw.SimpleText(string.format("%s (%s)", ModernCarDealer:GetPhrase("update"), #tSelectedPoints), "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
        else
            draw.SimpleText(ModernCarDealer:GetPhrase("update"), "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
        end
    end

    spawnPointsButton.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end

    spawnPointsButton:Dock(TOP)
    spawnPointsButton:DockMargin(0, 10, 0, 20)
    spawnPointsButton:SetTall(50)

    spawnPointsButton.DoClick = function()
        ModernCarDealer:SpawnPointCreator(content.frame)

        tSelectedPoints = {}

        content.frame:Hide()
    end

    local isComputerLabel = vgui.Create("DLabel", formcontent)
    isComputerLabel:Dock(TOP)
    isComputerLabel:SetTall(30)
    isComputerLabel:SetFont("ModernCarDealer.Font.BoldText")
    isComputerLabel:SetText((ModernCarDealer:GetPhrase("computer_model")))
    isComputerLabel:SetTextColor(cWhiteOnWhiteColor)

    local isComputerFrame = vgui.Create("DPanel", formcontent)
    isComputerFrame:Dock(TOP)
    isComputerFrame:DockMargin(0, 10, 0, 20)
    isComputerFrame:SetSize(50, 50)

    isComputerFrame.Paint = function() end

    local isComputer = ModernCarDealer.CheckBox(isComputerFrame, 0, 0, 0, 0, false)
    isComputer:SetChecked(false)
    isComputer:SetSize(50, 50)
    isComputer.Think = function(self)
        if self:GetChecked() then
            garageModel:SetValue("models/painless/monitor.mdl")
        end
    end
    isComputer.OnChange = function(self, bValue)
        if not bValue then 
            garageModel:SetValue("models/odessa.mdl")
        end
    end

    local is3DLabel = vgui.Create("DLabel", formcontent)
    is3DLabel:Dock(TOP)
    is3DLabel:SetTall(30)
    is3DLabel:SetFont("ModernCarDealer.Font.BoldText")
    is3DLabel:SetText("3D")
    is3DLabel:SetTextColor(cWhiteOnWhiteColor)

    local is3DFrame = vgui.Create("DPanel", formcontent)
    is3DFrame:Dock(TOP)
    is3DFrame:DockMargin(0, 10, 0, 20)
    is3DFrame:SetSize(50, 50)

    is3DFrame.Paint = function() end

    local is3D = ModernCarDealer.CheckBox(is3DFrame, 0, 0, 0, 0, false)
    is3D:SetChecked(true)
    is3D:SetSize(50, 50)

    local enterVehicleLabel = vgui.Create("DLabel", formcontent)
    enterVehicleLabel:Dock(TOP)
    enterVehicleLabel:SetTall(30)
    enterVehicleLabel:SetFont("ModernCarDealer.Font.BoldText")
    enterVehicleLabel:SetText(ModernCarDealer:GetPhrase("enter_vehicle"))
    enterVehicleLabel:SetTextColor(cWhiteOnWhiteColor)

    local enterVehicleFrame = vgui.Create("DPanel", formcontent)
    enterVehicleFrame:Dock(TOP)
    enterVehicleFrame:DockMargin(0, 10, 0, 20)
    enterVehicleFrame:SetSize(50, 50)

    enterVehicleFrame.Paint = function() end

    local enterVehicle = ModernCarDealer.CheckBox(enterVehicleFrame, 0, 0, 0, 0, false)
    enterVehicle:SetChecked(false)
    enterVehicle:SetSize(50, 50)

    local garageModelPanel = vgui.Create("DPanel", content)
    garageModelPanel:SetSize(content:GetWide()/4, content:GetTall()/1.5)
    garageModelPanel:SetPos(iMenuW/1.75, iMenuH/4)
    garageModelPanel:CenterVertical()
    
    garageModelPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(200, 200, 200))
    end

    local displayPanelModel = vgui.Create("DModelPanel", garageModelPanel)
    displayPanelModel:Dock(FILL)
    displayPanelModel:SetTall(garageModelPanel:GetTall() - 30)
    displayPanelModel:SetCamPos(Vector(50, 0, 40))
    displayPanelModel:SetFOV(60)
    displayPanelModel:SetLookAt(Vector(0,0,40))

    displayPanelModel.Think = function()
        displayPanelModel:SetModel(garageModel:GetValue())
    end

    function displayPanelModel:LayoutEntity(Entity) return end

    local createButton = ModernCarDealer.Button(buttonFrame, ModernCarDealer:GetPhrase("create"), 0, 0, 0, 0)
    createButton:Dock(RIGHT)
    createButton:SetWide(iMenuWo/5)

    createButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        if #garageCategoryUse:GetLines() == 0 then ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("dealer_set_notice")) return end

        for _, tNPC in pairs(ModernCarDealer.NPCs) do
            if tNPC.Name == garageName:GetValue() then
                ModernCarDealer.Notice("Modern Car Dealer", ModernCarDealer:GetPhrase("exists"))
                return
            end
        end

        timer.Simple(0.01, function() if IsValid(content) then ModernCarDealer:ClearPanel(content) ModernCarDealer:NPCManager(content) end end)
        timer.Simple(0.5, function() if IsValid(content) then ModernCarDealer:ClearPanel(content) ModernCarDealer:NPCManager(content) end end)

        local tDealers = {}

        for _, pDealer in pairs(garageCategoryUse:GetLines()) do
            table.insert(tDealers, pDealer:GetValue(1))
        end

        local tInformationToSubmit = {}
        tInformationToSubmit[garageName:GetValue()] = {
            ["Dealers"] = tDealers,
            ["Check"] = garageCheck:GetValue(),
            ["Model"] = garageModel:GetValue(),
            ["Position"] = vPlayerPos,
            ["Angles"] = vPlayerAngle,
            ["is3D"] = is3D:GetChecked(),
            ["EnterVehicle"] = enterVehicle:GetChecked(),
            ["SpawnPoints"] = tSelectedPoints
        }

        local tTableToSend = util.Compress(util.TableToJSON(tInformationToSubmit))

        net.Start("ModernCarDealer.Net.ClientCreateEntity")
        net.WriteUInt(1, 2)
        net.WriteUInt(#tTableToSend, 22)
        net.WriteData(tTableToSend, #tTableToSend)
        net.SendToServer()
    end

end

function ModernCarDealer:ModifyCarDealerEntity(eEntity) -- PURPOSE: This is the tool creation menu.
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    surface.PlaySound("moderncardealer/notify.wav")

    local frame = ModernCarDealer.Frame(0, 0, iScrW/3, iScrH/5, "Modify Entity") 
    frame:Center()

    local saveButton = ModernCarDealer.Button(frame, "Save Position", 0, 0, 0, 0)
    saveButton:SetSize(iScrW/8, iScrH/13)
    saveButton:SetPos((frame:GetWide()/2) - (saveButton:GetWide()) - 30, (frame:GetTall()/2) - (saveButton:GetTall()/2) + 15)

    saveButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        frame:Remove()

        net.Start("ModernCarDealer.Net.ClientModifyEntity")
        net.WriteUInt(eEntity:GetNWInt("MCD_Index"), 32)
        net.WriteBool(false)
        net.SendToServer()
    end

    local deleteButton = ModernCarDealer.Button(frame, ModernCarDealer:GetPhrase("remove"), 0, 0, 0, 0)
    deleteButton:SetSize(iScrW/8, iScrH/13 + 5)
    deleteButton:SetPos((frame:GetWide()/2) + 30, (frame:GetTall()/2) - (deleteButton:GetTall()/2) + 15)

    deleteButton.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")
 
        frame:Remove()

        net.Start("ModernCarDealer.Net.ClientDeleteEntity")
        net.WriteUInt(eEntity:GetNWInt("MCD_Index"), 32)
        net.SendToServer()
    end
end

function ModernCarDealer:SpawnPointCreator(content) -- PURPOSE: This is the spawn point creator for where cars spawn.
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    local frame = vgui.Create("DPanel")
    frame:SetSize(iScrW, iScrH)
    frame:SetPos(0, 0)

    frame.Paint = function(self, w, h)
        surface.SetTextColor(cTextColor)
        surface.SetFont("ModernCarDealer.Font.Main")
        surface.SetTextPos(iScrW/2, 100)

        draw.SimpleText(ModernCarDealer:GetPhrase("spawn_point_creation_tool"), "ModernCarDealer.Font.Main", iScrW/2, 50, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)

        local iTextW, iTextH = surface.GetTextSize(ModernCarDealer:GetPhrase("spawn_point_creation_tool"))

        draw.RoundedBox(0, (iScrW/2)-(iTextW/2), 50 + (iTextH/2), iTextW, 3, cTextColor)

        -- Information

        draw.SimpleText(ModernCarDealer:GetPhrase("enter_point"),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 30, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        draw.SimpleText(ModernCarDealer:GetPhrase("delete_point"),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 75, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        draw.SimpleText(ModernCarDealer:GetPhrase("tab_exit"),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 120, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
    end

    LocalPlayer().MCD_bCreatingSpawnPoints = true

    net.Start("ModernCarDealer.Net.ClientSpawnPointStart")
    net.SendToServer()

    tSelectedPoints = {}

    local function MCD_FindClosest()
        local tLowest = {100000000000}

        for _, eEnt in pairs(ents.FindByClass("mcd_carspawn")) do
            local vPos = eEnt:GetPos()
            local iDist = vPos:DistToSqr(LocalPlayer():GetEyeTrace().HitPos)

            if iDist < tLowest[1] then
                tLowest = {iDist, eEnt}
            end
        end

        return tLowest[2]
    end

    hook.Add("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown", function(_, iKeyRaw)
        if iKeyRaw == KEY_TAB then
            local tNewPoints = {}

            for _, eEnt in pairs(tSelectedPoints) do
                local iMinLocal, iMaxLocal = eEnt:GetModelBounds()
                local iMin, iMax = eEnt:LocalToWorld(iMinLocal), eEnt:LocalToWorld(iMaxLocal)

                table.insert(tNewPoints, {eEnt:GetPos(), eEnt:GetAngles(), iMin, iMax})
            end

            tSelectedPoints = tNewPoints
            
            LocalPlayer().MCD_bCreatingSpawnPoints = false
            
            frame:Remove()
            hook.Remove("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown")

            content:Show()

            net.Start("ModernCarDealer.Net.ClientSpawnPointEnd")
            net.SendToServer()
        elseif iKeyRaw == KEY_ENTER and IsFirstTimePredicted() then
            timer.Simple(0, function()
                local eEnt = MCD_FindClosest()

                table.insert(tSelectedPoints, eEnt)
            end)
        elseif iKeyRaw == KEY_BACKSPACE then
            local eEnt = MCD_FindClosest()

            table.RemoveByValue(tSelectedPoints, eEnt)
        end
    end)
end

function ModernCarDealer:MechanicPointCreator() -- PURPOSE: This is the trigger point creator for the mechanic.
    LocalPlayer().MCD_bCreatingSpawnPoints = true

    ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("reset_positions_notice"))

    local vFirstVector = ""
    local vSecondVector = nil

    local frame = vgui.Create("DPanel")
    frame:SetSize(iScrW, iScrH)
    frame:SetPos(0, 0)

    frame.Paint = function(self, w, h)

        surface.SetTextColor(cTextColor)
        surface.SetFont("ModernCarDealer.Font.Main")
        surface.SetTextPos(iScrW/2, 100)

        draw.SimpleText(ModernCarDealer:GetPhrase("mechanic_creation_tool"),"ModernCarDealer.Font.Main", iScrW/2, 50, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)

        local iTextW, iTextH = surface.GetTextSize(ModernCarDealer:GetPhrase("mechanic_creation_tool"))

        draw.RoundedBox(0, (iScrW/2)-(iTextW/2), 50 + (iTextH/2), iTextW, 3, cTextColor)

        -- Information

        if vFirstVector == "" then
            draw.SimpleText(ModernCarDealer:GetPhrase("first_point"), "ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 30, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        else
            draw.SimpleText(ModernCarDealer:GetPhrase("second_point"), "ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 30, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
        end

        draw.SimpleText(ModernCarDealer:GetPhrase("tab_exit"),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 75, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)

    end

    hook.Add("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown", function(_, iKeyRaw)
        if not IsFirstTimePredicted() then return end

        if iKeyRaw == MOUSE_LEFT then
            if vFirstVector == "" then
                vFirstVector = LocalPlayer():GetEyeTrace().HitPos

                hook.Add("PostDrawTranslucentRenderables", "ModernCarDealer.Hook.PostTranslucent", function()
                    local vSecondVector = vSecondVector or LocalPlayer():GetEyeTrace().HitPos
                    render.DrawLine(vFirstVector, Vector(vSecondVector.x, vFirstVector.y, vFirstVector.z), cAccentColor) 
                    render.DrawLine(vFirstVector, Vector(vFirstVector.x, vSecondVector.y, vFirstVector.z), cAccentColor)
                    render.DrawLine(vFirstVector, Vector(vFirstVector.x, vFirstVector.y, vSecondVector.z), cAccentColor)

                    render.DrawLine(vSecondVector, Vector(vSecondVector.x, vSecondVector.y, vFirstVector.z), cAccentColor)
                    render.DrawLine(vSecondVector, Vector(vFirstVector.x, vSecondVector.y, vSecondVector.z), cAccentColor)
                    render.DrawLine(vSecondVector, Vector(vSecondVector.x, vFirstVector.y, vSecondVector.z), cAccentColor)

                    render.DrawLine(Vector(vSecondVector.x, vSecondVector.y, vFirstVector.z), Vector(vSecondVector.x, vFirstVector.y, vFirstVector.z), cAccentColor)
                    render.DrawLine(Vector(vSecondVector.x, vSecondVector.y, vFirstVector.z), Vector(vFirstVector.x, vSecondVector.y, vFirstVector.z), cAccentColor)
                    
                    render.DrawLine(Vector(vFirstVector.x, vFirstVector.y, vSecondVector.z), Vector(vFirstVector.x, vSecondVector.y, vSecondVector.z), cAccentColor)
                    render.DrawLine(Vector(vFirstVector.x, vFirstVector.y, vSecondVector.z), Vector(vSecondVector.x, vFirstVector.y, vSecondVector.z), cAccentColor)
                    
                    render.DrawLine(Vector(vSecondVector.x, vFirstVector.y, vSecondVector.z), Vector(vSecondVector.x, vFirstVector.y, vFirstVector.z), cAccentColor) 
                    render.DrawLine(Vector(vFirstVector.x, vSecondVector.y, vFirstVector.z), Vector(vFirstVector.x, vSecondVector.y, vSecondVector.z), cAccentColor)
                end)   
            else
                vSecondVector = LocalPlayer():GetEyeTrace().HitPos

                hook.Remove("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown")
                frame:Remove()
                timer.Simple(2, function()
                    LocalPlayer().MCD_bCreatingSpawnPoints = false
                    hook.Remove("PostDrawTranslucentRenderables", "ModernCarDealer.Hook.PostTranslucent")
                
                    net.Start("ModernCarDealer.Net.ClientMechanicTriggerSet")
                    net.WriteVector(vFirstVector)
                    net.WriteVector(vSecondVector)
                    net.SendToServer()

                    local content = ModernCarDealer:AdminMenu()
                    timer.Simple(0.002, function() ModernCarDealer:ClearPanel(content) ModernCarDealer:AreaManager(content) end)
                end)
            end
        end
        if iKeyRaw == KEY_TAB then
            LocalPlayer().MCD_bCreatingSpawnPoints = false

            frame:Remove()
            hook.Remove("PlayerButtonDown", "ModernCarDealer.Hook.KeyDown")
            hook.Remove("PostDrawTranslucentRenderables", "ModernCarDealer.Hook.PostTranslucent")
        end
    end)
end

local bPlayerDataChecked = false 

function ModernCarDealer:OpenTransferUI()
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    local frame = ModernCarDealer.Frame(0, 0, iScrW/3, iScrH/3, ModernCarDealer:GetPhrase("transfer_data"))
    frame:Center()

    local playerData = ModernCarDealer.CheckBox(frame, 0, 0, 0, 0)
    playerData:SetPos(frame:GetWide() - 55, frame:GetTall() - 55)
    playerData:SetSize(50, 50)
    playerData:SetChecked(false)

    local transferLabel = vgui.Create("DLabel", frame)
    transferLabel:SetText(ModernCarDealer:GetPhrase("transfer_player_data")..":")
    transferLabel:SetTextColor(cWhiteOnWhiteColor)
    transferLabel:SetFont("ModernCarDealer.Font.Text")
    transferLabel:Dock(BOTTOM)
    transferLabel:SetTall(40)
    transferLabel:DockMargin(0, 0, 0, 5)

    local ACD = ModernCarDealer.Button(frame, "Advanced Car Dealer ➤ MCD", 0, 0, 0, 0)
    ACD:Dock(TOP)
    ACD:DockMargin(0, 10, 0, 0)
    ACD:SetTall(48)
    
    ACD.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        net.Start("ModernCarDealer.Net.Transfer")
        net.WriteUInt(0, 2)
        net.WriteBool(playerData:GetChecked())
        net.SendToServer()
    end

    local VCMOD = ModernCarDealer.Button(frame, "VCMOD ➤ MCD", 0, 0, 0, 0)
    VCMOD:Dock(TOP)
    VCMOD:DockMargin(0, 5, 0, 0)
    VCMOD:SetTall(48)
    
    VCMOD.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        bPlayerDataChecked = playerData:GetChecked()

        net.Start("ModernCarDealer.Net.RequestVCMODmaps")
        net.SendToServer()
    end

    local WCD = ModernCarDealer.Button(frame, "Williams Car Dealer ➤ MCD", 0, 0, 0, 0)
    WCD:Dock(TOP)
    WCD:DockMargin(0, 5, 0, 0)
    WCD:SetTall(48)
    
    WCD.DoClick = function()
        surface.PlaySound("moderncardealer/click.wav")

        net.Start("ModernCarDealer.Net.Transfer")
        net.WriteUInt(1, 2)
        net.WriteBool(playerData:GetChecked())
        net.SendToServer()
    end
end

net.Receive("ModernCarDealer.Net.SendVCMODmaps", function()
    local function TransferWithMap(sMap)
        net.Start("ModernCarDealer.Net.Transfer")
        net.WriteUInt(2, 2)
        net.WriteBool(bPlayerDataChecked)
        net.WriteString(sMap)
        net.SendToServer()
    end

    local iNum = net.ReadUInt(22)
    local tMaps = util.JSONToTable(util.Decompress(net.ReadData(iNum)))
    
    local menu = DermaMenu() 

    menu.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(cTextColor.r, cTextColor.g, cTextColor.b, 250))
    end

    for _, sMap in pairs(tMaps) do
        local option = menu:AddOption(sMap, function() TransferWithMap(sMap) end)
        option:SetTextColor(cMainColor)
    end

    menu:Open()
end)

concommand.Add("cardealer_transfer", function() ModernCarDealer:OpenTransferUI() end)
concommand.Add("cardealer_menu", function() ModernCarDealer:AdminMenu() end)

hook.Add("OnPlayerChat", "ModernCarDealer.Hook.TransferCommand", function(pPlayer, sText)
	if pPlayer == LocalPlayer() and string.lower(sText) == "!mcd_transfer" then
        RunConsoleCommand("cardealer_transfer")
    end
end)

function ModernCarDealer:ModifyShowcaseEntity(eShowcase)
    if not (ModernCarDealer.Config.AdminGroups[LocalPlayer():GetUserGroup()]) then return end

    surface.PlaySound("moderncardealer/notify.wav")

    local bModifying = eShowcase.bData

    local frame = ModernCarDealer.Frame(0, 0, iScrW/3, iScrH/1.5, "Create Showcase")
    frame:Center()

    local iID
    if bModifying then iID = eShowcase.iID frame:SetSize(iScrW/3, iScrH/3) frame:Center() end

    local contentFrame = vgui.Create("DPanel", frame)
    contentFrame:Dock(FILL)
    contentFrame:DockMargin(5, 20, 5, 10)

    contentFrame.Paint = function() end

    if bModifying then -- CASE: Data already exists
        local updateButton = ModernCarDealer.Button(contentFrame, ModernCarDealer:GetPhrase("update"), 0, 0, 0, 0)
        updateButton:Dock(TOP)
        updateButton:DockMargin(50, 20, 50, 0)
        updateButton:SetTall(40)

        updateButton.DoClick = function()
            local tInformationToSubmit = {}

            tInformationToSubmit[iID] = {
                ["Color"] = eShowcase:GetColor(),
                ["Class"] = eShowcase.sClass,
                ["Model"] = eShowcase:GetModel(),
                ["Name"] = ModernCarDealer.GamemodeVehicles[eShowcase.sClass].Name,
                ["Price"] = eShowcase.iPrice,
                ["Position"] = eShowcase:GetPos(),
                ["Angles"] = eShowcase:GetAngles() 
            }

            local tTableToSend = util.Compress(util.TableToJSON(tInformationToSubmit))

            net.Start("ModernCarDealer.Net.ClientCreateEntity")
            net.WriteUInt(2, 2)
            net.WriteUInt(#tTableToSend, 22)
            net.WriteData(tTableToSend, #tTableToSend)
            net.SendToServer()

            frame:Remove()
        end
        
        local deleteButton = ModernCarDealer.Button(contentFrame, ModernCarDealer:GetPhrase("remove"), 0, 0, 0, 0)
        deleteButton:Dock(TOP)
        deleteButton:DockMargin(50, 20, 50, 0)
        deleteButton:SetTall(40)

        deleteButton.DoClick = function()
            net.Start("ModernCarDealer.Net.ClientDeleteEntity")
            net.WriteUInt(eShowcase:GetNWInt("MCD_Index"), 32)
            net.SendToServer()

            frame:Remove()
        end

        local vOriginalPos = eShowcase:GetPos()

        local offsetSlider = vgui.Create("DNumSlider", contentFrame)
        offsetSlider:Dock(TOP)
        offsetSlider:SetSize(300, 100)
        offsetSlider:SetText("Height Offset")
        offsetSlider:SetMin(-1)
        offsetSlider:SetMax(1)
        offsetSlider:SetDecimals(3)
        offsetSlider:SetValue(0)

        offsetSlider.OnValueChanged = function(self, iOffset)
            eShowcase:SetPos(Vector(vOriginalPos.x, vOriginalPos.y, vOriginalPos.z + (iOffset*15)))
        end
        return
    end

    local chooseDealer = vgui.Create("DLabel", contentFrame) -- CASE: Spawned through the Q Menu
    chooseDealer:Dock(TOP)
    chooseDealer:SetTall(30)
    chooseDealer:SetFont("ModernCarDealer.Font.BoldText")
    chooseDealer:SetText(ModernCarDealer:GetPhrase("dealer_name")..":")
    chooseDealer:SetTextColor(cWhiteOnWhiteColor)

    local tDealerNames = {}
    for sDealerName, iDealerInfo in pairs(ModernCarDealer.Cars) do
        table.insert(tDealerNames, sDealerName)
    end

    local carDealers = ModernCarDealer.ComboBox(contentFrame, 0, 0, 0, 0, "defaultValue", tDealerNames)
    carDealers:Dock(TOP)
    carDealers:DockMargin(0, 10, 0, 20)
    carDealers:SetTall(40)
    carDealers:SetValue("")

    carDealers.OnSelect = function()
        if IsValid(contentFrame.NextButton) then contentFrame.NextButton:Remove() end


        local nextButton = ModernCarDealer.Button(contentFrame, "Continue", 0, 0, 0, 0)
        nextButton:Dock(TOP)
        nextButton:DockMargin(50, 20, 50, 0)
        nextButton:SetTall(40)

        contentFrame.NextButton = nextButton

        nextButton.DoClick = function()
            local sDealer = carDealers:GetSelected()

            chooseDealer:SetText(ModernCarDealer:GetPhrase("vehicles"))
            carDealers:Clear()

            for _, tCar in pairs(ModernCarDealer.Cars[sDealer]) do
                if not tCar.SimfPhys then
                    carDealers:AddChoice(tCar.Name, tCar)
                end
            end

            carDealers.OnSelect = function() -- After a dealer is selected
                local nextButton = ModernCarDealer.Button(contentFrame, "Continue", 0, 0, 0, 0)
                nextButton:Dock(TOP)
                nextButton:DockMargin(50, 20, 50, 0)
                nextButton:SetTall(40)
                if IsValid(contentFrame.NextButton) then contentFrame.NextButton:Remove() end

                contentFrame.NextButton = nextButton

                nextButton.DoClick = function() -- After a vehicle is selected
                    local _, tCar = carDealers:GetSelected()

                    carDealers:Remove()
                    chooseDealer:SetText(tCar.Name)
                    nextButton:Remove()

                    local mainGrid = vgui.Create("DPanel", contentFrame)
                    mainGrid:Dock(FILL)
                    mainGrid:DockMargin(0, 10, 0, 0)
                    mainGrid.Paint = function() end

                    local tCarPanelModel = vgui.Create("DModelPanel", mainGrid)
                    tCarPanelModel:Dock(FILL)
                    tCarPanelModel:SetTall(mainGrid:GetTall())
                    tCarPanelModel:SetModel(ModernCarDealer.GamemodeVehicles[tCar.Class].Model)

                    local mn, mx = tCarPanelModel.Entity:GetRenderBounds()

                    tCarPanelModel:SetCamPos(Vector(-140, mx.y*2, mx.z*0.75))
                    tCarPanelModel:SetFOV(75)
                    tCarPanelModel:SetDirectionalLight(BOX_TOP, Color(200, 200, 200))
                    tCarPanelModel:SetDirectionalLight(BOX_FRONT, Color(40, 40, 40))
                
                    function tCarPanelModel:LayoutEntity(Entity) return end

                    local tCarPanelOverlay = vgui.Create("DPanel", mainGrid)
                    tCarPanelOverlay:Dock(FILL)
                    tCarPanelOverlay.Paint = function() end

                    
                    local createButton = ModernCarDealer.Button(contentFrame, ModernCarDealer:GetPhrase("create"), 0, 0, 0, 0)
                    createButton:Dock(BOTTOM)
                    createButton:DockMargin(50, 20, 50, 0)
                    createButton:SetTall(40)

                    local carColor = vgui.Create("DColorMixer", contentFrame)
                    carColor:Dock(BOTTOM)
                    carColor:DockMargin(0, 10, 0, 0)
                    carColor:SetAlphaBar(false)
                    carColor:SetColor(tCarPanelModel:GetColor())
                    
                    carColor.ValueChanged = function(self, cColor)
                        tCarPanelModel:SetColor(cColor)
                    end

                    createButton.DoClick = function()
                        local tInformationToSubmit = {}

                        tInformationToSubmit[math.random(1, 999999)] = {
                            ["Color"] = tCarPanelModel:GetColor(),
                            ["Class"] = tCar.Class,
                            ["Model"] = ModernCarDealer.GamemodeVehicles[tCar.Class].Model,
                            ["Name"] = tCar.Name,
                            ["Price"] = tCar.Price,
                            ["Position"] = eShowcase:GetPos(),
                            ["Angles"] = eShowcase:GetAngles()
                        }

                        local tTableToSend = util.Compress(util.TableToJSON(tInformationToSubmit))

                        net.Start("ModernCarDealer.Net.ClientCreateEntity")
                        net.WriteUInt(2, 2)
                        net.WriteUInt(#tTableToSend, 22)
                        net.WriteData(tTableToSend, #tTableToSend)
                        net.WriteEntity(eShowcase)
                        net.SendToServer()

                        frame:Remove()
                        ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("touch_tip_notice"))
                    end
                end
            end

            nextButton:Remove()
        end
    end
end