--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Tools for debugging by showing things on the screen.

]]--
--[[ ================================================ ]]--

---requirements
local VisualMarkers = {
    UniqueMarker = {},
    SquareNametags = {},
    HighlightsSquares = {},
	Lines = {},
}

--tools
local Booleans = require "DoggyTools/Booleans"
local bools = Booleans.bools

--caching
local UIFont_Small = UIFont.Small
local spriteRenderer = getRenderer()

--functions
local IsoUtils_XToScreen, IsoUtils_YToScreen = IsoUtils.XToScreen, IsoUtils.YToScreen

VisualMarkers.OnPostRender = function()
	-- camera info
	local zoom = getCore():getZoom(0)
	local cameraX = IsoCamera.getOffX()
	local cameraY = IsoCamera.getOffY()

	if bools.ActivateVisualMarkers then
        for _, marker in pairs(VisualMarkers.SquareNametags) do
            local x, y, z = marker.x, marker.y, marker.z
            local sx = IsoUtils_XToScreen(x, y, z, 0)
            local sy = IsoUtils_YToScreen(x, y, z, 0)

            sx = sx - cameraX
            sy = sy - cameraY - marker.y_offset

            -- apply zoom
            sx = sx / zoom
            sy = sy / zoom
            sy = sy - marker.height

            marker.nametag:AddBatchedDraw(sx, sy, true)
        end

        local UniqueMarkers = VisualMarkers.UniqueMarker
        for i = 1,#UniqueMarkers do
            local marker = UniqueMarkers[i]
            local x, y, z = marker.x, marker.y, marker.z
            local sx = IsoUtils_XToScreen(x, y, z, 0)
            local sy = IsoUtils_YToScreen(x, y, z, 0)

            sx = sx - cameraX
            sy = sy - cameraY - marker.y_offset

            -- apply zoom
            sx = sx / zoom
            sy = sy / zoom
            sy = sy - marker.height

            marker.nametag:AddBatchedDraw(sx, sy, true)
        end
    end

    if bools.HighlightSquares then
        local floorSprite = IsoSprite.new()
        floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
        for square, highlight in pairs(VisualMarkers.HighlightsSquares) do
            local x,y,z = square:getX(), square:getY(), square:getZ()
            local color = highlight.color
            local r,g,b,a = color.r, color.g, color.b, color.a

            floorSprite:RenderGhostTileColor(x, y, z, r, g, b, a)
        end
    end

	local Lines = VisualMarkers.Lines
	for i = 1,#Lines do
		local line = Lines[i]

		local pointA = line.pointA
		local pointB = line.pointB
		local x1, y1, z1 = pointA.x, pointA.y, pointA.z
		local x2, y2, z2 = pointB.x, pointB.y, pointB.z

		local sx1 = IsoUtils_XToScreen(x1, y1, z1, 0)
		local sy1 = IsoUtils_YToScreen(x1, y1, z1, 0)
		local sx2 = IsoUtils_XToScreen(x2, y2, z2, 0)
		local sy2 = IsoUtils_YToScreen(x2, y2, z2, 0)

		sx1 = sx1 - cameraX
		sy1 = sy1 - cameraY
		sx2 = sx2 - cameraX
		sy2 = sy2 - cameraY

		local r,g,b,a = line.r, line.g, line.b, line.a
		spriteRenderer:renderline(nil,
			sx1, sy1,
			sx2, sy2,
			r, g, b, a
		)
	end
end



--[[ ================================================ ]]--
--- LINES ---
--[[ ================================================ ]]--

VisualMarkers.ResetLines = function()
	VisualMarkers.Lines = {}
end

VisualMarkers.AddLine = function(pointA,pointB,r,g,b,a,width)
	local vector = Vector2.new(pointB.x - pointA.x, pointB.y - pointA.y)
	vector:tangent()
	width = width or 0.1
	vector:setLength(width/2)

	local x = vector:getX()
	local y = vector:getY()

	local line = {
		pointA = pointA,
		pointB = pointB,
		widthA = {x=x,y=y,z=pointA.z},
		widthB = {x=x,y=y,z=pointB.z},
		r = r or 1,
		g = g or 0,
		b = b or 0,
		a = a or 1,
	}

	table.insert(VisualMarkers.Lines, line)
end




--[[ ================================================ ]]--
--- MARKERS ---
--[[ ================================================ ]]--


VisualMarkers.ResetMarkers = function()
    VisualMarkers.UniqueMarker = {}
    VisualMarkers.SquareNametags = {}
end


VisualMarkers.AddMarker = function(x,y,z,text,r,g,b,a,y_offset)
	text = tostring(text) -- safeguard

	local nametag = TextDrawObject.new()
	nametag:ReadString(UIFont_Small, text, -1)
    nametag:setDefaultColors(r or 1,g or 0,b or 0,a or 1)

	table.insert(VisualMarkers.UniqueMarker, {
		x = x,
		y = y,
		z = z,
		nametag = nametag,
		y_offset = y_offset or 0,
        height = nametag:getHeight(),
	})
end


VisualMarkers.AddSquareMarker = function(square,text,r,g,b,a,y_offset)
    local SquareNametags = VisualMarkers.SquareNametags
	if SquareNametags[square] then return end
	text = tostring(text) -- safeguard

	local nametag = TextDrawObject.new()
	nametag:ReadString(UIFont_Small, text, -1)
    nametag:setDefaultColors(r or 1,g or 0,b or 0,a or 1)

	SquareNametags[square] = {
		x = square:getX()+0.5,
        y = square:getY()+0.5,
		z = square:getZ(),
		nametag = nametag,
		y_offset = y_offset or 0,
        height = nametag:getHeight(),
	}
end


--[[ ================================================ ]]--
--- SQUARE HIGHLIGHT ---
--[[ ================================================ ]]--

VisualMarkers.ResetHighlightSquares = function()
    VisualMarkers.HighlightsSquares = {}
end

VisualMarkers.AddHighlightSquare = function(square, ISColors, priority)
    if not square or not ISColors then return end
    local existingSquare = VisualMarkers.HighlightsSquares[square]
    if existingSquare and existingSquare.priority >= priority then return end

    VisualMarkers.HighlightsSquares[square] = {color = ISColors, priority = priority}
end

return VisualMarkers