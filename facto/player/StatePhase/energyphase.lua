local Class = require("facto.class")

local StatePhases = Class.create()

function StatePhases:__constructor(props)
    self.statePhases = {}
end 

function StatePhases:match(state, phase)
    if state >= phase.min and state <= phase.max then return true end 
    return false
end 

function StatePhases:add(name, min, max, addEffect, removeEffect)
    self.statePhases[name] = { name = name, min = min, max = max, addEffect = addEffect, removeEffect = removeEffect }
end 

function StatePhases:get(name)
    return self.statePhases[name]
end 

function StatePhases:update(player, state_name)
    local matched 
    local previous_state_phase_property = string.format("previous_%s_phase_name", state_name)
    local previous_phase = self:get(player[previous_state_phase_property])
    for name, phase in pairs(self.statePhases) do 
        if self:match(player[state_name], phase) then 
            matched = phase    
            break
        end 
    end 
    assert(matched ~= nil)
    if previous_phase == nil or matched ~= previous_phase then 
        if previous_phase then previous_phase.removeEffect() end 
        matched.addEffect()
    end 
    player[previous_state_phase_property] = matched.name
end 

-- @export
return StatePhases

