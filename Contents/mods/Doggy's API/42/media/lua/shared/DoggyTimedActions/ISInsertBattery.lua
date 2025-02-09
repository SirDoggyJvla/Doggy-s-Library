--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Custom TimedAction to remove batteries

]]--
--[[ ================================================ ]]--

require "TimedActions/ISBaseTimedAction"

local ISInsertBattery = ISBaseTimedAction:derive("ISInsertBattery")

function ISInsertBattery:isValid()
	return true
end

function ISInsertBattery:waitToStart()
	return false
end

function ISInsertBattery:update()

end

function ISInsertBattery:start()
	self:setActionAnim("Craft")
end

function ISInsertBattery:stop()
	ISBaseTimedAction.stop(self);
end

function ISInsertBattery:perform()
    local item = self.item
    local battery = self.battery

    -- set the charge of the item
    item:setCurrentUsesFloat(battery:getCurrentUsesFloat())

	-- remove the battery from inventory
	local inventory = self.inventory
	inventory:Remove(battery)
	inventory:removeItemOnServer(battery)

	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISInsertBattery:new (character,item,battery,inventory,time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.stopOnWalk = false
	o.stopOnRun = true
	o.maxTime = time

	-- custom fields
    o.inventory = inventory -- player inventory
	o.item = item
	o.battery = battery
	return o
end

return ISInsertBattery