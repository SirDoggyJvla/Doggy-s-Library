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
}

--caching
local UIFont_Small = UIFont.Small


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