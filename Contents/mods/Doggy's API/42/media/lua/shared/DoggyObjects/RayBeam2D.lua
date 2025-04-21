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
-- local VisualMarkers = require "DoggyDebugTools/VisualMarkers"

--functions
local getSquare = getSquare
local math = math
local math_sqrt = math.sqrt


function RayBeam2D:_checkForIntersectedObject(objects)
	local closestWall, wallSegment
	local _shortestDistance = 9999999

    local _ignoredObjects = self.ignoredObjects
    local startPoint = self.startPoint
    local farPoint = self.farPoint

    -- local finalPoint
    -- Check for each objects
	for i = 0, objects:size() - 1 do repeat
		local object = objects:get(i)
		if _ignoredObjects and _ignoredObjects[object] then break end

        local canSeeThrough, objectProperty = WorldTools.CanSeeThrough(object)
        if canSeeThrough then break end -- skip as object won't block ray

        local segments = Geometry._PropertyToSegments[objectProperty]
        if not segments then break end

        -- check each segments of the object
		for j = 1, #segments do repeat
			local segment = segments[j]

            -- retrieve object points
			local objectPoint1 = {x = object:getX(), y = object:getY() + segment.y_offset}
			local objectPoint2 = {x = object:getX() + segment[1], y = object:getY() + segment[2] + segment.y_offset}

			local intersectionPoint = Geometry.FindIntersectPoint(startPoint, farPoint, objectPoint1, objectPoint2, 0.05)
            if not intersectionPoint then break end

            -- verify intersection point is closer to the start point
            local distance = math_sqrt((intersectionPoint.x - startPoint.x)^2 + (intersectionPoint.y - startPoint.y)^2)
            if distance < _shortestDistance then
                _shortestDistance = distance

                -- finalPoint = intersectionPoint
                wallSegment = segment
                closestWall = object
            end
		until true end
	until true end

    -- if finalPoint then
    --     VisualMarkers.AddMarker(finalPoint.x, finalPoint.y, closestWall:getZ(), "X", 1, 0, 1, 1, 10)
    -- end

	return closestWall, wallSegment and Vector2.new(wallSegment[1], wallSegment[2])
end


function RayBeam2D:castRay()
    local x1, y1, z = self.x1, self.y1, self.z
    local deltaVector = self.deltaVector
    local beamLength = self.beamLength
    local deltaLength = 0.01

    -- copy coordinates which will get increased each steps
    local x2, y2 = x1, y1

    -- list of squares in the ray path
    local squares = {}

    local intersectObject, wallVector -- variables to check
    local previousSquare -- used to store square on previous position

    while beamLength > 0 and not intersectObject do repeat
        local square = getSquare(x2, y2, z)
        if not square then break end -- square is nil so skip to next coordinates
        if squares[square] then break end -- square was already identified as intersect wall so don't check it anymore

        -- check first type of objects
        local objects = square:getObjects()
        intersectObject, wallVector = self:_checkForIntersectedObject(objects)

        if not intersectObject or not wallVector then
            -- check second type of objects
            local objects = square:getSpecialObjects()
            intersectObject, wallVector = self:_checkForIntersectedObject(objects)
        end

        -- verify that the ray intersected and object
        if intersectObject and wallVector then
            local angle = wallVector:getDirection() - self.beamDirection
            local wallSquare = angle < 0 and previousSquare or square

            squares[wallSquare] = intersectObject
            -- VisualMarkers.AddHighlightSquare(wallSquare, {r = 1, g = 1, b = 0, a = 0.5}, 20)
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

function RayBeam2D:setBeam(vectorBeam)
    self.vectorBeam = vectorBeam
    self:initialize()
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
    self.farPoint = {x = x1 + vectorBeam:getX(), y = y1 + vectorBeam:getY()}
    self.deltaVector = vectorBeam:clone():setLength(self.deltaLength)
end

function RayBeam2D:new(startPoint, vectorBeam, _ignoredObjects, _deltaLength)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    -- parameters
    self.deltaLength = _deltaLength or 0.01
    o.startPoint = startPoint
    o.vectorBeam = vectorBeam
    o.ignoredObjects = _ignoredObjects or {}

    -- initialize vectors and values used in casting the ray
    o:initialize()

    return o
end



return RayBeam2D