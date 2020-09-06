local Class = require("facto.class")

local StateModifiers = Class.create()

function StateModifiers:__constructor()
    self.modifiers = {}
end 

function StateModifiers:add(name, modifier)
    self.modifiers[name] = modifier
end 

function StateModifiers:get(name)
    return self.modifier[name]
end 

function StateModifiers:remove(name)
    if self:has(name) then 
        self.modifier[name] = nil 
    end 
end 

function StateModifiers:clear()
    self.modifiers = {}
end 

function StateModifiers:has(name)
    if self.modifiers[name] ~= nil then return true end 
    return false 
end 

function StateModifiers:getResult()
    local result 
    for _,modifier in pairs(self.modifiers) do 
        result = result + modifier
    end 
    return result
end 

-- @export
return StateModifiers