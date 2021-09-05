local module = {}

if entityList == nil then entityList = {} end

function module.removeStale(maxAgeMilis)
    local currentTime = getTickCount()
    for entityPtr, snapshotTime in pairs(entityList) do
        local snapshotAge = currentTime - snapshotTime
        local stale = snapshotAge > maxAgeMilis
        if stale then 
            entityList[entityPtr] = nil
        end
    end
end

function module.isNPC(entityPtr)
    local health = readFloat(entityPtr + 0x9C)
    local isLiving = health > 0.001 and health <= 1.001
    local isInanimate = (readInteger(entityPtr + 0x0C) == 0xFFFFFFFF)
    return isLiving and not isInanimate
end

function module.forEntitiesOfType(type, callback)
    for entityPtr, _ in pairs(entityList) do
        local entityType = readSmallInteger(entityPtr + 0x00)
        if entityType == type then
            callback(entityPtr)
        end
    end
end

function module.forNPCs(callback)
    for entityPtr, _ in pairs(entityList) do
        if module.isNPC(entityPtr) then
            callback(entityPtr)
        end
    end
end

return module