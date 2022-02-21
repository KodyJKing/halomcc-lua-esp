local vector = reloadPackage("lua/vector")
local Overlay = reloadPackage("lua/Overlay")
local worldToScreen = reloadPackage("lua/worldToScreen")
local Entities = reloadPackage("lua/Entities")
local Maps = reloadPackage("lua/Maps")

local module = {}

if not entityList then entityList = {} end

local inf = 1 / 0
local staleTime = 1000

local function toHex(x)
    return string.format("%x", x):upper()
end

function module.create(options)
    overlay = Overlay.create("UnrealWindow", nil)
    local c = overlay.Canvas
    local pen = overlay.Pen

    local worldToScreenFunc
    local map

    function forDisplayedEntities(cb)
        local f = overlay.form
        worldToScreenFunc = worldToScreen(f.Width, f.Height)

        local currentTime = getTickCount()
        for entityPtr, snapshotTime in pairs(entityList) do
            local snapshotAge = currentTime - snapshotTime
            local stale = snapshotAge > staleTime
            if stale then entityList[entityPtr] = nil end

            local health = readFloat(entityPtr + 0x9C)
            local validHealthRange = (health > 0 and health <= 1)

            local typeNum = readSmallInteger(entityPtr + 0x0)
            local isNpc = Entities.isNPC(entityPtr)

            local checkNPC = options.showInanimate or isNpc
            local checkHealth = options.showDead or validHealthRange

            if checkNPC and checkHealth then
                local footPos = vector.readVec(entityPtr + 0x18)
                local fp = worldToScreenFunc(footPos)
                if fp.depth > 0.1 then
                    cb(entityPtr, typeNum, isNpc, fp)
                end
            end
        end
    end

    function render()
        c.Clear()
        pen.Color = 0x00FF00
        pen.Width = 4
        c.Font.Size = 8
        c.Font.Style = "fsBold"
        -- c.Font.Color = pen.Color
        c.Font.Quality = "fqNonAntialiased"

        map = Maps.getMap()

        forDisplayedEntities(
        function(entityPtr, typeNum, isNpc, fp)
            local neckPos = vector.readVec(entityPtr + 0x6DC)
            local np = worldToScreenFunc(neckPos)
            local name = map.entityNames[typeNum]
            local type = Entities.getType(entityPtr, map)

            if options.showLines and isNpc and np.depth > 0.1 then
                c.Line(fp.x, fp.y, np.x, np.y)
            end

            if name ~= "player" and isNpc then
                if options.showBoneNumbers then
                    drawBoneNumbers(entityPtr)
                end
                if type.skeleton ~= nil and options.showBones then
                    drawBoneEdges(entityPtr, type.skeleton)
                end
                if type and type.headBoneIndex and options.showHeadBone then
                    drawBoneNumber(entityPtr, type.headBoneIndex, 0x0000FE, 100)
                end
            end

            local line = 0
            function showText(text)
                c.Font.Color = 0x00FF00
                local w = c.getTextWidth(text)
                local h = c.getTextHeight(text)
                c.textOut(fp.x - w / 2, fp.y + h * line, text)
                line = line + 1
            end

            if options.showType then showText(toHex(typeNum)) end
            if options.showPtr then showText(toHex(entityPtr)) end
            if name and options.showName then showText(name) end
            if options.showPos then
                local pos = vector.readVec(entityPtr + 0x18)
                showText(vector.toString(pos, 3))
            end

        end
        )
    end

    function drawBoneNumber(entityPtr, i, color, maxDepth)
        color = color or 0xFFFFFF
        maxDepth = maxDepth or 10

        local bonePos = Entities.getBone(entityPtr, i)
        local bp = worldToScreenFunc(bonePos)
        if bp.depth > 0.1 and bp.worldDepth < maxDepth then
            local text = tostring(i)
            local w = c.getTextWidth(text)
            c.Font.Color = color
            c.textOut(bp.x - w / 2, bp.y, text)
        end
    end

    function drawBoneNumbers(entityPtr, color)
        local maxNumBones = 32
        for i = 0, maxNumBones - 1 do
            drawBoneNumber(entityPtr, i, color)
        end
    end

    function drawBoneEdge(entityPtr, i, j, color)
        color = color or 0xFFFFFF

        local bonePos_i = Entities.getBone(entityPtr, i)
        local bonePos_j = Entities.getBone(entityPtr, j)
        local bp_i = worldToScreenFunc(bonePos_i)
        local bp_j = worldToScreenFunc(bonePos_j)
        if bp_i.depth > 0.1 and bp_j.depth > 0.1 then
            pen.color = color
            c.line(bp_i.x, bp_i.y, bp_j.x, bp_j.y)
        end
    end

    function drawBoneEdges(entityPtr, skeleton, color)
        for _, edge in ipairs(skeleton) do
            drawBoneEdge(entityPtr, edge[1], edge[2], color)
        end
    end

    function getEntityUnderReticle()
        local bestPtr = nil
        local bestDistSq = inf
        forDisplayedEntities(
        function(entityPtr, type, isNpc, fp)
            local f = overlay.form
            local w = f.Width
            local h = f.Height
            local dx = math.abs(w / 2 - fp.x)
            local dy = math.abs(h / 2 - fp.y)
            local distSq = dx * dx + dy * dy
            if distSq < bestDistSq then
                bestPtr = entityPtr
                bestDistSq = distSq
            end
        end
        )
        return bestPtr
    end

    local hotkey = createHotkey(
    function()
        local ptr = getEntityUnderReticle()
        if ptr then
            local type = readSmallInteger(ptr + 0x00)
            local pos = vector.readVec(ptr + 0x18)
            print(toHex(ptr))
            print(toHex(type))
            print(vector.toString(pos, 3))
            print("")
            -- writeToClipboard(text)
            beep()
        end
    end,
        VK_PAUSE
    )

    local t = createTimer(overlay.form)
    t.setInterval(1000 / 30)
    t.OnTimer = render

    return {
        overlay = overlay,
        destroy = function()
            overlay.destroy()
            hotkey.destroy()
        end
    }
end

return module
