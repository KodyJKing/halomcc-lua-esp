local Overlay = {}

function Overlay.getWindowRect(class, name)
    local win = findWindow(class, name)
    local m = createMemoryStream()
    m.size = 16
    local result
    if executeCodeLocalEx("GetWindowRect", win, m.Memory) then
        m.Position = 0
        result = {
            left = m.readDword(),
            top = m.readDword(),
            right = m.readDword(),
            bottom = m.readDword()
        }
    end
    m.destroy()
    return result
end

function Overlay.create(windowClassName, windowTitle)
    local overlay = {}

    local f = createForm(false)
    f.BorderStyle = "bsNone"
    f.Color = 0xFF
    f.setLayeredAttributes(0xFF, 255, 3)
    f.FormStyle = "fsSystemStayOnTop"
    f.visible = true

    overlay.form = f
    overlay.Canvas = f.Canvas
    overlay.Pen = f.Canvas.Pen
    overlay.updatePosition = function()
        local rect = Overlay.getWindowRect(windowClassName, windowTitle)
        f.Left = rect.left
        f.Top = rect.top
        f.Width = rect.right - rect.left
        f.Height = rect.bottom - rect.top
    end
    overlay.destroy = function()
        f.destroy()
    end

    overlay.updatePosition()

    return overlay
end

return Overlay
