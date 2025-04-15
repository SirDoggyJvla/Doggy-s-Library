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
local FindersTools = {}

--tools
local Geometry = require("DoggyTools/Geometry")

--functions
local getSquare = getSquare
local table = table
local math = math



--[[ ================================================ ]]--
--- CIRCULAR FINDERS ---
--[[ ================================================ ]]--

---Creates a table of directions to check outward from the center point for a circle of radius `radius`.
---Can be used to check around a point in a circle starting from the center or other circular applications.
---@param radius integer
---@param directions table|nil
---@return any
FindersTools.GetCircleOutwardDirections = function(radius,directions)
	-- create a direction table if doesn't exist already
	directions = directions or table.newarray()

	-- check from 1 to radius
	local uniques = {}
	local squares,x,y,uniqueKey,d
	for r = 1,radius do
		squares = table.newarray()

		-- create coordinates of squares of the circle of radius r
		for theta = 0, math.pi * 2, 0.01 do
			-- Calculate x and y using the parametric form of a circle
			x = round(r * math.cos(theta))
			y = round(r * math.sin(theta))

			-- get distance from center point
			d = ( x*x + y*y )^0.5

			-- verify these coordinates are not used for a direction check (to not have duplicate directions)
			uniqueKey = x..","..y
			if not uniques[uniqueKey] then
				-- add these coordinates in this circle
				uniques[uniqueKey] = true
				table.insert(squares,table.newarray(x,y,d))
			end
		end

		-- store them at this radius value
		table.sort(squares,function(a,b) return a[3] < b[3] end)
		directions[r] = squares
	end

	return directions
end

--- cache in default circle directions radius
FindersTools.CIRCULAR_OUTWARD_DIRECTIONS = FindersTools.GetCircleOutwardDirections(75)



---Determines the closest square and its distance to the start points based on a validation function `isValid`.
---
---Checks within a `radius` and in circle starting from the start points and going outward.
---Checks every floors within `min_h` and `max_h`.
---@param startX number
---@param startY number
---@param min_radius integer
---@param max_radius integer
---@param min_h integer
---@param max_h integer
---@param directions table
---@param isValid function
---@return IsoGridSquare|nil
---@return number|nil
FindersTools.FindNearestValidSquare = function(startX, startY , min_radius, max_radius, min_h, max_h, directions, isValid)
	-- iterate through every directions, starting at the nearest circle
	for r = min_radius,max_radius do
		-- retrieve directions
		local direction = directions[r]
		if direction then
			-- iterate through every directions pointing to the circle coordinates
			for i = 1,#direction do
				-- retrieve the direction coordinates
				local increase = direction[i]
				local x_dir = increase[1]
				local y_dir = increase[2]

				-- calculates point to check coordinates
				local x = startX + x_dir
				local y = startY + y_dir

				-- check within every floors
				for h = min_h,max_h do
					-- get square
					local square = getSquare(x,y,h)

					-- verify square is valid
					if square and isValid(square) then
						return square,increase[3]
					end
				end
			end
		end
	end

	-- no squares found
	return nil, nil
end



-- Retrieves zombies upstairs and adds them to a table.
---@param player IsoPlayer
---@param coordinates table 
---@return table
FindersTools.getZombiesInRadius = function(player,coordinates,radius)
    -- get zombieList
    local zombieList = player:getCell():getZombieList()

    -- coordinates of square top of stairs
    local x = coordinates.x
    local y = coordinates.y
    local z = coordinates.z

    -- Get zombies top of the stairs in the Radius
    radius = radius  + 0.5
    local zombies = {}
    for i = 0, zombieList:size() - 1 do
        -- get zombie
        local zombie = zombieList:get(i)

        -- get zombie coordinates
        local z_z = zombie:getZ()

        -- check zombie is top floor or in stairs of top floor
        if z_z - z_z%1 == z then
            -- get distance
            local d = math.sqrt( (zombie:getX() - x)^2 + (zombie:getY() - y)^2 )
            -- check if in radius of square of top stairs
            if d <= radius then
                -- add zombie to the table
                table.insert(zombies,zombie)
            end
        end
    end

    return zombies
