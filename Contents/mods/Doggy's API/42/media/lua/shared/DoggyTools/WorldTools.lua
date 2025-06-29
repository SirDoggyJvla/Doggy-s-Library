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
---@return integer
---@return integer
---@return integer
WorldTools.getBuildingInfo = function(buildingDef)
    -- get a X and Y coordinate
    local x_bID = buildingDef:getX()
    local y_bID = buildingDef:getY()

    -- get a Z coordinate
    local firstRoom = buildingDef:getFirstRoom()
    local z_bID = firstRoom and firstRoom:getZ() or 0

    return x_bID,y_bID,z_bID
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

---Checks if object is a windows.
---@param object any
---@return boolean
WorldTools.IsWindow = function(object)
    if instanceof(object, "IsoWindow") then
        return true
    elseif instanceof(object, "IsoThumpable") then
        return object:isWindow()
    end
    return false
end

---Checks if object is a door.
---@param object any
---@return boolean
WorldTools.IsDoor = function(object)
    if instanceof(object,"IsoDoor") then
        return true
    elseif instanceof(object,"IsoThumpable") then
        return object:isDoor()
    end
    return false
end

---Checks if object is a window or a door.
---@param object any
---@return boolean
WorldTools.IsWindowOrDoor = function(object)
    return WorldTools.IsWindow(object) or WorldTools.IsDoor(object)
end

---Checks if the square has a window or a door.
---@param square IsoGridSquare
---@return boolean, IsoObject|nil
WorldTools.HasWindowOrDoor = function(square)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if WorldTools.IsWindow(object) or WorldTools.IsDoor(object) then
            return true, object
        end
    end
    return false
end


--[[ ================================================ ]]--
--- TILE TRANSPARENCY ---
--[[ ================================================ ]]--

---Checks if the door can be seen through.
---
--- 1. Checks if the door is open
--- 2. Checks for barricades
--- 3. Checks if door is transparent and has closed curtains
---@param door IsoDoor
---@param spriteProperties PropertyContainer
---@return boolean
WorldTools.CanSeeThroughDoor = function(door,spriteProperties)
    -- check open
    if door:IsOpen() then return true end

    -- check for barricades
    local barricade1 = door:getBarricadeOnSameSquare()
    local barricade2 = door:getBarricadeOnOppositeSquare()
    if barricade1 and barricade1:isBlockVision()
    or barricade2 and barricade2:isBlockVision() then
        return false
    end

    if spriteProperties:Is("doorTrans") then
        -- check for curtains
        local curtains = door:HasCurtains() ---@as IsoCurtain
        return not curtains or curtains:isCurtainOpen() -- TODO: might be wrong for IsoThumpable
    end

    return false
end

---Checks if the window can be seen through.
---
--- 1. Checks for barricades
--- 2. Checks for closed curtains
---@param window IsoWindow
---@param spriteProperties PropertyContainer
---@return boolean
WorldTools.CanSeeThroughWindow = function(window,spriteProperties)
    -- check for barricades
    local barricade1 = window:getBarricadeOnSameSquare()
    local barricade2 = window:getBarricadeOnOppositeSquare()
    if barricade1 and barricade1:isBlockVision() or barricade2 and barricade2:isBlockVision() then
        return false
    end

    -- check for curtains
    local curtains = window:HasCurtains() ---@as IsoCurtain
    return not curtains or curtains:IsOpen()
end


--[[ ================================================ ]]--
--- SPRITES PROPERTIES ---
--[[ ================================================ ]]--

