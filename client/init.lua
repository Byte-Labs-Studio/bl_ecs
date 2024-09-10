lib.callback.register('bl_ecs:client:getVehicleData', function(vehicleHash)
    local model = lib.requestModel(vehicleHash)
    local ped = cache.ped
    local coords = GetEntityCoords(ped) + GetEntityForwardVector(ped)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, 100.0, false, false)
    SetModelAsNoLongerNeeded(model)
    SetEntityAlpha(vehicle, 0, true)
    local type = GetVehicleType(vehicle)
    DeleteVehicle(vehicle)

    return type
end)

lib.callback.register('bl_ecs:client:getVehicleProperties', function(netId, color1)
    local vehicle = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netId) then
            local vehicle = NetToVeh(netId)
            if DoesEntityExist(vehicle) then
                return vehicle
            end
        end
    end)

    local props = lib.waitFor(function()
        local props = lib.getVehicleProperties(vehicle)
        if props.color1 == color1 then
            return props
        end
    end)

    return props
end)

AddStateBagChangeHandler('vehicleProperties', nil, function(bagName, _, props, _, _)
    if not props then return end

    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end
    local playerId = cache.playerId

    local success = pcall(lib.waitFor, function()
        if NetworkGetEntityOwner(entity) == playerId then
            return true
        end
    end, 'Not entity owner', 10000)
    if not success then return end

    if props then
        lib.setVehicleProperties(entity, props)
    end

    Wait(0)
    Entity(entity).state:set('vehicleProperties', nil, true)
end)

-- CreateThread(function()
--     while true do
--         Wait(1000)
--         if testEnt ~= 0 then
--             print(Entity(testEnt).state.vehicleProperties)
--         end
--     end
-- end)