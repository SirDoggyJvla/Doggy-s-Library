--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Defines the timed action of replacing the battery of the InfectionScanner.

]]--
--[[ ================================================ ]]--

require "TimedActions/ISBaseTimedAction"

local ISRemoveBattery = ISBaseTimedAction:derive("ISRemoveBattery")

function ISRemoveBattery:isValid()
	return true
end

function ISRemoveBattery:waitToStart()
	return false
end

function ISRemoveBattery:update()

end

function ISRemoveBattery:start()
	self:setActionAnim("Craft")
end

function ISRemoveBattery:stop()
	ISBaseTimedAction.stop(self);
end

function ISRemoveBattery:perform()
    local scanner = self.scanner
    local charge = scanner:getCurrentUsesFloat()

	-- create a battery
	local battery = instanceItem("Base.Battery")
	battery:setCurrentUsesFloat(charge)
	battery:syncItemFields()

	self.character:getInventory():AddItem(battery)

    -- set the charge of the scanner
    scanner:setCurrentUsesFloat(0)
	scanner:syncItemFields()

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISRemoveBattery:new (character,scanner,inventory,time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.stopOnWalk = false
	o.stopOnRun = true
	o.maxTime = time

	-- custom fields
    o.inventory = inventory
	o.scanner = scanner
	return o
end

return ISRemoveBattery