WorldTools.IsoObjectType = {
    -- ["curtainE"] = "curtainE",
    -- ["curtainN"] = "curtainN",
    -- ["curtainS"] = "curtainS",
    -- ["curtainW"] = "curtainW",
    -- ["doorFrN"] = "doorFrN",
    -- ["doorFrW"] = "doorFrW",
    -- ["doorN"] = "doorN",
    -- ["doorW"] = "doorW",
    -- ["isMoveAbleObject"] = "isMoveAbleObject",
    -- ["jukebox"] = "jukebox",
    -- ["lightswitch"] = "lightswitch",
    -- ["MAX"] = "MAX",
    -- ["normal"] = "normal",
    -- ["radio"] = "radio",
    ["stairsBN"] = "stairsBN",
    ["stairsBW"] = "stairsBW",
    ["stairsMN"] = "stairsMN",
    ["stairsMW"] = "stairsMW",
    ["stairsTN"] = "stairsTN",
    ["stairsTW"] = "stairsTW",
    ["tree"] = "tree",
    -- ["UNUSED10"] = "UNUSED10",
    -- ["UNUSED24"] = "UNUSED24",
    -- ["UNUSED9"] = "UNUSED9",
    -- ["wall"] = "wall",
    -- ["WestRoofB"] = "WestRoofB",
    -- ["WestRoofM"] = "WestRoofM",
    -- ["WestRoofT"] = "WestRoofT",
    -- ["windowFN"] = "windowFN",
    -- ["windowFW"] = "windowFW",
}

WorldTools._PropertyToStructureType = {
	["WallN"] = "Wall",
	["WallW"] = "Wall",
	["WallNW"] = "Wall",
	["DoorSound"] = "Door",
	["WindowN"] = "Window",
	["WindowW"] = "Window",
    ["stairsBN"] = "Stairs",
    ["stairsBW"] = "Stairs",
    ["stairsMN"] = "Stairs",
    ["stairsMW"] = "Stairs",
    ["stairsTN"] = "Stairs",
    ["stairsTW"] = "Stairs",
}

WorldTools._SpritePropertyCheck = {
    "WallN",
    "WallW",
    "WallNW",
    "DoorSound",
    "WindowN",
    "WindowW",
    "stairsBN",
    "stairsBW",
    "stairsMN",
    "stairsMW",
    "stairsTN",
    "stairsTW",
}

---Retrieve property identification.
---@param object IsoObject
---@param spriteProperties PropertyContainer
---@return string|nil objectProperty
---@return string|nil objectType
WorldTools.GetObjectType = function(object, spriteProperties)
    ---@type IsoObjectType|string just bcs Lua typing shows a warning when there shouldn't be one
    local _type = object:getType()
    _type = tostring(_type)

    for i = 1, #WorldTools._SpritePropertyCheck do
        local property = WorldTools._SpritePropertyCheck[i]
        if spriteProperties:Is(property) or property == _type then
            return property, WorldTools._PropertyToStructureType[property]
        end
    end

	return nil, nil
end


--[[ ================================================ ]]--
--- OBJECT GEOMETRY ---
--[[ ================================================ ]]--

---Table of object types and custom functions that are ran when accessing the object segments. If one of the functions returns true, the object is invalid.
WorldTools.ObjectsSegmentChecks = {
    ["Door"] = {
        WorldTools.CanSeeThroughDoor,
    },
    ["Window"] = {
        WorldTools.CanSeeThroughWindow,
    },
}





---Retrieve segments that define the 2D flat geometry of the object.
---@param object IsoObject|IsoDoor|IsoWindow|IsoThumpable
---@param propertyToSegments table
---@return table|nil
WorldTools.GetSegments = function(object,propertyToSegments)
    local sprite = object:getSprite()
    if not sprite then return nil end

    local spriteProperties = sprite:getProperties()
    if not spriteProperties then return nil end

    local objectProperty, objectType = WorldTools.GetObjectType(object, spriteProperties)
    if not objectProperty then return nil end

    local behaviors = WorldTools.ObjectsSegmentChecks[objectType]
    if behaviors then
        for i = 1, #behaviors do
            local behavior = behaviors[i]
            if behavior(object, spriteProperties) then -- Lua screams at object bcs type is not updated based on the objectType, ignore it
                return nil
            end
        end
    end

	return objectProperty and propertyToSegments[objectProperty] or nil
end



return WorldTools