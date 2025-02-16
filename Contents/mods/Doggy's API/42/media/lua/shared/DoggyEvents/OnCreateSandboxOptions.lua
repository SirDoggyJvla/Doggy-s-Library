--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Custom event which triggers every time 

]]--
--[[ ================================================ ]]--


-- create new event
local LuaEvent = require "Starlit/LuaEvent"
local OnCreateSandboxOptions = {
    events = {},
}

function OnCreateSandboxOptions.addListener(pageName, func)
    -- if initialisation order is an issue you could create the event here if it doesn't exist
    OnCreateSandboxOptions.events[pageName] = OnCreateSandboxOptions.events[pageName] or LuaEvent.new()
    OnCreateSandboxOptions.events[pageName]:addListener(func)
end


return OnCreateSandboxOptions