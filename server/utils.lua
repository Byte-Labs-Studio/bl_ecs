local utils = {}
function utils.waitForEntityToLoad(entity)
    return lib.waitFor(function()
        if DoesEntityExist(entity) then
            return true
        end
    end, ('Vehicle didnt load %s'):format(GetEntityModel(entity)))
end

return utils