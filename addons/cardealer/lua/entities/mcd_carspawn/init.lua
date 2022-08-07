AddCSLuaFile("cl_init.lua") AddCSLuaFile("shared.lua") include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube2x4x025.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("models/debug/debugwhite")
	self:SetColor(ModernCarDealer.Config.AccentColor)
	self:PhysWake()
end

function ENT:SpawnFunction(pPlayer, tTr, sClassname)
	if (!tTr.Hit) then return end

	local vSpawnPos = tTr.HitPos + tTr.HitNormal * 50
	local aSpawnAng = pPlayer:EyeAngles()
	aSpawnAng.p = 0
	aSpawnAng.y = aSpawnAng.y + 270

	local eEnt = ents.Create(sClassname)
	if not IsValid(eEnt) then return end
	eEnt:SetPos(vSpawnPos)
	eEnt:SetAngles(aSpawnAng)
	eEnt:Spawn()
	eEnt:Activate()

	return eEnt
end