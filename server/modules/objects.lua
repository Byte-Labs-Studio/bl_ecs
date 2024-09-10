local utils = require 'server.utils'
local entities = require 'server.store'.entities

local function spawnObject(data)
    local coords = data.coords
    local model = data.model
    local object = CreateObjectNoOffset(model, coords.x, coords.y, coords.z, true, true, data.door or false)
    local loaded = utils.waitForEntityToLoad(object)
    if not loaded then return end

    entities[object] = {
        entityType = 'object',
        model = model
    }

    return object
end

RegisterCommand('spawnobject', function(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    spawnObject({
        model = `h4_prop_h4_champ_tray_01c`,
        coords = vec4(coords.x + 2, coords.y, coords.z, GetEntityHeading(GetPlayerPed(src))),
    })
end, false)