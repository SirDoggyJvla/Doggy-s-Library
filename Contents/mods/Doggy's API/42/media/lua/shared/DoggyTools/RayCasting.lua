--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Various tools used to check for stuff.

]]--
--[[ ================================================ ]]--

---requirements
local RayCasting = {}

--tools
local Geometry = require("DoggyTools/Geometry")
local WorldTools = require("DoggyTools/WorldTools")

--functions
local getSquare = getSquare
local math = math




--[[ ================================================ ]]--
--- RAY CASTING ---
--[[ ================================================ ]]--


-- local addMarker = function(x,y,z,text,r,g,b,a,y_offset)
-- 	text = tostring(text)

-- 	local nametag = TextDrawObject.new()
-- 	nametag:ReadString(UIFont.Small, text, -1)

-- 	table.insert(UniqueMarker, {
-- 		x = x,
-- 		y = y,
-- 		z = z,
-- 		nametag = nametag,
-- 		r = r or 1,
-- 		g = g or 0,
-- 		b = b or 0,
-- 		a = a or 1,
-- 		y_offset = y_offset or 0,
-- 	})
-- end

---Casts a 2D ray from a starting point in a specified direction and returns the squares it intersects with until it hits an object.
---@param startPoint table -- Starting point of the ray (x, y, z)
---@param vectorBeam Vector2 -- Direction and length vector of the ray
---@param _ignoredObjects table|nil -- List of objects to ignore during the ray casting
RayCasting.CastRay2D = function(startPoint, vectorBeam, _ignoredObjects)
    -- initialize vectors and values used in casting the ray
    local beamLength = vectorBeam:getLength()
    local x1, y1, z = startPoint.x, startPoint.y, startPoint.z
    local farPoint = {x = x1 + vectorBeam:getX(), y = y1 + vectorBeam:getY()}
    local deltaLength = 0.01
    local deltaVector = vectorBeam:clone():setLength(deltaLength)

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
        intersectObject, wallVector = RayCasting._CheckForIntersectedObject(objects, startPoint, farPoint, _ignoredObjects)

        if not intersectObject or not wallVector then
            -- check second type of objects
            local objects = square:getSpecialObjects()
            intersectObject, wallVector = RayCasting._CheckForIntersectedObject(objects, startPoint, farPoint, _ignoredObjects)
        end

        -- verify that the ray intersected and object
        if intersectObject and wallVector then
            local angle = wallVector:getDirection() - vectorBeam:getDirection()
            local wallSquare = angle < 0 and previousSquare or square

            -- local wallSquare = wallVector:angleTo(vectorBeam) >= -math.pi/2 and square or previousSquare
            squares[wallSquare] = intersectObject
            return squares
        end

        -- else this is a normal square without any object blocking the ray
        squares[square] = true
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





RayCasting._CheckForIntersectedObject = function(objects,startPoint,farPoint,_ignoredObjects)
	local closestWall, wallSegment
	local _shortestDistance = 9999999

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
            local distance = math.sqrt((intersectionPoint.x - startPoint.x)^2 + (intersectionPoint.y - startPoint.y)^2)
            if distance < _shortestDistance then
                _shortestDistance = distance

                wallSegment = segment
                closestWall = object
            end
		until true end
	until true end

	return closestWall, wallSegment and Vector2.new(wallSegment[1], wallSegment[2])
end



return RayCasting