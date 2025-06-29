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
local VisualMarkers = require("DoggyDebugTools/VisualMarkers")

--functions
local math = math
local math_min = math.min
local math_max = math.max



---Checks if the point (Px, Py) is within the segment [x1, y1] to [x2, y2]. `errorMargin` is used to expand the segment's bounding box to reduce error on segment to segment boundaries.
---@param Px any
---@param Py any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param errorMargin any
---@return boolean
---@return any
---@return any
---@return any
---@return any
Geometry.IsPointInSegment = function(Px, Py, x1, y1, x2, y2, errorMargin)
	local minX, maxX = math_min(x1, x2), math_max(x1, x2)
	local minY, maxY = math_min(y1, y2), math_max(y1, y2)

	-- Add error margin and consider if segment is not axis-aligned
	if minX ~= maxX then
		minX = minX - errorMargin
		maxX = maxX + errorMargin
	end
	if minY ~= maxY then
		minY = minY - errorMargin
		maxY = maxY + errorMargin
	end

	-- VisualMarkers.AddLine({x=minX,y=minY,z=0}, {x=maxX,y=maxY,z=0}, 0.5, 0, 1, 0.05)
	return Px >= minX and Px <= maxX and Py >= minY and Py <= maxY, minX, maxX, minY, maxY
end



---Used to check for the intersection of segment [AB] and segment [CD] (see [1]). The intersection point is called (Px, Py).
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

	-- VisualMarkers.AddLine(pointA, pointB, 1, 0, 0, 0.05)
	-- VisualMarkers.AddLine(pointC, pointD, 1, 1, 0, 0.05)

	local denom = (x2 - x1) * (y4 - y3) - (y2 - y1) * (x4 - x3)
	if denom == 0 then
		return false -- lines are parallel or coincident
	end

	local Px = ( (x1*y2 - y1*x2)*(x3-x4) - (x1-x2)*(x3*y4 - y3*x4) )/denom
	local Py = ( (x1*y2 - y1*x2)*(y3-y4) - (y1-y2)*(x3*y4 - y3*x4) )/denom

	local inSegmentCD, minX, maxX, minY, maxY = Geometry.IsPointInSegment(Px, Py, x3, y3, x4, y4, errorMargin)

	if not inSegmentCD or not Geometry.IsPointInSegment(Px, Py, x1, y1, x2, y2, 0) then
		return false -- intersection point is not within one or both segments
	end

	-- VisualMarkers.AddLine({x=minX,y=minY,z=0}, {x=maxX,y=maxY,z=0}, 0.5, 0, 1, 0.05)
	-- VisualMarkers.AddLine(pointA, {x=Px,y=Py,z=0}, 1, 0, 1, 0.05)

	return {x=Px,y=Py,minX=minX,maxX=maxX,minY=minY,maxY=maxY}
end

return Geometry