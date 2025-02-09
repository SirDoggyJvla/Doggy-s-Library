--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Various events the framework links to.

]]--
--[[ ================================================ ]]--

---requirements
local DoggyAPI = require "DoggyAPI_module"
require "DoggyTools/DoggyAPI_world"
local BatteryHandler = require "DoggyTools/DoggyAPI_BatteryHandler"

---Event triggered when global mod data get initialized
Events.OnInitGlobalModData.Add(function()
    DoggyAPI.MODDATA.NewChunks = ModData.getOrCreate("DoggyAPI_NewChunk")
end)

Events.OnFillInventoryObjectContextMenu.Add(BatteryHandler.OnFillInventoryObjectContextMenu)

---Event triggered when a chunk is loaded
Events.LoadChunk.Add(DoggyAPI.WORLD.LoadChunk)