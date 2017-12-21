function EFFECT:Init(data)
    self:SetModel("models/effects/combineball.mdl")
    self:SetRenderMode(RENDERMODE_TRANSALPHA)
    self:SetPos(data:GetOrigin())
    self:SetAngles(LocalPlayer():EyeAngles())
    
    self.Color = Color(80, 157, 255, 178.5)
    self.Scale = 15
    self.Duration = 0.5
    self.Begin = CurTime()
    self:SetModelScale(self.Scale)
    self:SetColor(self.Color)
    
    local light = DynamicLight(self:EntIndex())
    light.Pos = self:GetPos()
    light.r, light.g, light.b = self.Color.r, self.Color.g, self.Color.b 
    light.brightness = 2
    light.Decay = 1000
    light.Size = 256
    light.DieTime = CurTime() + self.Duration
    
    -- if CLIENT then
        -- CreateMaterial("pulseBombLobRing", "VertexLitGeneric",
        -- {
            -- ["$basetexture"] = "bombBall",
            -- ["$model"] = 1
            -- --["$alpha"] = 0.7
        -- })
    -- end
    
    -- self:SetMaterial("!pulseBombLobRing", true)
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