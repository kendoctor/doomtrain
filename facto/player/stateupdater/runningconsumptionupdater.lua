local Class = require("oop.class")
local AbstractStateUpdater = require("facto.player.abstractstateupdater")

local RunningConsumptionUpdater = Class.extend({}, AbstractStateUpdater)
RunningConsumptionUpdater.type = "running-consumption-updater"

-- @section metatable memebers
--- Initialization.
function RunningConsumptionUpdater:initialize(props)
    self.cycle_ticks = self.cycle_ticks or 2
    self.update_cycles = 0
    self.updated_cycle = 0
    self.stamina_consumption = props.stamina_consumption or 0.15
end 

function RunningConsumptionUpdater:update(game_tick, player)
    player = player or self.player
    if player:isMoving() and not player:isStaminaEmpty() then 
        local actual = player:decStamina(self.stamina_consumption)
    end 
    self.updated_cycle = self.updated_cycle + 1
end 

-- @export
return RunningConsumptionUpdater