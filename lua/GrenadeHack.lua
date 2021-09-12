local Entities = reloadPackage("lua/Entities")
local vector = reloadPackage("lua/vector")
local json = reloadPackage("lua/json")

local module = {}

local grenadeType = 0x0BC7
local marineType = 0x0288

local posOffset = 0x18
local velocityOffset = 0x24
local neckOffset = 0x06DC

local updatesPerSecond = 10
-- local attraction = 10
local attraction = 100
local cosAngleLimit = math.cos(math.pi / 24)
local guaranteedAttrationRange = 2
local maxSpeed = 1

function module.create()
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
                        local npcType = readSmallInteger(npcPtr)
                        if npcType ~= marineType then
                            local npcPos = vector.readVec(npcPtr + neckOffset)
                            local diff = vector.sub(npcPos, grenadePos)
                            local dist = vector.length(diff)
                            local diffUnit = vector.unit(diff)
                            local cosAngle = vector.dot(velUnit, diffUnit)
                            if (dist < guaranteedAttrationRange) or (cosAngle >= cosAngleLimit) then
                                local forceScalar = attraction / updatesPerSecond / dist -- / (dist * dist)
                                if not (forceScalar ~= forceScalar) then
                                    local force = vector.scale(diffUnit, forceScalar)
                                    netForce = vector.add(netForce, force)
                                end
                            end
                        end
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