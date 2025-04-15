--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Various tools used for geometry.

]]--
--[[ ================================================ ]]--

---requirements
local Geometry = {}

--tools
local WorldTools = require("DoggyTools/WorldTools")

--functions
local math = math




---Used to check for the intersection of segment [AB] and segment [CD] [1]. The intersection point is called (Px, Py).
---
---[1]: https://en.wikipedia.org/wiki/Line–line_intersection
---@param pointA table -- Origin point
---@param pointB table -- Far point
---@param pointC table -- First point of the line to check intersection with
---@param pointD table -- Second point of the line to check intersection with
---@param errorMargin number|nil -- Error margin for the segment [CD] on both tips
---@return table|false -- Intersection point or false if no intersection was found
Geometry.FindIntersectPoint = function(pointA, pointB, pointC, pointD, errorMargin)
    errorMargin = errorMargin or 0 -- default
	local x1, y1 = pointA.x, pointA.y
	local x2, y2 = pointB.x, pointB.y
	local x3, y3 = pointC.x, pointC.y
	local x4, y4 = pointD.x, pointD.y

	-- addMarker(x1, y1, 0, "A", 1, 0, 0, 1)
	-- addMarker(x2, y2, 0, "B", 0, 1, 0, 1)
	-- addMarker(x3, y3, 0, "C", 1, 1, 0, 1, 0)
	-- addMarker(x4, y4, 0, "D", 1, 0, 1, 1, 10)

	local denom = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3)
	if denom == 0 then
		return false -- lines are parallel or coincident
	end

	local Px = ( (x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4) )/denom
	local Py = ( (x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4) )/denom

	-- errorMargin = 0.05

	-- Check if P_x, P_y lies between pointC and pointD
	local minX, maxX = math.min(x3, x4), math.max(x3, x4)
	local minY, maxY = math.min(y3, y4), math.max(y3, y4)

    -- Add error margin and consider if segment is not axis-aligned
	if minX ~= maxX then
		minX = minX - errorMargin
		maxX = maxX + errorMargin
	end
	if minY ~= maxY then
		minY = minY - errorMargin
		maxY = maxY + errorMargin
	end

	-- addMarker(minX, minY, 0, "minX", 1, 0, 0, 1, 40)
	-- addMarker(maxX, minY, 0, "maxX", 1, 0, 0, 1, 30)

    -- Verify the two segments intersect
	if Px < minX or Px > maxX or Py < minY or Py > maxY then
		return false -- intersection point is not within the segment
	end

	-- addMarker(Px, Py, 0, "X", 1, 0, 1, 1, 10)

	return {x=Px,y=Py}
end



--[[ ================================================ ]]--
--- OBJECT GEOMETRIES ---
--[[ ================================================ ]]--

FindersTools.GetWallType = function(spriteProperties)
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

Geometry._PropertyToSegments = {
	["WallN"] = {
		{1,0,y_offset = 0},
	},
	["WallW"] = {
		{0,-1,y_offset = 1},
	},
	["WallNW"] = {
		{1,0,y_offset = 0},
		{0,-1,y_offset = 1},
	},
}


Geometry.GetObjectSegments = function(object)
    local canSeeThrough, objectProperty = WorldTools.CanSeeThrough(object)
    if canSeeThrough then return end -- skip as object won't block ray

    return Geometry._PropertyToSegments[objectProperty]
end

Geometry.GetObjectSegments = function(object)
	local sprite = object:getSprite()
	if not sprite then return end

	local properties = sprite:getProperties()
	if not properties then return end

	local wallType = FindersTools.GetWallType(properties)
	if not wallType then return end

	local structureType = FindersTools._ObjectTypeToStructureType[wallType]

	local segments = {
		wallType=wallType,
		structureType = structureType,
	}

	if structureType == "Wall" then
		local defaultProperties = FindersTools._DefaultProperties[wallType]
		for i = 1, #defaultProperties do
			table.insert(segments, defaultProperties[i])
		end
	elseif structureType == "Door" then
		local curtains = object:HasCurtains()
		local canSeeThrough = object:IsOpen() or properties:Is("doorTrans") and not curtains or curtains and curtains:isCurtainOpen() or false

		if not canSeeThrough then
			local wallType = object:getNorth() and "WallN" or "WallW"
			local defaultProperties = Geometry._DefaultProperties[wallType]
			for i = 1, #defaultProperties do
				table.insert(segments, defaultProperties[i])
			end
		end
	elseif structureType == "Window" then
		local canSeeThrough

		local barricade1 = object:getBarricadeOnSameSquare()
		local barricade2 = object:getBarricadeOnOppositeSquare()

		if barricade1 and barricade1:isBlockVision() or barricade2 and barricade2:isBlockVision() then
			canSeeThrough = false
		else
			local curtains = object:HasCurtains()
			canSeeThrough = not curtains or curtains:IsOpen()
		end

		if not canSeeThrough then
			local wallType = object:getNorth() and "WallN" or "WallW"
			local defaultProperties = FindersTools._DefaultProperties[wallType]
			for i = 1, #defaultProperties do
				table.insert(segments, defaultProperties[i])
			end
		end
	end

	return segments
end



return Geometry