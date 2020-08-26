local Class = require("oop.class")
local AbstractStateUpdater = require("facto.player.abstractstateupdater")

local EnergyPhaseUpdater = Class.extend({}, AbstractStateUpdater)
EnergyPhaseUpdater.type = "energy-phase-updater"

-- @section metatable memebers
--- Initialization.
function EnergyPhaseUpdater:initialize(props)
    self.cycle_ticks = self.cycle_ticks or 60
    self.update_cycles = 0
    self.updated_cycle = 0
end 

function EnergyPhaseUpdater:update(game_tick, player)
   -- get phase
   -- modifier, bonus, buff, debuff
   --[[--

   
   ]]
end 

-- @export
return EnergyPhaseUpdater