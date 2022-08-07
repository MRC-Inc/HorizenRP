include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	local iMinLocal, iMaxLocal = self:GetRenderBounds()
	
	render.DrawWireframeBox(self:GetPos(), self:GetAngles(), iMinLocal, iMaxLocal, color_white)
	render.DrawLine(self:LocalToWorld(Vector(iMaxLocal.x-iMinLocal.x*-1, iMinLocal.y+20, iMaxLocal.z)), self:LocalToWorld(Vector(iMaxLocal.x-iMinLocal.x*-1, iMaxLocal.y-100, iMaxLocal.z)), color_white)
	render.DrawLine(self:LocalToWorld(Vector(iMaxLocal.x-iMinLocal.x*-1, iMinLocal.y+20, iMaxLocal.z)), self:LocalToWorld(Vector(iMaxLocal.x-iMinLocal.x*-1+20, iMaxLocal.y-150, iMaxLocal.z)), color_white)
	render.DrawLine(self:LocalToWorld(Vector(iMaxLocal.x-iMinLocal.x*-1, iMinLocal.y+20, iMaxLocal.z)), self:LocalToWorld(Vector(iMaxLocal.x-iMinLocal.x*-1-20, iMaxLocal.y-150, iMaxLocal.z)), color_white)
end