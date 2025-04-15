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



--[[ ================================================ ]]--
--- SPRITES ---
--[[ ================================================ ]]--

WorldTools._PropertyToStructureType = {
	["WallN"] = "Wall",
	["WallW"] = "Wall",
	["WallNW"] = "Wall",
	["DoorSound"] = "Door",
	["WindowN"] = "Window",
	["WindowW"] = "Window",
}

WorldTools.GetObjectType = function(spriteProperties)
	if spriteProperties:Is("WallN") then
		return "WallN"
	elseif spriteProperties:Is("WallW") then
		return "WallW"
	elseif spriteProperties:Is("WallNW") then
		return "WallNW"
	elseif spriteProperties:Is("DoorSound") then
		return "DoorSound"
	elseif spriteProperties:Is("WindowN") then
		return "WindowN"
	elseif spriteProperties:Is("WindowW") then
		return "WindowW"
	end

	return false
end

---
---@param object IsoObject
---@return boolean
---@return string|nil
WorldTools.CanSeeThrough = function(object)
	local sprite = object:getSprite()
	if not sprite then return true end -- needs to be true as object is not valid

    local properties = sprite:getProperties()
	if not properties then return true end -- needs to be true as object is not valid

    local objectProperty = WorldTools.GetObjectType(properties)
    if not objectProperty then return true end -- needs to be true as object is not valid

    local structureType = WorldTools._PropertyToStructureType[objectProperty]
    if not structureType then return false, objectProperty end

    if structureType == "Wall" then
        return false, objectProperty
    elseif structureType == "Window" then
        ---@cast object IsoWindow

        -- check for barricades
		local barricade1 = object:getBarricadeOnSameSquare()
		local barricade2 = object:getBarricadeOnOppositeSquare()
		if barricade1 and barricade1:isBlockVision() or barricade2 and barricade2:isBlockVision() then
			return false, objectProperty
		end

        -- check for curtains
        local curtains = object:HasCurtains() ---@as IsoCurtain
        return not curtains or curtains:IsOpen(), objectProperty
    elseif structureType == "Door" then
        ---@cast object IsoDoor

        -- check open
        if object:IsOpen() then return true end

        -- check for barricades
		local barricade1 = object:getBarricadeOnSameSquare()
		local barricade2 = object:getBarricadeOnOppositeSquare()
		if barricade1 and barricade1:isBlockVision()
        or barricade2 and barricade2:isBlockVision() then
			return false, objectProperty
		end

        if properties:Is("doorTrans") then
            -- check for curtains
            local curtains = object:HasCurtains() ---@as IsoCurtain
            return not curtains or curtains:isCurtainOpen(), objectProperty -- TODO: might be wrong for IsoThumpable
        end

		return false, objectProperty
    end

    return false, objectProperty
end



return WorldTools