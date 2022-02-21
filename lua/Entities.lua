local vector = reloadPackage("lua/vector")
local Maps = reloadPackage("lua/Maps")

local module = {}

if entityList == nil then entityList = {} end

local function chain(bones)
    local result = {}
    for i = 1, #bones - 1 do
        table.insert(result, { bones[i], bones[i + 1] })
    end
    return result
end

local function flatten(arr)
    local result = {}
    for _, subArr in ipairs(arr) do
        for _, elem in ipairs(subArr) do
            table.insert(result, elem)
        end
    end
    return result
end

local jackalSkeleton = flatten({
    chain({ 0, 1, 7, 11, 16 }), -- left leg
    chain({ 0, 2, 8, 14, 18 }), -- right leg
    chain({ 0, 3, 9, 12, 21, 22 }), -- spine
    chain({ 12, 10, 17, 20, 24 }), -- left arm
    chain({ 12, 13, 19, 23, 25 }), -- right arm
})

local eliteSkeleton = flatten({
    chain({ 0, 1, 4, 8, 12 }), -- left leg
    chain({ 0, 2, 5, 11, 15 }), -- right leg
    chain({ 0, 3, 6, 9, 14, 17 }), -- spine
    chain({ 9, 7, 13, 18, 20 }), -- left arm
    chain({ 9, 10, 16, 19, 21 }), -- right arm
    chain({ 17, 22, 24 }), -- left mandible
    chain({ 17, 23, 25 }), -- right mandible
})

module.entityTypes = {
    player = {
        living = true,
        friendly = true,
        isPlayer = true,
    },
    jackal1 = {
        living = true,
        friendly = false,
        headBoneIndex = 22,
        skeleton = jackalSkeleton
    },
    jackal2 = {
        living = true,
        friendly = false,
        headBoneIndex = 22,
        skeleton = jackalSkeleton
    },
    grunt = {
        living = true,
        friendly = false,
        headBoneIndex = 12,
        skeleton = flatten({
            chain({ 0, 1, 4, 8 }), -- left leg
            chain({ 0, 2, 5, 11 }), -- right leg
            chain({ 0, 3, 6, 9, 12 }), -- spine
            chain({ 9, 7, 13, 15 }), -- left arm
            chain({ 9, 10, 14, 16 }), -- left arm
        })
    },
    elite1 = {
        living = true,
        friendly = false,
        headBoneIndex = 17,
        skeleton = eliteSkeleton
    },
    elite2 = {
        living = true,
        friendly = false,
        headBoneIndex = 17,
        skeleton = eliteSkeleton
    },
    hunter = {
        living = true,
        friendly = false,
    },
    marine1 = {
        living = true,
        friendly = true,
        headBoneIndex = 16,
        skeleton = flatten({
            chain({ 0, 1, 4, 8 }), -- left leg
            chain({ 0, 2, 5, 11 }), -- right leg
            chain({ 0, 3, 6, 9, 12, 16 }), -- spine
            chain({ 9, 7, 13, 15, 18 }), -- left arm
            chain({ 9, 10, 14, 17, 19 }), -- right arm
        })
    },
}

function module.getType(entityPtr, map)
    if map == nil then map = Maps.getMap() end
    local typeNum = readSmallInteger(entityPtr + 0x00)
    local typeName = map.entityNames[typeNum]
    return module.entityTypes[typeName]
end

-- Is *probably* an npc. It's much better to check
-- the entity's type via Entities.getType.
function module.isNPC(entityPtr)
    local check1 = (readInteger(entityPtr + 0x0C) ~= 0xFFFFFFFF)
    local check2 = (readInteger(entityPtr + 0x74) ~= 0xFFFFFFFF)
    local check3 = (readInteger(entityPtr + 0x88) ~= 0xFFFFFFFF)
    return check1 or check2 or check3
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

-- See halo1.dll+BFE228
function module.entityIdToPointer(id)
    local index = bAnd(id, 0xFFFF)
    -- mov r12,[7FF856A482C8]
    local _r12 = readQword(0x7FF856A682C8)
    -- mov r11,[7FF8579CD980]
    local _r11 = readQword(0x7FF8579ED980)
    -- lea rax,[r10+r10*2]
    -- lea rcx,[rax*4+00000000]
    -- movsxd  rax,dword ptr [r12+34]
    -- add rax,rcx
    local _rax = readInteger(_r12 + 0x34) + index * 12
    -- movsxd  rsi,dword ptr [rax+r12+08]
    local _rsi = readInteger(_rax + _r12 + 0x08)
    -- lea rbx,[r11+34]
    -- add rbx,rsi ; halo1.dll+BFE228
    local _rbx = _r11 + 0x34 + _rsi
    return _rbx
end

function module.getBone(entityPtr, index)
    return vector.readVec(entityPtr + 0x570 + 0x34 * index)
end

return module
