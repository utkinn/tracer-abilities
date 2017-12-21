function createFonts()
    surface.CreateFont("Overwatch", {
        font = "BigNoodleTooOblique",
        size = 50
    })
    surface.CreateFont("Overwatch 0.5x", {
        font = "BigNoodleTooOblique",
        size = 25
    })
end

createFonts()
hook.Add("InitPostEntity", "createFont", createFonts)