--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Tools for boolean handling.

]]--
--[[ ================================================ ]]--

--requirements
local Booleans = {
    bools = {
        ActivateVisualMarkers = true,
        IntersectionPointMarkers = false,
        HighlightSquares = true,
    },
}

Booleans.SwapBooleans = function(key, _funcBefore, _funcAfter)
    if _funcBefore then
        _funcBefore()
    end
    Booleans.bools[key] = not Booleans.bools[key]
    if _funcAfter then
        _funcAfter()
    end
end

return Booleans