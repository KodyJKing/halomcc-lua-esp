local json = require("lua/json")

local module = {}

local function readMatrix3x4(address)
    local result = {}
    for i = 0, 11 do
        result[i] = readFloat(address + i * 4)
    end
    return result
end

function worldToScreen(width, height)
    local invViewMat = readMatrix3x4(getAddress("halo1.dll+1AC5174"))
    local fov = readFloat("halo1.dll+19E79E4")
    local w = 2 * math.tan(fov / 2)

    return function(v)
        local m = invViewMat
    
        local forwardOffset = 0
        local leftOffset = 3
        local upOffset = 6
        local eyeOffset = 9
    
        local f = forwardOffset
        local l = leftOffset
        local u = upOffset
        local e = eyeOffset
    
        local diff = {
            x = v.x - m[e],
            y = v.y - m[e + 1],
            z = v.z - m[e + 2]
        }
        local d = diff
    
        local depth = d.x * m[f + 0] + d.y * m[f + 1] + d.z * m[f + 2]
        local left  = d.x * m[l + 0] + d.y * m[l + 1] + d.z * m[l + 2]
        local up    = d.x * m[u + 0] + d.y * m[u + 1] + d.z * m[u + 2]
    
        left = left / depth / w * width
        up = up / depth / w * width
        
        return {
            x = width / 2 - left,
            y = height / 2 - up,
            depth = depth
        }
    end
end

return worldToScreen