local material = Material("bombBall.png")

function EFFECT:Init(data)
	self:SetModel("models/effects/combineball.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetMaterial(material)
	self:SetPos(data:GetOrigin())
	self:SetAngles(LocalPlayer():EyeAngles())
	
	self.Scale = 5
	self.Duration = 0.5
	self.Begin = CurTime()
	self:SetModelScale(self.Scale)
	
	local light = DynamicLight(self:EntIndex())
	light.Pos = self:GetPos()
	light.r, light.g, light.b = 80, 157, 255
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