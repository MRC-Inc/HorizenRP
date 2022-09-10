ENT.Type = "anim"
ENT.Base = "itemstore_box"

ENT.PrintName = "Huge Box"
ENT.Category = "ItemStore"

ENT.Spawnable = true
ENT.AdminOnly = true

if SERVER then
	AddCSLuaFile()

	ENT.Model = "models/props_junk/wood_crate001a_damaged.mdl"

	ENT.ContainerWidth = 8
	ENT.ContainerHeight = 4
	ENT.ContainerPages = 2
end
