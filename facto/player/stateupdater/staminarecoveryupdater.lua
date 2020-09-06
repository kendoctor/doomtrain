local Class = require("facto.class")
local AbstractStateUpdater = require("facto.player.abstractstateupdater")

local StaminaRecoveryUpdater = Class.extend({}, AbstractStateUpdater)
StaminaRecoveryUpdater.type = "stamina-recovery-updater"

-- @section metatable memebers
--- Initialization.
function StaminaRecoveryUpdater:initialize(props)
    self.cycle_ticks = self.cycle_ticks or 10
    self.update_cycles = 0
    self.updated_cycle = 0
    self.energy_consumption = props.energy_consumption or 10
end 

function StaminaRecoveryUpdater:update(game_tick, player)
    player = player or self.player
    -- player:decEnergy(self.energy_consumption)
    if not player:isStaminaFull() and not player:isEnergyEmpty() then 
        local stamina_added = 2
        -- @fixme check if has enough energy 
        local actual = player:decEnergy(stamina_added)
        actual = player:incStamina(actual)       
        player:incEnergy(stamina_added - actual)
    end 
    self.updated_cycle = self.updated_cycle + 1
end 

-- @export
return StaminaRecoveryUpdater