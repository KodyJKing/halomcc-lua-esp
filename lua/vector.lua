local module = {}

function module.readVec(address)
    return {
        x = readFloat(address + 4),
        y = readFloat(address + 8),
        z = readFloat(address + 12),
    }
end

return module