materials = {
    blink = Material("blink.png", "smooth"),
    recall = Material("recall.png", "smooth"),
    bomb = Material("bomb.png", "smooth"),
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