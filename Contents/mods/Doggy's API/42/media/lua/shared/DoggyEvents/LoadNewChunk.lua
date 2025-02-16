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

---CACHE
-- create new event
local LuaEvent = require "Starlit/LuaEvent"
local LoadNewChunk = {
    Event = LuaEvent.new(),
}

-- mod data
local NewChunks
Events.OnInitGlobalModData.Add(function()
    NewChunks = ModData.getOrCreate("DoggyAPI_AlreadyLoadedChunks")
end)

---Triggers whenever a chunk is loaded and verify it wasn't already loaded. If not, triggers the custom event.
---@param chunk IsoChunk
LoadNewChunk.LoadChunk = function(chunk)
    -- verify chunk wasn't already loaded
    local chunkID = tostring(chunk.wx).."x"..tostring(chunk.wy) -- chunk ID
    if NewChunks[chunkID] then return end
    NewChunks[chunkID] = true

    -- Trigger the event
    LoadNewChunk.Event:trigger(chunk)
end

return LoadNewChunk