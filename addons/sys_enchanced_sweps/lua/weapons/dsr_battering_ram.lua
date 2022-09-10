AddCSLuaFile()

if( CLIENT ) then
    SWEP.PrintName = "Таранить"
    SWEP.Slot = 5
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

-- Variables that are used on both client and server

SWEP.Author = "Brickwall"
SWEP.Instructions = "Left click to ram a door."
SWEP.Contact = ""
SWEP.Purpose = "Knock down doors!"

SWEP.ViewModel = Model( "models/sterling/c_enhanced_batteringram.mdl" )
SWEP.WorldModel = ( "models/sterling/w_enhanced_batteringram.mdl" )
SWEP.ViewModelFOV = 85
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "DarkRP SWEP Replacements"

SWEP.Primary.ClipSize = -1      -- Size of a clip
SWEP.Primary.DefaultClip = 0        -- Default number of bullets in a clip
SWEP.Primary.Automatic = false      -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1        -- Size of a clip
SWEP.Secondary.DefaultClip = -1     -- Default number of bullets in a clip
SWEP.Secondary.Automatic = false        -- Automatic/Semi Auto
SWEP.Secondary.Ammo = ""

SWEP.Sound = Sound("physics/wood/wood_box_impact_hard3.wav")

--[[-------------------------------------------------------
Name: SWEP:Initialize()
Desc: Called when the weapon is first loaded
---------------------------------------------------------]]
function SWEP:Initialize()
    self:SetHoldType("crossbow")
end

function SWEP:SetupDataTables()
    self:NetworkVar( "Int", 0, "BarPercent" )
end

--[[-------------------------------------------------------
Name: SWEP:PrimaryAttack()
Desc: +attack1 has been pressed
---------------------------------------------------------]]

-- Check whether an object of this player can be rammed
local function canRam(ply)
    return IsValid(ply) and (ply.warranted == true or ply:isWanted() or ply:isArrested())
end

