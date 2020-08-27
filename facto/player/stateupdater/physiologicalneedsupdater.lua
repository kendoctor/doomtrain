local Class = require("oop.class")
local AbstractStateUpdater = require("facto.player.abstractstateupdater")

require("utils")
local PhysiologicalNeeds = Class.extend({}, AbstractStateUpdater)
PhysiologicalNeeds.type = "physiological-needs-updater"

-- @section metatable memebers
--- Initialization.
function PhysiologicalNeeds:initialize(props)
    self.cycle_ticks = self.cycle_ticks or 60
    self.update_cycles = 0
    self.updated_cycle = 0
    self.energy_consumption = props.energy_consumption or 10
end 

function PhysiologicalNeeds:update(game_tick, player)
    player = player or self.player
    if not player:isEnergyEmpty() then 
        player:decEnergy(self.energy_consumption)
    elseif not player:isStaminaEmpty() then
        player:decStamina(self.energy_consumption)
    end 
end 

-- @export
return PhysiologicalNeeds