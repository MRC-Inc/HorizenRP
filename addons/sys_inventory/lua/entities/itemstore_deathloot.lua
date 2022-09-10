ENT.Type = "anim"
ENT.Base = "itemstore_box"

ENT.PrintName = "Death Loot"
ENT.Category = "ItemStore"

ENT.Spawnable = false
ENT.AdminOnly = false

if SERVER then
	AddCSLuaFile()

	ENT.Model = "models/props_junk/garbage_bag001a.mdl"

	ENT.ContainerWidth = 5
	ENT.ContainerHeight = 5
	ENT.ContainerPages = 2

	ENT.Timeout = 0

	function ENT:Think()
		if self.Timeout < CurTime() then self:Remove() end
	end
end
