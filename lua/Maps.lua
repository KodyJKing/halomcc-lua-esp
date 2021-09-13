local json = require("lua/json")

local module = {}

local function invertTable(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[v] = k
    end
    return res
end

local maps = {
    {
        name = "The Pillar of Autumn",
        file = "a10.map",
        size = 96571064
    },
    {
        name = "Halo",
        file = "a30.map",
        size = 38355292
    },
    {
        name = "The Truth and Reconciliation",
        file = "a50.map",
        size = 54531080,
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
    {
        name = "The Silent Cartographer",
        file = "b30.map",
        size = 36237008,
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
    {
        name = "Assault on the Control Room",
        file = "b40.map",
        size = 78880812,
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
    {
        name = "343 Guilty Spark",
        file = "c10.map",
        size = 63064936
    },
    {
        name = "The Library",
        file = "c20.map",
        size = 55255932
    },
    {
        name = "Two Betrayals",
        file = "c40.map",
        size = 79063960
    },
    {
        name = "Keyes",
        file = "d20.map",
        size = 61109928
    },
    {
        name = "The Maw",
        file = "d40.map",
        size = 94048692
    }
}

local sizeToMap = {}
for _, map in ipairs(maps) do
    sizeToMap[map.size] = map
    if map.entityTypes then
        map.entityNames = invertTable(map.entityTypes)
    end
end

function module.getMap()
    local size = readInteger("halo1.dll+2A4BC04 + 08")
    return sizeToMap[size]
end

function module.printMap()
    local map = module.getMap()
    print(json.encode(map))
end

-- local maps = reloadPackage("lua/maps")
-- maps.printMap()

return module