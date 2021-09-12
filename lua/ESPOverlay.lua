
local vector = reloadPackage("lua/vector")
local Overlay = reloadPackage("lua/Overlay")
local worldToScreen = reloadPackage("lua/worldToScreen")

local module = {}

if not entityList then entityList = {} end

local inf = 1 / 0

local function toHex(x)
    return string.format("%x", x):upper()
end

function module.create(options)
    overlay = Overlay.create("UnrealWindow", nil)
    local c = overlay.Canvas
    local pen = overlay.Pen

    local worldToScreenFunc

    function forDisplayedEntities(cb)
        local f = overlay.form
        worldToScreenFunc = worldToScreen(f.Width, f.Height)

        local currentTime = getTickCount()
        for entityPtr, snapshotTime in pairs(entityList) do
            local snapshotAge = currentTime - snapshotTime
            local stale = snapshotAge > 100
            if stale then entityList[entityPtr] = nil end

            local health = readFloat(entityPtr + 0x9C)
            local validHealthRange = (health > 0 and health <= 1)

            local type = readSmallInteger(entityPtr + 0x0)
            local isNpc = not (readInteger(entityPtr + 0x0C) == 0xFFFFFFFF)

            local checkNPC = options.showInanimate or isNpc
            local checkHealth = options.showDead or validHealthRange

            if checkNPC and checkHealth then
                local footPos = vector.readVec(entityPtr + 0x18)
                local fp = worldToScreenFunc(footPos)
                if fp.depth > 0.1 then
                    cb(entityPtr, type, isNpc, fp)
                end
            end
        end
    end
        
    function render()
        c.Clear()
        pen.Color=0x00FF00
        pen.Width = 4
        c.Font.Size = 8
        c.Font.Style = "fsBold"
        -- c.Font.Color = pen.Color
        c.Font.Quality = "fqNonAntialiased"

        -- local f = overlay.form
        -- local worldToScreenFunc = worldToScreen(f.Width, f.Height)

        forDisplayedEntities(
            function(entityPtr, type, isNpc, fp)
                local neckPos = vector.readVec(entityPtr + 0x6DC)
                -- local neckPos = vector.readVec(entityPtr + 0x7E0)
                local np = worldToScreenFunc(neckPos)
                if options.showLines and isNpc and np.depth > 0.1 then
                    c.Line(fp.x, fp.y, np.x, np.y)
                end

                if options.showBoneNumbers and isNpc then
                    drawBoneNumbers(entityPtr)
                end

                local line = 0
                function showText(text)
                    c.Font.Color = 0x00FF00
                    local w = c.getTextWidth(text)
                    local h = c.getTextHeight(text)
                    c.textOut(fp.x - w / 2, fp.y + h * line, text)
                    line = line + 1
                end

                if options.showType then showText(toHex(type)) end
                if options.showPtr then showText(toHex(entityPtr)) end

            end
        )
    end

    function drawBoneNumbers(entityPtr)
        local baseBonePtr = entityPtr + 0x570
        local boneSize = 0x34
        local NUMBONES = 26
        for i = 0, NUMBONES - 1 do
            local bonePos = vector.readVec(baseBonePtr + i * boneSize)
            local bp = worldToScreenFunc(bonePos)
            if bp.depth > 0.1 then
                local text = tostring(i)
                local w = c.getTextWidth(text)
                c.Font.Color = 0xFFFFFF
                c.textOut(bp.x - w / 2, bp.y, text)
            end
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
        function ()
            local ptr = getEntityUnderReticle()
            if ptr then
                local text = toHex(ptr)
                writeToClipboard(text)
                beep()
            end
        end,
        VK_PAUSE
    )

    local t = createTimer(overlay.form)
    t.setInterval(1000 / 60)
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