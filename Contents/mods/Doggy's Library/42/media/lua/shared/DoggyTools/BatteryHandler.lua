--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Battery handler gives a context menu handler for removing, adding or replacing batteries.

]]--
--[[ ================================================ ]]--

---CACHING
-- module
local BatteryHandler = {
    BatteryItems = {}, -- list of battery items
    BatteryItemsCount = 0, -- count of battery items
}
local BatteryItems = BatteryHandler.BatteryItems

-- requirements
local ISInsertBattery = require "DoggyTimedActions/ISInsertBattery"
local ISRemoveBattery = require "DoggyTimedActions/ISRemoveBattery"



---Add a new battery item to the list of battery items to have their context menu handled for swapping batteries.
---@param itemFullType string
---@return boolean|nil
BatteryHandler.AddBatteryItem = function(itemFullType)
    if not itemFullType or type(itemFullType) ~= "string" then
        error("BatteryHandler.AddBatteryItem - wrong item full type given (string expected, got "..type(itemFullType)..")",1)
        return nil
    end

    -- insert item in battery item list
    BatteryItems[itemFullType] = true
    BatteryHandler.BatteryItemsCount = BatteryHandler.BatteryItemsCount + 1

    return true
end




---Test function to recursively find batteries that are not dead in the inventory.
---@param item InventoryItem
---@return boolean
BatteryHandler.isBattery = function(item)
	return item:getType() == "Battery" and item:getCurrentUsesFloat() > 0
end

---When right clicking the item, show options to add or remove battery.
---@param playerIndex integer
---@param context table
---@param items table
BatteryHandler.OnFillInventoryObjectContextMenu = function(playerIndex, context, items)
    -- skip if no battery item
    if BatteryHandler.BatteryItemsCount <= 0 then return end

	-- retrieve player
	local player = getSpecificPlayer(playerIndex)

	-- check if item is item
	for i = 1,#items do repeat
		-- retrieve the item
		local item = items[i]
		if not instanceof(item, "InventoryItem") then
            item = item.items[1]
        end

		-- if item is valid
		if not BatteryItems[item:getFullType()] then break end

        -- retrieve batteries in the inventory
        local inventory = player:getInventory()
        local batteries = ArrayList.new()
        inventory:getAllEvalRecurse(BatteryHandler.isBattery, batteries)
        local batteriesAmount = batteries:size()

        -- check if item is charged, equiped and activated
        local charged = item:getCurrentUsesFloat() > 0

        -- create the submenu to insert or swap a battery
        local option
        if charged then
            option = context:addOption(getText("ContextMenu_DoggyAPI_SwapBattery"))
        else
            option = context:addOption(getText("ContextMenu_DoggyAPI_InsertBattery"))
        end

        -- if not batteries, then make option unavailable
        if batteriesAmount > 0 then
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)

            -- add every battery as an option to insert or swap battery
            for j = 0,batteriesAmount - 1 do
                local battery = batteries:get(j)

                local repairPercent = math.floor(battery:getCurrentUsesFloat() * 100.0).."%"
                subMenu:addOption(battery:getDisplayName()..":  "..repairPercent, player, BatteryHandler.ChangeBattery, item, battery, inventory)
            end
        else
            option.notAvailable = true
            local tooltip = ISWorldObjectContextMenu.addToolTip()
            tooltip.description = getText("Tooltip_DoggyAPI_noBatteriesAvailable")
            option.toolTip = tooltip
        end

        -- add option to remove the battery if present
        if charged then
            context:addOption(getText("ContextMenu_DoggyAPI_RemoveBattery"), player, BatteryHandler.RemoveBattery, item, inventory)
        end

        --- ONLY ADD OPTIONS FOR A SINGLE BATTERY ITEM TO NOT BLOAT CONTEXT MENU ---
        return
	until true end
end



---Change the battery from the item.
---@param player IsoPlayer
---@param item InventoryItem
---@param battery Drainable
---@param inventory ItemContainer
BatteryHandler.ChangeBattery = function(player,item,battery,inventory)
	-- item has an existing battery, replace it instead by removing the battery then adding the new one
	if item:getCurrentUsesFloat() > 0 then
		BatteryHandler.RemoveBattery(player,item,inventory)
	end

	-- transfer item and battery in main inventory if not in it
	ISInventoryPaneContextMenu.transferIfNeeded(player, battery)
	ISInventoryPaneContextMenu.transferIfNeeded(player, item)

	-- add an action to change battery
	ISTimedActionQueue.add(ISInsertBattery:new(player,item,battery,inventory,20))
end

---Remove the battery from the item.
---@param player IsoPlayer
---@param item InventoryItem
---@param inventory ItemContainer
BatteryHandler.RemoveBattery = function(player,item,inventory)
	-- transfer item in main inventory if not in it
	ISInventoryPaneContextMenu.transferIfNeeded(player, item)

	-- add an action to remove battery
	ISTimedActionQueue.add(ISRemoveBattery:new(player,item,inventory,20))
end

return BatteryHandler