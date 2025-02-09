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
local DoggyAPI = require "DoggyAPI_module"
local FINDERS = DoggyAPI.FINDERS

---functions
local getSquare = getSquare


--[[ ================================================ ]]--
--- CIRCULAR FINDERS ---
--[[ ================================================ ]]--

---Creates a table of directions to check outward from the center point for a circle of radius `radius`.
---Can be used to check around a point in a circle starting from the center or other circular applications.
---@param radius integer
---@param directions table|nil
---@return any
FINDERS.CacheCircleOutwardDirections = function(radius,directions)
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

FINDERS.CIRCULAR_OUTWARD_DIRECTIONS = FINDERS.CacheCircleOutwardDirections(75)



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
FINDERS.FindNearestValidSquare = function(startX, startY , min_radius, max_radius, min_h, max_h, directions, isValid)
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