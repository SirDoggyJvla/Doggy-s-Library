--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Custom event which triggers when a zombie gets recycled.

]]--
--[[ ================================================ ]]--

---CACHE
-- create new event
local LuaEvent = require "Starlit/LuaEvent"
local OnZombieRecycle = {
    Event = LuaEvent.new(),
    ZOMBIES_CONTROL_RECYCLE = {},
}

return OnZombieRecycle