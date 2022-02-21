local vector = reloadPackage("lua/vector")
local Maps = reloadPackage("lua/Maps")

local module = {}

if entityList == nil then entityList = {} end

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
    },
    jackal2 = {
        living = true,
        friendly = false,
        headBoneIndex = 22,
    },
    grunt = {
        living = true,
        friendly = false,
        headBoneIndex = 12,
    },
    elite1 = {
        living = true,
        friendly = false,
        headBoneIndex = 17,
    },
    elite2 = {
        living = true,
        friendly = false,
        headBoneIndex = 17,
    },
    hunter = {
        living = true,
        friendly = false,
    },
    marine1 = {
        living = true,
        friendly = true,
        headBoneIndex = 16,
        skeleton = {
            { 0, 1 }, { 1, 4 }, { 4, 8 }, -- left leg
            { 0, 2 }, { 2, 5 }, { 5, 11 }, -- right leg
            { 0, 3 }, { 3, 6 }, { 6, 9 }, -- torso, hip to neck
            { 9, 7 }, { 7, 13 }, { 13, 15 }, { 15, 18 }, -- left arm
            { 9, 10 }, { 10, 14 }, { 14, 17 }, { 17, 19 }, -- right arm
            { 9, 12 }, { 12, 16 } -- head, lower-neck to skull
        }
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
