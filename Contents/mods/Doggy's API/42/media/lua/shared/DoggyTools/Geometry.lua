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
local Booleans = require("DoggyTools/Booleans")
local bools = Booleans.bools
local VisualMarkers = require("DoggyDebugTools/VisualMarkers")

--functions
local math = math
local math_min = math.min
local math_max = math.max




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

	VisualMarkers.AddMarker(x1, y1, 0, "A", 1, 0, 0, 1)
	VisualMarkers.AddMarker(x2, y2, 0, "B", 0, 1, 0, 1)
	-- VisualMarkers.AddMarker(x3, y3, 0, "C", 1, 1, 0, 1, 0)
	-- VisualMarkers.AddMarker(x4, y4, 0, "D", 1, 0, 1, 1, 10)

	local denom = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3)
	if denom == 0 then
		return false -- lines are parallel or coincident
	end

	local Px = ( (x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4) )/denom
	local Py = ( (x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4) )/denom

	-- Check if P_x, P_y lies between pointC and pointD
	local minX, maxX = math_min(x3, x4), math_max(x3, x4)
	local minY, maxY = math_min(y3, y4), math_max(y3, y4)

    -- Add error margin and consider if segment is not axis-aligned
	if minX ~= maxX then
		minX = minX - errorMargin
		maxX = maxX + errorMargin
	end
	if minY ~= maxY then
		minY = minY - errorMargin
		maxY = maxY + errorMargin
	end

	-- VisualMarkers.AddMarker(minX, minY, 0, "minX", 1, 0, 0, 1, 40)
	-- VisualMarkers.AddMarker(maxX, minY, 0, "maxX", 1, 0, 0, 1, 30)

    -- Verify the two segments intersect
	if Px < minX or Px > maxX or Py < minY or Py > maxY then
		return false -- intersection point is not within the segment
	end

	-- VisualMarkers.AddMarker(Px, Py, 0, "X", 1, 0, 1, 1, 10)

	return {x=Px,y=Py}
end



--[[ ================================================ ]]--
--- OBJECT GEOMETRIES ---
--[[ ================================================ ]]--

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
    ["WindowN"] = {
		{1,0,y_offset = 0},
	},
	["WindowW"] = {
		{0,-1,y_offset = 1},
	},
    ["DoorN"] = {
		{1,0,y_offset = 0},
	},
	["DoorW"] = {
		{0,-1,y_offset = 1},
	},
}


Geometry.GetObjectSegments = function(object)
    local canSeeThrough, objectProperty = WorldTools.CanSeeThrough(object)
    if canSeeThrough then return end -- skip as object won't block ray

    return Geometry._PropertyToSegments[objectProperty]
end


return Geometry