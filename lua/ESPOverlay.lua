local Overlay = reloadPackage("lua/Overlay")
local worldToScreen = reloadPackage("lua/worldToScreen")

local module = {}

function module.create()
    overlay = Overlay.create("UnrealWindow", nil)
    local c = overlay.Canvas
    local pen = overlay.Pen
    
    function render()
      c.Clear()
      pen.Color=0x00FF00
      pen.Width = 4
      local worldToScreenFunc = worldToScreen(1920, 1080)
    
      for entityPtr, t in pairs(entityList) do
        local pos = {
          x = readFloat(entityPtr + 0x18),
          y = readFloat(entityPtr + 0x1C),
          z = readFloat(entityPtr + 0x20),
        }
        local screenPos = worldToScreenFunc(pos)
        local p = screenPos
        if p.depth > 0 then
          c.Line(p.x - 1, p.y - 1, p.x, p.y)
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