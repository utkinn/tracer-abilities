local FONT_NAME = "BigNoodleTooOblique"

function createFonts()
    surface.CreateFont("Overwatch", {
        font = FONT_NAME,
        size = 50
    })
    surface.CreateFont("Overwatch 0.5x", {
        font = FONT_NAME,
        size = 25
    })
end

createFonts()
hook.Add("InitPostEntity", "createFont", createFonts)
