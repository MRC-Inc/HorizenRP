--[[

MCD DERMA
Credits as parts of the base was done by matlib and their developers. Check it out: https://github.com/LivacoNew/MatLib

]]--

local cMainColor = ModernCarDealer.Config.PrimaryColor
local cSecondaryColor = ModernCarDealer.Config.SecondaryColor
local cAccentColor = ModernCarDealer.Config.AccentColor
local cTextColor = ModernCarDealer.Config.TextColor

local iScrW, iScrH = ScrW(), ScrH()

local iHeaderHeight = 30

local mGradientDown = Material("gui/gradient_down")
local mGradientUp = Material("gui/gradient_up")

function ModernCarDealer.Frame(x, y, w, h, sTitle, bNotice) 
    local frame = vgui.Create("DFrame")
    frame:SetSize(w, h)
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:MakePopup()

    frame.iHeaderHeight = iHeaderHeight
    local iStartTime = SysTime()

    if x == -1 and y == -1 then
        frame:Center()
    else
        frame:SetPos(x, y)
    end
    
    frame.Paint = function(self, w, h)
        if bNotice then
            Derma_DrawBackgroundBlur(frame, iStartTime)
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

        draw.SimpleText(sTitle, "ModernCarDealer.Font.MediumText", 10, self.iHeaderHeight / 2, cTextColor, 0, 1)
    end

    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetPos(frame:GetWide() - frame.iHeaderHeight*2 + 10, 3)
    closeButton:SetSize(frame.iHeaderHeight*2, frame.iHeaderHeight + 6)
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

    return frame
end

function ModernCarDealer.Button(frame, text, x, y, w, h, cColor)
    local button = vgui.Create("DButton", frame)
    button:SetPos(x, y)
    button:SetSize(w, h)
    button:SetText("")
    button.Lerp = 0

    button.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, cColor or cSecondaryColor)
   
        if self:IsHovered() then
            self.Lerp = Lerp(0.2, self.Lerp, 25)
        else
            self.Lerp = Lerp(0.1, self.Lerp, 0)
        end
        
        draw.RoundedBox(6, 0, 0, w, h, Color(79, 79, 79, self.Lerp))

        draw.SimpleText(text, "ModernCarDealer.Font.MediumText", w / 2, h / 2, cTextColor, 1, 1)
    end

    button.OnCursorEntered = function()
        surface.PlaySound("moderncardealer/rollover.wav")
    end

    return button
end

function ModernCarDealer.CheckBox(frame, x, y, w, h, defaultValue)
    local box = vgui.Create("DCheckBox", frame)
    box:SetPos(x, y)
    box:SetSize(w, h)
    box:SetChecked(defaultValue)
    box.Lerp = 0

    box.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, cSecondaryColor)

        if self:GetChecked() then
            box.Lerp = Lerp(0.2, box.Lerp, 255)
        else
            box.Lerp = Lerp(0.2, box.Lerp, 0)
        end

        draw.SimpleText("✓", "ModernCarDealer.Font.MediumText", w / 2, h / 2, Color(255, 255, 255, box.Lerp), 1, 1)
    end
    return box
end

function ModernCarDealer.ComboBox(frame, x, y, w, h, defaultValue, fields)
    local box = vgui.Create("DComboBox", frame)

    box:SetPos(x, y)
    box:SetSize(w, h)
    box:SetTextColor(color_black)
    box:SetSortItems(false)
    box:SetFont("ModernCarDealer.Font.Text")

    for _, sName in pairs(fields) do
        local option = box:AddChoice(sName)
    end

    box:SetValue(defaultValue)

    box.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, Color(cTextColor.r, cTextColor.g, cTextColor.b, 250))
    end

    return box
end

function ModernCarDealer.TextEntry(frame, defaultValue, button)
    local cEntryColor = Color(cTextColor.r, cTextColor.g, cTextColor.b, 250)

    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:SetValue(defaultValue)
    textEntry:SetFont("ModernCarDealer.Font.Text")
    textEntry:SetCursorColor(color_black)
    textEntry:SetDrawBackground(false)
    textEntry.OldPaint = textEntry.Paint

    textEntry.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, cEntryColor)
        self:OldPaint(w, h)
    end

    textEntry.OnKeyCode = function(self, iKey)
        if button and iKey == KEY_ENTER then
            button:DoClick()
        end
    end

    return textEntry
