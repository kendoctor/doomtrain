local Class = require("facto.class")
local AbstractStateUpdater = require("facto.player.abstractstateupdater")

local FoodDigestingUpdater = Class.extend({}, AbstractStateUpdater)
FoodDigestingUpdater.type = "food-digesting-updater"

-- @section metatable memebers
--- Initialization.
function FoodDigestingUpdater:initialize(props)
    self.cycle_ticks = self.cycle_ticks or 30
    self.update_cycles = 0
    self.updated_cycle = 0
end 

function FoodDigestingUpdater:update(game_tick, player)
    player = player or self.player

    for key, eaten in pairs(player.eatens) do        
        local food = eaten.food 
        if eaten.absorbed_energy < food.energy then 
            local energy_per_cycle = food.energy/food.digest_time*self.cycle_ticks
            if (energy_per_cycle + eaten.absorbed_energy) > food.energy then energy_per_cycle = food.energy - eaten.absorbed_energy end 
            local actual = player:incEnergy(energy_per_cycle)
            eaten.absorbed_energy = eaten.absorbed_energy + actual
        else
            player.eatens[key] = nil
        end 
    end 
    self.updated_cycle = self.updated_cycle + 1
end 

-- @export
return FoodDigestingUpdater