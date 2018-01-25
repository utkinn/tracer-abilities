local MATERIAL_PARAMETERS = 'smooth'

OWTA_MATERIALS = {
    blink = Material("blink.png", MATERIAL_PARAMETERS),
    recall = Material("recall.png", MATERIAL_PARAMETERS),
    bomb = Material("bomb.png", MATERIAL_PARAMETERS),
    crosshair = {
        blink = {
            [true] = Material("blinkCrosshairOn.png"),
            [false] = Material("blinkCrosshairOff.png")
        },
        recall = {
            [true] = Material("recallCrosshairOn.png"),
            [false] = Material("recallCrosshairOff.png")
        }
    }
}
