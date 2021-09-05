local Entities = reloadPackage("lua/Entities")
local vector = reloadPackage("lua/vector")
local json = reloadPackage("lua/json")

local module = {}

local grenadeType = 0x0BC7

local posOffset = 0x18
local velocityOffset = 0x24
local neckOffset = 0x06DC

local attraction = 10
local cosAngleLimit = math.cos(2 * math.pi / 24)

function module.create()
    local updatesPerSecond = 10
    local timer = createTimer()
    timer.setInterval(1000 / updatesPerSecond)
    timer.OnTimer = function()
        Entities.removeStale(100)
        Entities.forEntitiesOfType(
            grenadeType,
            function (grenadePtr)
                local grenadePos = vector.readVec(grenadePtr + posOffset)
                local vel = vector.readVec(grenadePtr + velocityOffset)
                local speed = vector.length(vel)
                local velUnit = vector.unit(vel)
                local netForce = vector.vector(0, 0, 0)
                Entities.forNPCs(
                    function (npcPtr)
                        local npcPos = vector.readVec(npcPtr + neckOffset)
                        local diff = vector.sub(npcPos, grenadePos)
                        local diffUnit = vector.unit(diff)
                        local cosAngle = vector.dot(velUnit, diffUnit)
                        -- if cosAngle <= cosAngleLimit then
                            local dist = vector.length(diff)
                            local forceScalar = attraction / updatesPerSecond / (dist * dist)
                            local force = vector.scale(diffUnit, forceScalar)
                            netForce = vector.add(netForce, force)
                        -- end
                    end
                )
                vel = vector.add(vel, netForce)
                vel = vector.withLength(vel, speed) -- Redirect rather than speed up.
                vector.writeVec(grenadePtr + velocityOffset, vel)
                --print(json.encode(netForce))
            end
        )
    end
    return {
        destroy = function()
            timer.destroy()
        end
    }
end

return module