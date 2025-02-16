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

---Event triggered when the player right clicks on an item in the inventory
local BatteryHandler = require "DoggyTools/BatteryHandler"
Events.OnFillInventoryObjectContextMenu.Add(BatteryHandler.OnFillInventoryObjectContextMenu)

---Event triggered when a chunk is loaded
local LoadNewChunk = require "DoggyEvents/LoadNewChunk"
Events.LoadChunk.Add(LoadNewChunk.LoadChunk)