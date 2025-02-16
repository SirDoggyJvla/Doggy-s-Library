--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Gives tools to modders to easily customize the sandbox option panel.

]]--
--[[ ================================================ ]]--

--- DEFINITIONS
---@class CustomizeSandboxOptionPanel
local CustomizeSandboxOptionPanel = {}

---@class BaseColor
---@field r number
---@field g number
---@field b number
---@field a number

--- REQUIREMENTS
local OptionPanels = require "DoggyPatch/Patch_SandboxOptions"
CustomizeSandboxOptionPanel.GetOptionPanel = OptionPanels.GetOptionPanel


--- CACHING
-- ui size
local UI_BORDER_SPACING = 10


---Retrieves the total 
---@param panel any
CustomizeSandboxOptionPanel.GetTotalOptionDimensions = function(panel)
    -- get y
    local titles = panel.titles
    local controls = panel.controls
    local labels = panel.labels
    local y = 11
    local i = 1

    -- intercept other coordinates
    local width = 0
    local x = 0

    for name,control in pairs(controls) do
        if titles[i] then
            y = titles[i].yShift -- it's not the one associated to control, but we don't really care here bcs we look for total y
        end
        local label = labels[name]
        y = y + math.max(label:getHeight(), control:getHeight()) + UI_BORDER_SPACING

        i = i + 1

        local control_rightSide = control.x + control.width
        local label_leftSide = label.x

        width = math.max(width, control_rightSide - label_leftSide)
        x = math.max(x, label_leftSide)

        -- pimp control
        control.backgroundColor = {r=1,g=0.80,b=0,a=0.5}
        control.borderColor = {r=1,g=0.80,b=0,a=1}
    end

    return x,y,width
end






--[[ ================================================ ]]--
--- CUSTOMIZE SandboxOptionPanel ---
--[[ ================================================ ]]--

---Sets the color of the panel.
---@param panel SandboxOptionPanel
---@param borderColor BaseColor
---@param backgroundColor BaseColor
CustomizeSandboxOptionPanel.SetPanelColor = function(panel, borderColor, backgroundColor)
    if not panel then
        error("Panel cannot be nil.")
    end
    panel.borderColor = borderColor or panel.borderColor
    panel.backgroundColor = backgroundColor or panel.backgroundColor
end

CustomizeSandboxOptionPanel.SetScrollBarHeight = function(panel,y)
    panel:setScrollHeight(y)
end


return CustomizeSandboxOptionPanel