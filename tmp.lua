local worldToScreen = reloadPackage("lua/worldToScreen")
local json          = require("lua/json")

local pos = {
    x = -60.32415009,
    y = -21.36865616,
    z = 3.919598818
}

local result = worldToScreen(pos, 1920, 1080)

print(json.encode(result))