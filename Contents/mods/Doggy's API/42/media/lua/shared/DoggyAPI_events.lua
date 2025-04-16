--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Various events the framework links to.

]]--
--[[ ================================================ ]]--

---requirements

local Booleans = require "DoggyTools/Booleans"
local bools = Booleans.bools

--functions
local IsoUtils_XToScreen, IsoUtils_YToScreen = IsoUtils.XToScreen, IsoUtils.YToScreen



---Event triggered when the player right clicks on an item in the inventory
local BatteryHandler = require "DoggyTools/BatteryHandler"
Events.OnFillInventoryObjectContextMenu.Add(BatteryHandler.OnFillInventoryObjectContextMenu)

---Event triggered when a chunk is loaded
local LoadNewChunk = require "DoggyEvents/LoadNewChunk"
Events.LoadChunk.Add(LoadNewChunk.LoadChunk)

local DebugContextMenu = require "DoggyDebugTools/DebugContextMenu"
Events.OnFillWorldObjectContextMenu.Add(DebugContextMenu.OnFillWorldObjectContextMenu)

local VisualMarkers = require "DoggyDebugTools/VisualMarkers"
Events.OnPostRender.Add(function()
    if bools.ActivateVisualMarkers then
        local zoom = getCore():getZoom(0)

        for _, marker in pairs(VisualMarkers.SquareNametags) do
            local x, y, z = marker.x, marker.y, marker.z
            local sx = IsoUtils_XToScreen(x, y, z, 0)
            local sy = IsoUtils_YToScreen(x, y, z, 0)

            sx = sx - IsoCamera.getOffX()
            sy = sy - IsoCamera.getOffY() - marker.y_offset

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

            sx = sx - IsoCamera.getOffX()
            sy = sy - IsoCamera.getOffY() - marker.y_offset

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
end)