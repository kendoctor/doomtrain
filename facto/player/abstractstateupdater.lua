local Class = require("facto.class")

local AbstractStateUpdater = Class.create()

--- Constructor.
function AbstractStateUpdater:__constructor(props)
    props = props or {}
    self.id = props.id
    self.player = props.player
    self.cycle_ticks = props.cycle_ticks
    self.update_cycles = props.cycle_ticks
    self.updated_cycles = 0
    -- self.update = props.update
    self:initialize(props)
end 

--- Initialization.
function AbstractStateUpdater:initialize()
end 

function AbstractStateUpdater:getId()
    return self.id
end 

--- Check if the updater needs to be removed from the updater queue.
-- @treturn boolean if true, update in next cycle, false removed
function AbstractStateUpdater:isContinued()
    if self.update_cycles == 0 then return true end 
    if self.updated_cycles < self.update_cycles then return true end 
    return false  
end 

function AbstractStateUpdater:incUpdated()
    self.updated_cycles = self.updated_cycles + 1
end 

function AbstractStateUpdater:update(player, game_tick)
    error("AbstractStateUpdater.update should be overriden.")
end 

-- @export
return AbstractStateUpdater