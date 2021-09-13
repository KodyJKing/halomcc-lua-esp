local vector = reloadPackage("lua/vector")
local Maps = reloadPackage("lua/Maps")

local module = {}

if entityList == nil then entityList = {} end

module.entityTypes = {
    player = {
        friendly = true,
        isPlayer = true,
    },
    jackal1 = {
        friendly = false,
        headBoneIndex = 22,
    },
    jackal2 = {
        friendly = false,
        headBoneIndex = 22,
    },
    grunt = {
        friendly = false,
        headBoneIndex = 12,
    },
    elite1 = {
        friendly = false,
        headBoneIndex = 17,
    },
    elite2 = {
        friendly = false,
        headBoneIndex = 17,
    },
    hunter = {
        friendly = false,
    },
    marine1 = {
        friendly = true,
        headBoneIndex = 16,
    },
}

function module.getType(entityPtr, map)
    if map == nil then map = Maps.getMap() end
    local typeNum = readSmallInteger(entityPtr + 0x00)
    local typeName = map.entityNames[typeNum]
    return module.entityTypes[typeName]
end

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
    local check1 = (readInteger(entityPtr + 0x0C) ~= 0xFFFFFFFF)
    local check2 = (readInteger(entityPtr + 0x74) ~= 0xFFFFFFFF)
    local check3 = (readInteger(entityPtr + 0x88) ~= 0xFFFFFFFF)
    return check1 or check2 or check3
end

function module.forEntitiesOfType(type, callback)
    for entityPtr, _ in pairs(entityList) do
        local entityType = readSmallInteger(entityPtr + 0x00)
        if entityType == type then
            callback(entityPtr)
        end
    end
end

function module.forNPCs(allowDead, callback)
    for entityPtr, _ in pairs(entityList) do
        local health = readFloat(entityPtr + 0x9C)
        local isLiving = health > 0.001 and health <= 1.001
        local livingCheck = allowDead or isLiving
        if livingCheck and module.isNPC(entityPtr) then
            callback(entityPtr)
        end
    end
end

function module.getBone(entityPtr, index)
    return vector.readVec(entityPtr + 0x570 + 0x34 * index)
end

return module