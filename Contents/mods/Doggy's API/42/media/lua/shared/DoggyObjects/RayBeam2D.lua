--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

2D ray beam to check for intersections with objects in the world.

]]--
--[[ ================================================ ]]--

---requirements
local RayBeam2D = ISBaseObject:derive("RayBeam2D")

--tools
local Geometry = require("DoggyTools/Geometry")
local WorldTools = require("DoggyTools/WorldTools")
local VisualMarkers = require "DoggyDebugTools/VisualMarkers"

--functions
local getSquare = getSquare
local math = math
local math_sqrt = math.sqrt



---Table of object type to their respective segments.
RayBeam2D.propertyToSegments = {
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


---Verifies if the objects can be seen through and if not verify if the beam intersects with the object.
---@param objects any
---@return IsoObject|nil closestObject
---@return table|nil objectSegment
---@return table|nil
function RayBeam2D:_checkForIntersectedObject(objects)
	local closestObject, objectSegment, finalPoint
	local _shortestDistance = 9999999

    -- retrieve infos
    local _ignoredObjects = self.ignoredObjects
    local startPoint = self.startPoint
    local farPoint = self.farPoint
    local propertyToSegments = self.propertyToSegments

    -- Check for each objects
	for i = 0, objects:size() - 1 do repeat
		local object = objects:get(i)
		if _ignoredObjects and _ignoredObjects[object] then break end

        local segments = WorldTools.GetSegments(object,propertyToSegments)
        if not segments then
            break
        end

        local z = object:getZ()

        -- check each segments of the object
		for j = 1, #segments do repeat
			local segment = segments[j]

            -- retrieve object points
            local x, y = object:getX(), object:getY()
            local x_offset, y_offset = segment.x_offset or 0, segment.y_offset or 0
            x, y = x + x_offset, y + y_offset
			local objectPoint1 = {x = x, y = y, z = z}
			local objectPoint2 = {x = x + segment[1], y = y + segment[2], z = z}

            -- verify for intersection of beam with object segment
			local intersectionPoint = Geometry.FindIntersectPoint(startPoint, farPoint, objectPoint1, objectPoint2, 0.05)
            if not intersectionPoint then break end

            -- verify intersection point is closer to the start point than the previously found ones
            local distance = math_sqrt((intersectionPoint.x - startPoint.x)^2 + (intersectionPoint.y - startPoint.y)^2)
            if distance < _shortestDistance then
                _shortestDistance = distance

                finalPoint = intersectionPoint
                objectSegment = segment
                closestObject = object
            end
		until true end
	until true end

	return closestObject, objectSegment, finalPoint
end

---Shoots the current ray beam and returns the squares it intersects with. 
---
---The ray beam is casted from the `startPoint` in the direction of the `vectorBeam`, slowly checking coordinates by moving by `deltaLength` until either an object intersects the beam or it reaches its maximum length.
---@return table squares
function RayBeam2D:castRay()
    local x1, y1, z = self.x1, self.y1, self.z
    local deltaVector = self.deltaVector
    local beamLength = self.beamLength
    local deltaLength = self.deltaLength

    -- copy coordinates which will get increased each steps
    local x2, y2 = x1, y1

    -- list of squares in the ray path
    local squares = {}

    -- local intersectObject, objectVector, finalPoint -- variables to check
    local previousSquare -- used to store square on previous position

    while beamLength > 0 do repeat
        local square = getSquare(x2, y2, z)
        if not square then break end -- square is nil so skip to next coordinates
        if squares[square] then break end -- square was already identified as intersect wall so don't check it anymore

        -- check first type of objects
        local objects = square:getObjects()
        local intersectObject, objectSegment, finalPoint = self:_checkForIntersectedObject(objects)

        if not intersectObject then
            -- check second type of objects
            local objects = square:getSpecialObjects()
            intersectObject, objectSegment, finalPoint = self:_checkForIntersectedObject(objects)
        end

        -- verify that the ray intersected an object
        if intersectObject then
            ---@cast objectSegment table
            ---@cast finalPoint table

            local objectVector = Vector2.new(objectSegment[1], objectSegment[2])

            -- verifies the direction the ray is coming from and if from the top then it needs to use the previous square
            local angle = objectVector:getDirection() - self.beamDirection
            local intersectionSquare = angle < 0 and previousSquare or square

            -- local startPoint = self.startPoint
            -- finalPoint.z = startPoint.z
            -- VisualMarkers.AddLine(startPoint, finalPoint, 1, 0, 1, 0.05)
            -- local minX, minY = finalPoint.minX, finalPoint.minY
            -- local maxX, maxY = finalPoint.maxX, finalPoint.maxY
            -- VisualMarkers.AddLine({x=minX,y=minY,z=0}, {x=maxX,y=maxY,z=0}, 1, 1, 0, 0.2)

            squares[intersectionSquare] = intersectObject
            -- VisualMarkers.AddHighlightSquare(intersectionSquare, {r = 1, g = 1, b = 0, a = 0.5}, 20)
            return squares
        end

        -- else this is a normal square without any object blocking the ray
        squares[square] = true
        -- VisualMarkers.AddHighlightSquare(square, {r = 1, g = 0, b = 0, a = 0.5}, 10)
        previousSquare = previousSquare ~= square and square or previousSquare
        until true

        -- update next ray position
        x1, y1 = x2, y2
		x2 = x1 + deltaVector:getX()
		y2 = y1 + deltaVector:getY()
		beamLength = beamLength - deltaLength
    end

    return squares
end

---Used to update the beam and apply the changes.
---@param vectorBeam Vector2
function RayBeam2D:setBeam(vectorBeam)
    self.vectorBeam = vectorBeam
    self:initialize()
    -- VisualMarkers.ResetLines()
end

---Initialize the ray beam with the current parameters.
function RayBeam2D:initialize()
    local vectorBeam = self.vectorBeam
    local startPoint = self.startPoint

    -- initialize vectors and values used in casting the ray
    self.beamLength = vectorBeam:getLength()
    self.beamDirection = vectorBeam:getDirection()
    local x1, y1, z = startPoint.x, startPoint.y, startPoint.z
    self.x1, self.y1, self.z = x1, y1, z
    self.farPoint = {x = x1 + vectorBeam:getX(), y = y1 + vectorBeam:getY(), z = z}
    self.deltaVector = vectorBeam:clone():setLength(self.deltaLength)
end

---Create a new RayBeam2D instance.
---@param startPoint table
---@param vectorBeam Vector2
---@param _ignoredObjects? table|nil
---@param _deltaLength? number|nil
---@return table
function RayBeam2D:new(startPoint, vectorBeam, _ignoredObjects, _deltaLength)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- parameters
    o.deltaLength = _deltaLength or 0.01
    o.startPoint = startPoint
    o.vectorBeam = vectorBeam
    o.ignoredObjects = _ignoredObjects or {}

    -- initialize vectors and values used in casting the ray
    o:initialize()

    return o
end



return RayBeam2D