-- Ram action when ramming a door
local GoingUp = true
local Freeze = false
local function ramDoor(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 3000 or (not GAMEMODE.Config.canforcedooropen and ent:getKeysNonOwnable()) then return false end

    local allowed = false

    -- if we need a warrant to get in
    if GAMEMODE.Config.doorwarrants and ent:isKeysOwned() and not ent:isKeysOwnedBy(ply) then
        -- if anyone who owns this door has a warrant for their arrest
        -- allow the police to smash the door in
        for _, v in ipairs(player.GetAll()) do
            if ent:isKeysOwnedBy(v) and canRam(v) then
                allowed = true
                break
            end
        end
    else
        -- door warrants not needed, allow warrantless entry
        allowed = true
    end

    -- Be able to open the door if any member of the door group is warranted
    local keysDoorGroup = ent:getKeysDoorGroup()
    if GAMEMODE.Config.doorwarrants and keysDoorGroup then
        local teamDoors = RPExtraTeamDoors[keysDoorGroup]
        if teamDoors then
            allowed = false
            for _, v in ipairs(player.GetAll()) do
                if table.HasValue(teamDoors, v:Team()) and canRam(v) then
                    allowed = true
                    break
                end
            end
        end
    end

    if CLIENT then return allowed end

    -- Do we have a warrant for this player?
    if not allowed then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))

        return false
    end

    Freeze = true

    timer.Simple( 0.4, function() 
        if( not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then return end 
        ply:EmitSound( wep.Sound )

        if( not BES.CONFIG.DoorRam.InstantOpen and (not ent:GetNWInt( "BES_DoorHP", false ) or ent:GetNWInt( "BES_DoorHP", 0 ) > 0) ) then
            if( not ent:GetNWInt( "BES_DoorHP", false ) ) then
                ent:SetNWInt( "BES_DoorHP", BES.CONFIG.DoorRam.DoorHealth )
            end

            local percent = 0
            if( wep:GetBarPercent() <= 50 ) then
                percent = wep:GetBarPercent()/50
            else
                percent = (50-(wep:GetBarPercent()-50))/50
            end

            local Damage = BES.CONFIG.DoorRam.DamagePerHit*percent
            ent:SetNWInt( "BES_DoorHP", math.max( ent:GetNWInt( "BES_DoorHP", 0 )-Damage, 0 ) )
        end

        if( BES.CONFIG.DoorRam.InstantOpen or ent:GetNWInt( "BES_DoorHP", 0 ) <= 0 or (BES.CONFIG.DoorRam.InstantAdmin and (ply:IsAdmin() or ply:IsSuperAdmin())) ) then
            ent:keysUnLock()
            ent:Fire( "open", "", 0 )
            ent:Fire( "setanimation", "open", 0 )

            if( not BES.CONFIG.DoorRam.InstantOpen ) then
                timer.Create( "BES_DoorTimer_" .. ent:EntIndex(), BES.CONFIG.DoorRam.DoorRegenTime, 1, function()
                    if( IsValid( ent ) ) then
                        ent:SetNWInt( "BES_DoorHP", BES.CONFIG.DoorRam.DoorHealth )
                    end
                end )
            end
        end
    end )

    return true
end

-- Ram action when ramming a vehicle
local function ramVehicle(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    if CLIENT then return false end -- Ideally this would return true after ent:GetDriver() check

    timer.Simple( 0.4, function() 
        if( not IsValid( ent ) or not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then return end 

        ent:keysLock()

        ply:EmitSound( wep.Sound )
        
        local driver = ent:GetDriver()
        if not IsValid(driver) or not driver.ExitVehicle then return false end
    
        driver:ExitVehicle()
    end )

    return true
end

-- Ram action when ramming a fading door
local function ramFadingDoor(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end

    local Owner = ent:CPPIGetOwner()

    if CLIENT then return canRam(Owner) end

    if not canRam(Owner) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("warrant_required"))
        return false
    end

    timer.Simple( 0.4, function() 
        if( not IsValid( ent ) or not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then return end 
        ply:EmitSound( wep.Sound )

        if not ent.fadeActive then
            ent:fadeActivate()
            timer.Simple(5, function() if IsValid(ent) and ent.fadeActive then ent:fadeDeactivate() end end)
        end
    end )

    return true
end

-- Ram action when ramming a frozen prop
local function ramProp(ply, trace, ent, wep)
    if ply:EyePos():DistToSqr(trace.HitPos) > 10000 then return false end
    if ent:GetClass() ~= "prop_physics" then return false end

    local Owner = ent:CPPIGetOwner()

    if CLIENT then return canRam(Owner) end

    if not canRam(Owner) then
        DarkRP.notify(ply, 1, 5, DarkRP.getPhrase(GAMEMODE.Config.copscanunweld and "warrant_required_unweld" or "warrant_required_unfreeze"))
        return false
    end

    timer.Simple( 0.4, function() 
        if( not IsValid( ent ) or not IsValid( ply ) or ply:GetActiveWeapon() != wep ) then return end 
        ply:EmitSound( wep.Sound )

        if GAMEMODE.Config.copscanunweld then
            constraint.RemoveConstraints(ent, "Weld")
        end
    
        if GAMEMODE.Config.copscanunfreeze then
            ent:GetPhysicsObject():EnableMotion(true)
        end
    end )

    return true
end

-- Decides the behaviour of the ram function for the given entity
local function getRamFunction(ply, trace, wep)
    local ent = trace.Entity

    if not IsValid(ent) then return fp{fn.Id, false} end

    local override = hook.Call("canDoorRam", nil, ply, trace, ent)

    return
        override ~= nil     and fp{fn.Id, override}                                 or
        ent:isDoor()        and fp{ramDoor, ply, trace, ent, wep}                        or
        ent:IsVehicle()     and fp{ramVehicle, ply, trace, ent, wep}                     or
        ent.fadeActivate    and fp{ramFadingDoor, ply, trace, ent, wep}                  or
        ent:GetPhysicsObject():IsValid() and not ent:GetPhysicsObject():IsMoveable()
                                         and fp{ramProp, ply, trace, ent, wep}           or
        fp{fn.Id, false} -- no ramming was performed
end

function SWEP:PrimaryAttack()
    self:GetOwner():LagCompensation(true)
    local trace = self:GetOwner():GetEyeTrace()
    self:GetOwner():LagCompensation(false)

    local hasRammed = getRamFunction(self:GetOwner(), trace, self)()

    if SERVER then
        hook.Call("onDoorRamUsed", GAMEMODE, hasRammed, self:GetOwner(), trace)
    end

    if not hasRammed then return end

    self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )
    timer.Simple( 1, function() if( not IsValid( self.Owner ) or self.Owner:GetActiveWeapon() != self ) then return end self.Weapon:SendWeaponAnim( ACT_VM_IDLE ) Freeze = false self:SetBarPercent( 0 ) end )
    self:SetNextPrimaryFire( CurTime() + 1.1 )
end

function SWEP:SecondaryAttack()

end

function SWEP:Think()
    if( BES.CONFIG.DoorRam.InstantOpen or not IsValid( self.Owner ) ) then return end
    if CLIENT then return end
    if Freeze then return end

    local TraceEnt = self.Owner:GetEyeTrace().Entity
    local eyepos = self.Owner:EyePos()
    if( IsValid( TraceEnt ) and TraceEnt:isDoor() and eyepos:DistToSqr( self.Owner:GetEyeTrace().HitPos ) < 3000 and not TraceEnt:getKeysNonOwnable() and TraceEnt:isKeysOwned() ) then
        if( self:GetBarPercent() < 100 and GoingUp ) then
            self:SetBarPercent( self:GetBarPercent()+2 )
            if( self:GetBarPercent() >= 100 ) then
                GoingUp = false
            end
        elseif( not GoingUp ) then
            self:SetBarPercent( self:GetBarPercent()-2 )
            if( self:GetBarPercent() <= 0 ) then
                GoingUp = true
            end
        end
    elseif( self:GetBarPercent() > 0 ) then
        GoingUp = true
        self:SetBarPercent( 0 )
    end
end

function SWEP:Holster()
	return true
end

if( CLIENT ) then
    local w = ScrW()
    local h = ScrH()
    local x, y, width, height = w / 2 - w / 10, (h / 4)*3 - (h / 15 + 20)/2, w / 5, h / 15
    local hHeight = 20
    local sizet = 9
    function SWEP:DrawHUD()
        if( BES.CONFIG.DoorRam.InstantAdmin and (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()) ) then return end

        if( BES.CONFIG.DoorRam.InstantOpen or not IsValid( self.Owner ) ) then return end
        local TraceEnt = self.Owner:GetEyeTrace().Entity
        local eyepos = self.Owner:EyePos()
        if( not IsValid( TraceEnt ) or not TraceEnt:isDoor() or eyepos:DistToSqr( self.Owner:GetEyeTrace().HitPos ) > 4000 or TraceEnt:getKeysNonOwnable() or not TraceEnt:isKeysOwned() ) then return end
        local status = self:GetBarPercent()/100

        surface.SetDrawColor( BES.CONFIG.Themes.Secondary )
        surface.DrawRect( x, y, width, height+hHeight )
        
        local BarWidth = status * (width - sizet)

        surface.SetDrawColor( BES.CONFIG.Themes.Tertiary )
        surface.DrawRect( x + sizet/2, y + sizet/2, width-sizet, height - sizet )
        
        draw.GradientBox( x + sizet/2, y + sizet/2, (width - sizet)/2, height - sizet, 0, HSVToColor( 0, 1, 1 ), HSVToColor( 90, 1, 1 ) )
        draw.GradientBox( x + sizet/2 + (width - sizet)/2 -1, y + sizet/2, (width - sizet)/2, height - sizet, 0, HSVToColor( 90, 1, 1 ), HSVToColor( 0, 1, 1 ) )

        surface.SetDrawColor( 50, 50, 50, 100 )
        surface.DrawRect( x + sizet/2, y + sizet/2, (width - sizet), height - sizet )

        surface.SetDrawColor( BES.CONFIG.Themes.Primary )
        surface.DrawRect( (x + sizet/2)+(BarWidth), y + sizet/2, 3, height - sizet )
        
        status = TraceEnt:GetNWInt( "BES_DoorHP", BES.CONFIG.DoorRam.DoorHealth )/BES.CONFIG.DoorRam.DoorHealth

        surface.SetDrawColor( BES.CONFIG.Themes.Tertiary )
        surface.DrawRect( x + sizet/2, y + height, width-sizet, hHeight - sizet/2 )
        surface.SetDrawColor( BES.CONFIG.Themes.Red )
        surface.DrawRect( x + sizet/2, y + height, (width-sizet)*status, hHeight - sizet/2 )
    end
end