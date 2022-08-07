AddCSLuaFile()

SWEP.Category 		= "Modern Car Dealer"
SWEP.PrintName		= "Setup Tool"
SWEP.Author			= "painless"
SWEP.Instructions   = "Left click to use the tool."
SWEP.Spawnable              = true
SWEP.AdminOnly              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Weight			        = 5
SWEP.AutoSwitchTo		    = false
SWEP.AutoSwitchFrom		    = false

SWEP.Slot			        = 2
SWEP.SlotPos			    = 1
SWEP.DrawAmmo			    = false
SWEP.DrawCrosshair		    = true

SWEP.ViewModel		= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel		= "models/weapons/w_toolgun.mdl"
SWEP.UseHands = true

local iTextSize = 256
local iLogoSize = 200
local cMainColor = ModernCarDealer.Config.PrimaryColor
local cSecondaryColor = ModernCarDealer.Config.SecondaryColor
local cTextColor = ModernCarDealer.Config.TextColor

function SWEP:Initialize()
    self:SetHoldType("revolver")
    self.iCoolDown = false

    if CLIENT then
        local mRT = GetRenderTarget("GModToolgunScreen", iTextSize, iTextSize)
        local matScreen = Material("models/weapons/v_toolgun/screen")
        matScreen:SetTexture("$basetexture", mRT)
    
        local mLogo = Material("moderncardealer/logo.png", "$ignorez")
    
        function self:RenderScreen()
            render.PushRenderTarget(mRT)
            cam.Start2D()
                surface.SetDrawColor(cMainColor)
                surface.DrawRect(0, 0, iTextSize, iTextSize)
    
                surface.SetDrawColor(cSecondaryColor)
                surface.SetMaterial(mLogo)
                surface.DrawTexturedRect((iTextSize-iLogoSize)/2 - 10, (iTextSize-iLogoSize)/2, iLogoSize, iLogoSize)
            cam.End2D()
            render.PopRenderTarget()
        end
    end
end

if CLIENT then
    local iScrW, iScrH = ScrW(), ScrH()

    function SWEP:DrawHUD()
        if not (LocalPlayer().MCD_bCreatingSpawnPoints) then
            -- Header

            surface.SetTextColor(cTextColor)
            surface.SetFont("ModernCarDealer.Font.Main")
            surface.SetTextPos(iScrW/2, 100)

            draw.SimpleText(ModernCarDealer:GetPhrase("creation_tool"),"ModernCarDealer.Font.Main", iScrW/2, 50, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)

            local iTextW, iTextH = surface.GetTextSize(ModernCarDealer:GetPhrase("creation_tool"))

            draw.RoundedBox(0, (iScrW/2)-(iTextW/2), 50 + (iTextH/2), iTextW, 3, cTextColor)

            -- Information

            draw.SimpleText(ModernCarDealer:GetPhrase("left_click_modify"),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 30, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)
            draw.SimpleText(ModernCarDealer:GetPhrase("reload_admin_menu"),"ModernCarDealer.Font.Text", iScrW/2, 50 + (iTextH/2) + 75, cTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2)

            local eTraceEntityClass = "" 
            if IsValid(LocalPlayer():GetEyeTrace().Entity) then
                eTraceEntityClass = LocalPlayer():GetEyeTrace().Entity:GetClass()
            end
            if eTraceEntityClass == "mcd_cardealer" or eTraceEntityClass == "mcd_showcase" then
                draw.SimpleText(ModernCarDealer:GetPhrase("left_click_modify"), "ModernCarDealer.Font.Text", iScrW/2, iScrH/2, cTextColor, TEXT_ALIGN_CENTER)
            end
        end
    end
end

function SWEP:PrimaryAttack()
    if not self.iCoolDown then
        self.iCoolDown = true
        
        if CLIENT and not LocalPlayer().MCD_bCreatingSpawnPoints then
            local eTraceEntity = LocalPlayer():GetEyeTrace().Entity

            if eTraceEntity:GetClass() == "mcd_cardealer" then
                ModernCarDealer:ModifyCarDealerEntity(eTraceEntity)
            elseif eTraceEntity:GetClass() == "mcd_showcase" then
                ModernCarDealer:ModifyShowcaseEntity(eTraceEntity)
            end
        end
        timer.Simple(1, function() if IsValid(self) then self.iCoolDown = false end end)
    end
end

function SWEP:Reload()
    if not self.iCoolDown then
        self.iCoolDown = true
       
        if CLIENT and not LocalPlayer().MCD_bCreatingSpawnPoints then
            ModernCarDealer:AdminMenu()
        end
        
        timer.Simple(1, function() if IsValid(self) then self.iCoolDown = false end end)
    end
end