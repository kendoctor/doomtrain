local Class = require("facto.class")
local AbstractStateUpdater = require("facto.player.abstractstateupdater")
local StatePhases = require("facto.player.statephases")

require("utils")
local EnergyPhases = StatePhases("energy")
    :add("Vigorous", 90, 100, 
    function(player) 
        debug("Vigorous")
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  + 0.25
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  + 0.25
    end, 
    function(player) 
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  - 0.25
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  - 0.25
    end)
    :add("Normal", 50, 90, 
    function(player) 
        debug("Normal")
    end, 
    function(player) 
        
    end)
    :add("Tired", 20, 50, 
    function(player) 
        debug("Tired")
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  - 0.25
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  - 0.25
    end, 
    function(player) 
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  + 0.25
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  + 0.25
    end)
    :add("Exhausted", 5, 20, 
    function(player) 
        debug("Exhausted")
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  - 0.5
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  - 0.5
    end, 
    function(player) 
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  + 0.5
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  + 0.5
    end)
    :add("Unconscious", 0, 5, 
    function(player) 
        debug("Unconscious")
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  - 1
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  - 1
    end, 
    function(player) 
        player.factoobj.character_running_speed_modifier  = player.factoobj.character_running_speed_modifier  + 1
        player.factoobj.character_mining_speed_modifier  = player.factoobj.character_mining_speed_modifier  + 1
    end)

local EnergyPhaseUpdater = Class.extend({}, AbstractStateUpdater)
EnergyPhaseUpdater.type = "energy-phase-updater"

-- @section metatable memebers
--- Initialization.
function EnergyPhaseUpdater:initialize(props)
    self.cycle_ticks = self.cycle_ticks or 30
    self.update_cycles = 0
    self.updated_cycle = 0
end 

function EnergyPhaseUpdater:update(game_tick, player)
    EnergyPhases:update(player)
end 

-- @export
return EnergyPhaseUpdater