end




--[[ ================================================ ]]--
--- RAY CASTING ---
--[[ ================================================ ]]--


local addMarker = function(x,y,z,text,r,g,b,a,y_offset)
	text = tostring(text)

	local nametag = TextDrawObject.new()
	nametag:ReadString(UIFont.Small, text, -1)

	table.insert(UniqueMarker, {
		x = x,
		y = y,
		z = z,
		nametag = nametag,
		r = r or 1,
		g = g or 0,
		b = b or 0,
		a = a or 1,
		y_offset = y_offset or 0,
	})
end

local addSquareMarker = function(square,text)
	if SquareNametags[square] then return end
	text = tostring(text)

	local nametag = TextDrawObject.new()
	nametag:ReadString(UIFont.Small, text, -1)

	SquareNametags[square] = nametag
end



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

FindersTools._DefaultSegments = {
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

FindersTools._ObjectTypeToStructureType = {
	["WallN"] = "Wall",
	["WallW"] = "Wall",
	["WallNW"] = "Wall",
	["DoorSound"] = "Door",
	["WindowN"] = "Window",
	["WindowW"] = "Window",
}

FindersTools.GetObjectSegments = function(object)
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
		local defaultProperties = FindersTools._DefaultSegments[wallType]
		for i = 1, #defaultProperties do
			table.insert(segments, defaultProperties[i])
		end

	elseif structureType == "Door" then
		local curtains = object:HasCurtains()
		local canSeeThrough = object:IsOpen() or properties:Is("doorTrans") and not curtains or curtains and curtains:isCurtainOpen() or false

		if not canSeeThrough then
			local wallType = object:getNorth() and "WallN" or "WallW"
			local defaultProperties = FindersTools._DefaultSegments[wallType]
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
			local defaultProperties = FindersTools._DefaultSegments[wallType]
			for i = 1, #defaultProperties do
				table.insert(segments, defaultProperties[i])
			end
		end
	end

	return segments
end

FindersTools.CastVisionRay = function(point, vectorBeam, maxBeamLength, ignoredObjects)
	local squares = {}
	local x1, y1, z = point.x, point.y, point.z

	local longVector = Vector2.new(vectorBeam):setLength(maxBeamLength)
	local farPoint = {x = x1 + longVector:getX(), y = y1 + longVector:getY()}
	local deltaLength = 0.01
	vectorBeam:setLength(deltaLength) -- for some reasons works better with a short length

	-- addMarker(x1, y1, 0, "X", 1, 0, 0, 1)

	local object, previousSquare, segments

	local x2 = x1
	local y2 = y1

	while maxBeamLength > 0 and not object do repeat
		local square = getSquare(x2, y2, z)
		x1, y1 = x2, y2
		x2 = x1 + vectorBeam:getX()
		y2 = y1 + vectorBeam:getY()
		maxBeamLength = maxBeamLength - deltaLength
		if squares[square] then break end -- square was already identified as intersect wall so don't check it anymore

		if square then
			-- check first type of objects
			local objects = square:getObjects()
			object, segments = FindersTools._CheckForIntersectedWall(objects, point, farPoint,vectorBeam, ignoredObjects)

			if object and segments then
				local wallSquare = segments.impactAngle >= 0 and previousSquare or square
				squares[wallSquare] = object
				return squares
			end

			-- check second type of objects
			local objects = square:getSpecialObjects()
			object, segments = FindersTools._CheckForIntersectedWall(objects, point, farPoint,vectorBeam, ignoredObjects)

			if object and segments then
				local wallSquare = segments.impactAngle >= 0 and previousSquare or square
				squares[wallSquare] = object
				return squares
			end

			-- else it's just a normal square, not a wall
			squares[square] = true
			previousSquare = square
		end

	until true end

	return squares
end


return FindersTools