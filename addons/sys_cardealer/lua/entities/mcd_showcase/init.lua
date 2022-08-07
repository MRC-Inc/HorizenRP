AddCSLuaFile("cl_init.lua") AddCSLuaFile("shared.lua") include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate2x4.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMaterial("phoenix_storms/gear")
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
end

function ENT:SpawnFunction(pPlayer, tTr, sClass)
	if (!tTr.Hit) then return end

	local vSpawnPos = tTr.HitPos + tTr.HitNormal * 50
	local aSpawnAng = pPlayer:EyeAngles()
	aSpawnAng.p = 0
	aSpawnAng.y = aSpawnAng.y + 90

	local eEnt = ents.Create(sClass)
	if not IsValid(eEnt) then return end
	eEnt:SetPos(vSpawnPos)
	eEnt:SetAngles(aSpawnAng)
	eEnt:Spawn()
	eEnt:Activate()
	return eEnt
end

function ENT:Use(pPlayer)
	if not (ModernCarDealer.Config.AdminGroups[pPlayer:GetUserGroup()]) or self.tDealerData then return end
	
	ModernCarDealer:ChatMessage(ModernCarDealer:GetPhrase("nodata_notice"), pPlayer)
end