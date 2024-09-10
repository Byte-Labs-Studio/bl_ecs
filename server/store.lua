local store = {
    entities = {}
}

exports('getEntity', function(entity)
    return store.entities[entity]
end)

exports('getAllEntities', function()
    return store.entities
end)

return store