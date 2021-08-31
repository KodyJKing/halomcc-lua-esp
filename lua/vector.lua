local module = {}

function module.readVec(address)
    return {
        x = readFloat(address + 0),
        y = readFloat(address + 4),
        z = readFloat(address + 8),
    }
end

function module.dist(a, b)
    return math.sqrt(
        (a.x - b.x) ^ 2 +
        (a.y - b.y) ^ 2 +
        (a.z - b.z) ^ 2
    )
end

function module.addZ(v, z)
    return {
        x = v.x,
        y = v.y,
        z = v.z + z,
    }
end

return module