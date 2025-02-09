--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Custom event which is used to detect whenever a new chunk is loaded.

Connected to LoadChunk event and simply identifies newly loaded chunks.

]]--
--[[ ================================================ ]]--

local LuaEvent = require "Starlit/LuaEvent"
local DoggyAPI = require "DoggyAPI_module"
DoggyAPI.EVENTS.LoadNewChunk = LuaEvent.new()

