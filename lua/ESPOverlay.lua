
local vector = reloadPackage("lua/vector")
local Overlay = reloadPackage("lua/Overlay")
local worldToScreen = reloadPackage("lua/worldToScreen")

local module = {}

if not entityList then entityList = {} end

function module.create()
    overlay = Overlay.create("UnrealWindow", nil)
    local c = overlay.Canvas
    local pen = overlay.Pen
        
    function render()
        c.Clear()
        pen.Color=0x00FF00
        pen.Width = 4

        c.Font.Size = 16
        c.Font.Style = "fsBold"
        c.Font.Color = pen.Color
        c.Font.Quality = "fqNonAntialiased"
        -- c.textOut(10, 10, "Hello?")

        local f = overlay.form
        local worldToScreenFunc = worldToScreen(f.Width, f.Height)

        local currentTime = getTickCount()
    
        for entityPtr, snapshotTime in pairs(entityList) do

            local snapshotAge = currentTime - snapshotTime
            local stale = snapshotAge > 100
            if stale then entityList[entityPtr] = nil end

            local health = readFloat(entityPtr + 0x9C)
            local validHealthRange = (health > 0 and health <= 1)

            local type = readSmallInteger(entityPtr + 0x0)
            local isNpc = not (readInteger(entityPtr + 0x0C) == 0xFFFFFFFF)

            -- if true then
            -- if isNpc and not stale and validHealthRange then
            if isNpc then
                local footPos = vector.readVec(entityPtr + 0x18)
                local neckPos = vector.readVec(entityPtr + 0x6DC)
                -- local neckPos = vector.readVec(entityPtr + 0x7E0)
                -- When entities get in vehicles, some of their key points are not updated.
                local dist = vector.dist(footPos, neckPos)
                if dist > 2 then
                    footPos = vector.addZ(neckPos, -0.5)
                end
                local footScreenPos = worldToScreenFunc(footPos)
                local torsoScreenPos = worldToScreenFunc(neckPos)
                local fp = footScreenPos
                local np = torsoScreenPos
                if fp.depth > 0.1 and np.depth > 0.1 then
                    c.Line(fp.x, fp.y, np.x, np.y)
                    local typeStr =  string.format("%x", type):upper()
                    local textWidth = c.getTextWidth(typeStr)
                    local textHeight = c.getTextHeight(typeStr)
                    c.textOut(fp.x - textWidth / 2, fp.y, typeStr)
                end
            end
        end
    end
    
    local t = createTimer(overlay.form)
    t.setInterval(1000 / 60)
    t.OnTimer = render

    return {
        overlay = overlay,
        destroy = function()
            overlay.destroy()
        end
    }
end

return module