local MATERIAL_PARAMETERS = 'noclamp smooth'

local HERO = {
    name = 'Tracer',

    description = [[Toting twin pulse pistols, energy-based time bombs, and rapid-fire banter,
Tracer is able to "blink" through space and rewind her personal timeline as she battles to right wrongs the world over.]],

    abilities = {
        {
            name = 'Blink',
            description = [[Tracer zips horizontally through space in the direction she’s moving,
and reappears several yards away.
She stores up to three charges of the blink ability and generates more every few seconds.]],
            cooldown = 3,
            castFunction = blink
        },
        {
            name = 'Recall',
            description = [[Tracer bounds backward in time, returning her health,
ammo and position on the map to precisely where they were a few seconds before.]],
            cooldown = 12,
            castFunction = recall
        }
    },

    ultimate = {
        name = 'Pulse Bomb',
        description = [[Tracer lobs a large bomb that adheres to any surface or unfortunate opponent it lands on.
After a brief delay, the bomb explodes, dealing high damage to all enemies within its blast radius.]],
        castFunction = throwBomb,
        pointsRequired = 1125
    },

    materials = {
        abilities = {
            Material('tracer/blink.png', MATERIAL_PARAMETERS),
            Material('tracer/recall.png', MATERIAL_PARAMETERS)
        },
        ultimate = Material('tracer/bomb.png', MATERIAL_PARAMETERS),
        portrait = Material('tracer/portrait.png', MATERIAL_PARAMETERS),
    },

    health = 150
}

if not OWA_LOADED then
    hook.Add('OWA: Wait for OWA loading', 'Add Tracer', function() OverwatchHero(HERO) end)
else
    OverwatchHero(HERO)
end
