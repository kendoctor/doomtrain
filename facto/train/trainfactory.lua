local Class = require("facto.class")
local AbstractFactory = require("facto.abstractfactory")

--- Train factory for creating different types of train
-- Centralized management of train instances for facto data serialization
-- @classmod TrainFactory
local TrainFactory = Class.extend({}, AbstractFactory)

--- Setup train factory
-- @todo using cfg
function TrainFactory:setup()    
    local class = require("facto.train.train")
    self:register(class.type, class)
end 

-- @section static members

--- Return a global unique key
-- @treturn string
function TrainFactory.guid()
    return "facto.train.trainfactory"
end 

local instance 
--- Get singleton instance
function TrainFactory.getInstance()
    if instance == nil then 
       instance = TrainFactory()
       instance:setup()      
    end 
    return instance
end 

-- @export
return TrainFactory