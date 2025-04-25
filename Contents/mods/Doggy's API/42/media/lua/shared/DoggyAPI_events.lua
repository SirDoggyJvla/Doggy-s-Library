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




---Event triggered when the player right clicks on an item in the inventory
local BatteryHandler = require "DoggyTools/BatteryHandler"
Events.OnFillInventoryObjectContextMenu.Add(BatteryHandler.OnFillInventoryObjectContextMenu)

---Event triggered when a chunk is loaded
local LoadNewChunk = require "DoggyEvents/LoadNewChunk"
Events.LoadChunk.Add(LoadNewChunk.LoadChunk)

local DebugContextMenu = require "DoggyDebugTools/DebugContextMenu"
Events.OnFillWorldObjectContextMenu.Add(DebugContextMenu.OnFillWorldObjectContextMenu)

local VisualMarkers = require "DoggyDebugTools/VisualMarkers"
Events.OnPostRender.Add(VisualMarkers.OnPostRender)

