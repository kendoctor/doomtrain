local Class = require("oop.class")

local StatePhases = Class.create()

function ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

function StatePhases:__constructor(state)
    self.statePhases = {}
    self.state = state
end 

function StatePhases:match(state_ratio, phase)
    state_ratio = math.floor(state_ratio*100)
    if state_ratio >= phase.min and state_ratio <= phase.max then return true end 
    return false
end 

function StatePhases:add(name, min, max, addEffect, removeEffect)
    self.statePhases[name] = { name = name, min = min, max = max, addEffect = addEffect, removeEffect = removeEffect }
    return self
end 

function StatePhases:get(name)
    return self.statePhases[name]
end 

function StatePhases:update(player)
    local matched 
    local previous_state_phase_name_property = string.format("previous_%s_phase_name", self.state)
    local get_state_ratio_method = string.format("get%sRatio", ucfirst(self.state))
    local previous_phase = self:get(player[previous_state_phase_name_property])

    for name, phase in pairs(self.statePhases) do 
        if self:match(player[get_state_ratio_method](player), phase) then 
            matched = phase    
            break
        end 
    end 
    assert(matched ~= nil)
    if previous_phase == nil or matched ~= previous_phase then 
        if previous_phase then previous_phase.removeEffect(player) end 
        matched.addEffect(player)
    end 
    player[previous_state_phase_name_property] = matched.name
end 

-- @export
return StatePhases