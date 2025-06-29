--[[ ================================================ ]]--
--[[  /~~\'      |~~\                  ~~|~    |      ]]--
--[[  '--.||/~\  |   |/~\/~~|/~~|\  /    | \  /|/~~|  ]]--
--[[  \__/||     |__/ \_/\__|\__| \/   \_|  \/ |\__|  ]]--
--[[                     \__|\__|_/                   ]]--
--[[ ================================================ ]]--
--[[

Custom event which triggers after a zombie is spawned and has its visuals set.

]]--
--[[ ================================================ ]]--

---CACHE
-- create new event
local LuaEvent = require "Starlit/LuaEvent"
local OnZombieVisuals = {
    Event = LuaEvent.new(),
    ZOMBIES_WAITING_FOR_INITIALIZATION = {},
    ZOMBIES_CHANGE_VISUALS_NEXT_TICK = {},
}

-- recycle
local OnZombieRecycle = require "DoggyEvents/OnZombieRecycle"



Events.OnZombieCreate.Add(function(zombie)
    table.insert(OnZombieVisuals.ZOMBIES_WAITING_FOR_INITIALIZATION,zombie)
end)

Events.OnTick.Add(function(tick)
    local ZOMBIES_WAITING_FOR_INITIALIZATION = OnZombieVisuals.ZOMBIES_WAITING_FOR_INITIALIZATION
    local ZOMBIES_CHANGE_VISUALS_NEXT_TICK = OnZombieVisuals.ZOMBIES_CHANGE_VISUALS_NEXT_TICK
    local ZOMBIES_CONTROL_RECYCLE = OnZombieRecycle.ZOMBIES_CONTROL_RECYCLE


    --- DETECT A ZOMBIE THAT IS VALID FOR SETTING VISUALS

    for i = #ZOMBIES_WAITING_FOR_INITIALIZATION,1,-1 do repeat
        -- get zombie
        local zombie = ZOMBIES_WAITING_FOR_INITIALIZATION[i]

        -- verify if valid for visuals
        if not zombie:hasActiveModel() then
            -- verify zombie got dressed in outfit
            if not zombie:isPersistentOutfitInit() then
                zombie:dressInRandomOutfit()

                -- if this doesn't pass, it means zombie can't get dressed in outfit, meaning the zombie got recycled
                if not zombie:isPersistentOutfitInit() then
                    table.remove(ZOMBIES_WAITING_FOR_INITIALIZATION,i)
                    OnZombieRecycle.Event:trigger(zombie)
                end
            end
            break
        end

        table.insert(ZOMBIES_CHANGE_VISUALS_NEXT_TICK,zombie)
        table.insert(ZOMBIES_CONTROL_RECYCLE,zombie)

        -- zombie doesn't need to be set later
        table.remove(ZOMBIES_WAITING_FOR_INITIALIZATION,i)
    until true end



    --- TRIGGER EVENT FOR VALID ZOMBIES ---

    for i = #ZOMBIES_CHANGE_VISUALS_NEXT_TICK,1,-1 do
        -- get zombie
        local zombie = ZOMBIES_CHANGE_VISUALS_NEXT_TICK[i]

        print(zombie:isPersistentOutfitInit())
        zombie:dressInRandomOutfit()
        print(zombie:isPersistentOutfitInit())

        -- if pID is not 0 then that zombie can get set
        if zombie:getPersistentOutfitID() ~= 0 then
            -- trigger event for this zombie
            OnZombieVisuals.Event:trigger(zombie)
        end

        -- zombie doesn't need to be set later
        table.remove(ZOMBIES_CHANGE_VISUALS_NEXT_TICK,i)
    end



    --- VERIFY RECYCLE ---

    for i = #ZOMBIES_CONTROL_RECYCLE,1,-1 do
        local zombie = ZOMBIES_CONTROL_RECYCLE[i]

        -- verify zombie got dressed in outfit
        if not zombie:isPersistentOutfitInit() then
            zombie:dressInRandomOutfit()

            -- if this doesn't pass, it means zombie can't get dressed in outfit, meaning the zombie got recycled
            if not zombie:isPersistentOutfitInit() then
                table.remove(ZOMBIES_CONTROL_RECYCLE,i)
                OnZombieRecycle.Event:trigger(zombie)
            end
        end
    end

end)

return OnZombieVisuals