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

-- requirements
local DebugContextMenu = {}

-- tools
local Booleans = require "DoggyTools/Booleans"
local bools = Booleans.bools
local VisualMarkers = require "DoggyDebugTools/VisualMarkers"


DebugContextMenu.OnFillWorldObjectContextMenu = function(playerIndex, context, worldObjects, test)
    if not isDebugEnabled() then return end

    -- access the first square found
    local worldObject,square
    for i = 1,#worldObjects do
        worldObject = worldObjects[i]
        square = worldObject:getSquare()
        if square then
            break
        end
    end

    -- skip if no square found
    if not square then return end


    -- create the submenu for Doggy's Library debug context menu
    local mainMenuOption = context:addOptionOnTop("Doggy's Library: Debug")
    local mainMenu = context:getNew(context)
    context:addSubMenu(mainMenuOption, mainMenu)

    mainMenuOption.iconTexture = getTexture("poster.png")



    --- VISUAL MARKERS ---
    local visualMarkersMenuOption = mainMenu:addOptionOnTop("Visual Markers")
    local visualMarkersMenu = mainMenu:getNew(mainMenu)
    mainMenu:addSubMenu(visualMarkersMenuOption, visualMarkersMenu)

    -- Remove markers
    local option = visualMarkersMenu:addOption("Remove All Markers", nil, VisualMarkers.ResetMarkers)

    -- Disable visual markers
    local option = visualMarkersMenu:addOption("Active Visual Markers", "ActivateVisualMarkers", Booleans.SwapBooleans)
    visualMarkersMenu:setOptionChecked(option, bools.ActivateVisualMarkers)

    -- Disable intersection point markers
    local option = visualMarkersMenu:addOption("Intersection Point Markers", "IntersectionPointMarkers", Booleans.SwapBooleans)
    visualMarkersMenu:setOptionChecked(option, bools.IntersectionPointMarkers)

    -- Remove square highlights
    local option = visualMarkersMenu:addOption("Remove Square Highlights", nil, VisualMarkers.ResetHighlightSquares)

    -- Disable square highlights
    local option = visualMarkersMenu:addOption("Highlight Squares", "HighlightSquares", Booleans.SwapBooleans)
end



return DebugContextMenu