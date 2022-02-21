local json = require("lua/json")

local module = {}

local maps = {
    a10 = {
        name = "The Pillar of Autumn",
        file = "a10"
    },
    a30 = {
        name = "Halo",
        file = "a30"
    },
    a50 = {
        name = "The Truth and Reconciliation",
        file = "a50",
        entityTypes = {
            player     = 0x569,
            jackal1    = 0xA0C,
            jackal2    = 0x9B2,
            grunt      = 0x8CE,
            elite1     = 0x5E9,
            elite2     = 0x8BC,
            hunter     = 0x675,
            marine1    = 0x07A,
            marine2    = 0x50D,
            keyes      = 0x4AF,
        }
    },
    b30 = {
        name = "The Silent Cartographer",
        file = "b30",
        entityTypes = {
            player     = 0x0DD,
            jackal1    = 0xA9C,
            jackal2    = 0xA44,
            grunt      = 0x957,
            elite1     = 0x59D,
            elite2     = 0xA9F,
            hunter     = 0x9E7,
            marine1    = 0x288,
        }
    },
    b40 = {
        name = "Assault on the Control Room",
        file = "b40",
        entityTypes = {
            player     = 0x0CC,
            jackal1    = 0xC00, -- yellow shield
            jackal2    = 0x872, -- blue shield
            grunt      = 0x262,
            elite1     = 0x49D,
            elite2     = 0xBE3,
            hunter     = 0x7FE,
            marine1    = 0x560,
            sergeant   = 0xC21
        }
    },
    c10 = {
        name = "343 Guilty Spark",
        file = "c10"
    },
    c20 = {
        name = "The Library",
        file = "c20"
    },
    c40 = {
        name = "Two Betrayals",
        file = "c40"
    },
    d20 = {
        name = "Keyes",
        file = "d20",
    },
    d40 = {
        name = "The Maw",
        file = "d40"
    }
}

local function invertTable(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[v] = k
    end
    return res
end

for _, map in pairs(maps) do
    if map.entityTypes ~= nil then
        map.entityNames = invertTable(map.entityTypes)
    end
end

function module.getMap()
    local mapName = readString("halo1.dll+2A52D84+20", 3, false)
    return maps[mapName]
end

function module.printMap()
    local map = module.getMap()
    print(map.name)
end

return module
