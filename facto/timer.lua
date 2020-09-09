local Class = require("facto.class")

local Timer = Class.create()
Timer.type = "timer"

function Timer:__constructor(handler, timeout, is_interval)
    self.handler = handler
    self.is_interval = is_interval or false 
end 



-- @epxort
return Timer