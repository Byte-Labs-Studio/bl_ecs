local lib = lib
if not lib then return end
local entities = {}

local function spawnVehicle(data)
    local source = data.src
    local hash = data.model
    local coords, type = data.coords, data.type or source and lib.callback.await('bl_ecs:client:getVehicleData', source, hash)
    local props = data.properties

    assert(type, ('Type unknown for %s'):format(hash))

    local vehicle = CreateVehicleServerSetter(hash, type, coords.x, coords.y, coords.z, coords.w)
    lib.waitFor(function()
        if DoesEntityExist(vehicle) then
            return true
        end
    end, ('Vehicle didnt load %s'):format(hash))

    if props then
        Entity(vehicle).state:set('vehicleProperties', props)
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    if not props then
        -- trick to get correct vehicle props from client, other wise it will get wrong data like (colors)
        local color1 = lib.waitFor(function()
            local color1 = GetVehicleColours(vehicle)
            if color1 ~= 0 then
                return color1
            end
        end, ('Vehicle props didnt load %s'):format(hash))

        props = lib.callback.await('bl_ecs:client:getVehicleProperties', source, netId, color1)
    end

    entities[vehicle] = {
        type = type,
        properties = props,
        model = hash
    }

    return vehicle
end

AddEventHandler('entityRemoved', function(handle)
    local entity = entities[handle]
    if not entity then return end

    local coords = GetEntityCoords(handle)
    local heading = GetEntityHeading(handle)
    entity.coords = vec4(coords.x, coords.y, coords.z, heading)
    spawnVehicle(entity)
    entity.coords = nil
end)

RegisterCommand('spawn', function(src)
    local coords = GetEntityCoords(GetPlayerPed(src))
    spawnVehicle({
        model = 'sultan2',
        coords = vec4(coords.x + 2, coords.y, coords.z, GetEntityHeading(GetPlayerPed(src))),
        src = src
    })
end, false)

SetRoutingBucketEntityLockdownMode(GetPlayerRoutingBucket('1'), 'strict')

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    for entity in pairs(entities) do
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
end)