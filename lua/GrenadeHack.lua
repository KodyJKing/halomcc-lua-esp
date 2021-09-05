local module = {}

function module.create()
    local updatesPerSecond = 10
    local timer = createTimer()
    timer.setInterval(1000 / updatesPerSecond)
    timer.OnTimer = function()
        print("Not implemented!")
    end
    return {
        destroy = function()
            timer.destroy()
        end
    }
end

return module