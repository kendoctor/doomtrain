local Class = require("facto.class")

local Updater = Class.create()
Updater.type = "updater"

local function is_valid_serialization_function(fnc)
    local i = 1
    while true do
        local name, value = debug.getupvalue(fnc, i)
        if name and name ~= "_ENV" then return false end 
        if not name then break end
        i = i + 1
    end
    return true
end

--- Constructor.
function Updater:__constructor(handler, frequency, multiply)
    if not is_valid_serialization_function(handler) then 
        error("Updater:__constructor, invalid handler for serialization.") 
    end 
    self.id = nil
    self.handler = string.dump(handler)
    self.frequency = frequency or 60 -- in ticks
    self.multiply = multiply or 0-- how many times to update
    self.updated = 0
    self:initialize()
end 

--- Initialization.
function Updater:initialize()
end 

function Updater:getId()
    return self.id
end 

--- Check if the updater needs to be removed from the updater queue.
-- @treturn boolean if true, update in next cycle, false removed
function Updater:isContinued()
    if self.multiply == 0 or self.updated < self.multiply then return true end 
    return false  
end 

function Updater:incUpdated()
    self.updated = self.updated + 1
end 

function Updater:update(game_tick)
    local h = (load or loadstring)(self.handler)
    self:incUpdated()
    return h(self, game_tick)
end 

-- @export
return Updater