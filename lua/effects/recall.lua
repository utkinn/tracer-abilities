local material = Material("models/props_combine/stasisshield_sheet")

function EFFECT:Init(data)
	local color = Color(192, 255, 255)
	
	self:SetModel("models/effects/combineball.mdl")
	self:SetMaterial(material)
	self:SetPos(data:GetOrigin())
	self:SetAngles(LocalPlayer():EyeAngles())
	
	self:SetColor(color)
	self.Scale = 4
	self.Duration = 0.25
	self.Begin = CurTime()
	self:SetModelScale(self.Scale)
	
	local light = DynamicLight(self:EntIndex())
	light.Pos = self:GetPos()
	light.r, light.g, light.b = color.r, color.g, color.b
	light.brightness = 2
	light.Decay = 1000
	light.Size = 256
	light.DieTime = CurTime() + self.Duration
end

function EFFECT:Think()
	self:SetAngles(LocalPlayer():EyeAngles())
	return CurTime() < self.Begin + self.Duration
end

function EFFECT:Render()
	local scale = (self.Duration - CurTime() + self.Begin) / self.Duration * self.Scale
	self:SetModelScale(scale)
	self:SetAngles(LocalPlayer():EyeAngles())
	self:DrawModel()
end