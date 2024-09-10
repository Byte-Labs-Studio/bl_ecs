local utils = require 'server.utils'
local entities = require 'server.store'.entities

local function spawnPed(data)
    local coords = data.coords
    local model = data.model
    local ped = CreatePed(2, model, coords.x, coords.y, coords.z, coords.w, false, false)
    local loaded = utils.waitForEntityToLoad(ped)
    if not loaded then return end

    entities[ped] = {
        entityType = 'ped',
        model = model
    }
    return ped
end

RegisterCommand('spawnped', function(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    spawnPed({
        model = `a_f_m_bevhills_02`,
        coords = vec4(coords.x + 2, coords.y, coords.z, GetEntityHeading(GetPlayerPed(src))),
    })
end, false)