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
local WorldTools = {}


--[[ ================================================ ]]--
--- IDENTIFICATION ---
--[[ ================================================ ]]--

---Retrieves the room ID based on its coordinates x,y,z.
---@param roomDef RoomDef
---@return string
WorldTools.GetRoomID = function(roomDef)
    return roomDef:getX().."x"..roomDef:getY().."x"..roomDef:getZ()
end

---Used to get a persistent identification coordinates of a building.
---@param buildingDef BuildingDef
---@return [integer, integer, integer]
WorldTools.getBuildingInfo = function(buildingDef)
    -- get a X and Y coordinate
    local x_bID = buildingDef:getX()
    local y_bID = buildingDef:getY()

    -- get a Z coordinate
    local firstRoom = buildingDef:getFirstRoom()
    local z_bID = firstRoom and firstRoom:getZ() or 0

    return {x=x_bID,y=y_bID,z=z_bID}
end

---Used to get a persistent identification of a building.
---@param buildingDef BuildingDef
---@return string
WorldTools.getBuildingID = function(buildingDef)
    -- get a X and Y coordinate
    local x_bID = buildingDef:getX()
    local y_bID = buildingDef:getY()

    -- get a Z coordinate
    local firstRoom = buildingDef:getFirstRoom()
    local z_bID = firstRoom and firstRoom:getZ() or 0

    return x_bID.."x"..y_bID.."x"..z_bID
end

return WorldTools