end

function ModernCarDealer.Scroll(frame, x, y, w, h)
    local scroll = vgui.Create("DScrollPanel", frame)
    
    scroll:SetPos(x, y)
    scroll:SetSize(w, h)

    scroll.Paint = function() end

    local sBar = scroll:GetVBar()
    local iSize = 8
    local cScrollColor = cSecondaryColor

    function sBar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_transparent)
    end

    function sBar.btnUp:Paint(w, h)
        draw.RoundedBox(5, (w - iSize)/2, 0, iSize, iSize, cScrollColor)
    end

    function sBar.btnDown:Paint(w, h)
        draw.RoundedBox(5, (w - iSize)/2, 0, iSize, iSize, cScrollColor)
    end

    function sBar.btnGrip:Paint(w, h)
        draw.RoundedBox(5, (w - iSize)/2, 0, iSize, h, cScrollColor)
    end

    return scroll
end

function ModernCarDealer.HeaderText(frame, x, y, text)
    local label = vgui.Create("DLabel", frame)
    label:SetPos(x, y)
    label:SetText(text)
    label:SetFont("ModernCarDealer.Font.Small")
    label:SetContentAlignment(7)
    label:SizeToContents()
    label:SetColor(cTextColor)
    return label
end

function ModernCarDealer.Notice(title, text)
    surface.PlaySound("moderncardealer/notify.wav")

    local frame = ModernCarDealer.Frame(-1, -1, ScrW() * 0.3, ScrH() * 0.075, title, true)
    frame:Center()
    frame:CenterVertical(0.4)

    ModernCarDealer.HeaderText(frame, 10, iHeaderHeight + 8, text)
end

function ModernCarDealer.Query(text, title, button1text, button1func, button2text, button2func)
    
    local frame = ModernCarDealer.Frame(-1, -1, ScrW() * 0.3, ScrH() * 0.125, title, true)
    frame:Center()
    frame:CenterVertical(0.4)

    ModernCarDealer.HeaderText(frame, 10, iHeaderHeight + 8, text)

    local iInBetween = (frame:GetWide() - ((iScrW/10) * 2))/3

    local buttonFrame = vgui.Create("DPanel", frame)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iHeaderHeight)
    buttonFrame.Paint = function() end


    local button1 = ModernCarDealer.Button(buttonFrame, button1text, 0, 0, 0, 0)
    button1:SetSize(iScrW/10, buttonFrame:GetTall())
    button1:SetPos(iInBetween, 0)
    button1.DoClick = function()
        frame:Remove()
        
        if not button1func then return end
        button1func()
    end

    local button2 = ModernCarDealer.Button(buttonFrame, button2text, 0, 0, 0, 0)
    button2:SetSize(iScrW/10, buttonFrame:GetTall())
    button2:SetPos(iScrW/10 + iInBetween*2, 0)
    button2.DoClick = function()
        frame:Remove()

        if not button2func then return end
        button2func()
    end
end

function ModernCarDealer.StringRequest(title, text, defaulttext, func)
    local frame = ModernCarDealer.Frame(-1, -1, ScrW() * 0.3, ScrH() * 0.175, title, true)
    frame:Center()
    frame:CenterVertical(0.4)

    local iRoundMargins = 5

    ModernCarDealer.HeaderText(frame, 10, iHeaderHeight + 8, text)

    local buttonFrame = vgui.Create("DPanel", frame)
    buttonFrame:Dock(BOTTOM)
    buttonFrame:SetTall(iHeaderHeight)
    buttonFrame.Paint = function() end

    local textEntry

    local button1 = ModernCarDealer.Button(buttonFrame, "Submit", 0, 0, 0, 0)
    button1:SetSize(iScrW/10, buttonFrame:GetTall())
    button1:SetPos(frame:GetWide()/2 - button1:GetWide()/2, 0)
    button1.DoClick = function()
        frame:Remove()
        
        if not func then return end
        func(textEntry:GetValue())
    end

    textEntry = ModernCarDealer.TextEntry(frame, defaulttext, button1)
    textEntry:SetPos(iRoundMargins, iRoundMargins + iHeaderHeight + ScrH() * 0.04)
    textEntry:SetSize(frame:GetWide() - (iRoundMargins*2), 40 - (iRoundMargins*2))
end