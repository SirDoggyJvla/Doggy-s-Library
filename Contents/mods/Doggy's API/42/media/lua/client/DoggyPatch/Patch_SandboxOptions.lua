--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Retrieve every option panels from the sandbox option panel.

]]--
--[[ ================================================ ]]--

--- DEFINITIONS

---@class OptionPanels
---@field OPTION_PANELS table<string, SandboxOptionPanel> -- list of option panels
local OptionPanels = {
    OPTION_PANELS = {}, -- list of option panels
}

---@class SandboxOptionPanel

--- CACHING
-- custom event
local OnCreateSandboxOptions = require "DoggyEvents/OnCreateSandboxOptions"



--[[ ================================================ ]]--
--- RETRIEVING SandboxOptionPanel ---
--[[ ================================================ ]]--

local SandboxOptionsScreen_createPanel = SandboxOptionsScreen.createPanel

---Intercept the creation of the panel to store each option based on their name.
---@param page table
---@return table
function SandboxOptionsScreen:createPanel(page)
    local panel = SandboxOptionsScreen_createPanel(self, page)

    OptionPanels.OPTION_PANELS[page.name] = panel

    local event = OnCreateSandboxOptions.events[page.name]
    if event then
        event:trigger(panel)
    end

    return panel
end

---Retrieves the option panel based on its name, needs to be the exact name as in the sandbox option panel which can be retrieved with your page name in `sandbox-options.txt` by using `getText()`.
---@param name string
---@return SandboxOptionPanel|nil
OptionPanels.GetOptionPanel = function(name)
    local panel = OptionPanels.OPTION_PANELS[name]
    if panel then
        return panel
    end
    error("Option panel not found for name: " .. tostring(name))
end

return OptionPanels