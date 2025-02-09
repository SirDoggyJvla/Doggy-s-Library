--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Tools in relation with the world and the map.

]]--
--[[ ================================================ ]]--

---requirements
local DoggyAPI = require "DoggyAPI_module"
local WORLD = DoggyAPI.WORLD
local MODDATA = DoggyAPI.MODDATA
local EVENTS = DoggyAPI.EVENTS

---custom events
require "DoggyEvents/DoggyAPI_LoadNewChunk"
local LoadNewChunk = EVENTS.LoadNewChunk




--[[ ================================================ ]]--
--- LOADING CHUNK ---
--[[ ================================================ ]]--

WORLD.LoadChunk = function(chunk)
    -- verify chunk wasn't already loaded
    local chunkID = tostring(chunk.wx).."x"..tostring(chunk.wy)
    if MODDATA.NewChunks[chunkID] then return end
    MODDATA.NewChunks[chunkID] = true

    -- Trigger the event
    LoadNewChunk:trigger(chunk)
end




--[[ ================================================ ]]--
--- IDENTIFICATION ---
--[[ ================================================ ]]--

---Retrieves the room ID based on its coordinates x,y,z.
---@param roomDef RoomDef
---@return string
WORLD.GetRoomID = function(roomDef)
    return roomDef:getX().."x"..roomDef:getY().."x"..roomDef:getZ()
end

---Used to get a persistent identification of a building.
---@param buildingDef BuildingDef
---@return integer
---@return integer
---@return integer
WORLD.getBuildingID = function(buildingDef)
    -- get a X and Y coordinate
    local x_bID = buildingDef:getX()
    local y_bID = buildingDef:getY()

    -- get a Z coordinate
    local firstRoom = buildingDef:getFirstRoom()
    local z_bID = firstRoom and firstRoom:getZ() or 0

    return x_bID,y_bID,z_bID
end