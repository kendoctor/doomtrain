local Class = require("oop.class")
local Event = require("facto.event")
local AbstractFactory = require("facto.abstractfactory")

--- Train factory for creating different types of train
-- Centralized management of train instances for facto data serialization
-- @classmod TrainFactory
local ExchangerFactory = Class.extend({}, AbstractFactory)

--- Setup train factory
-- @todo using cfg
function ExchangerFactory:setup()    
    local class = require("facto.exchanger.cargowagonexchanger")
    self:register(class.type, class)
end 

--- Create carriage door in lazy added mode.
-- Considering creating facto entities and tiles in one call
-- When in final creation of all entities, invoke the returned closure
-- @tparam table props
-- @treturn class<CarriageDoor>, closure 
function ExchangerFactory:createLazyAdded(key, props)    
    local class = self:getClass(key)
    if class == nil then error(string.format("Key(%s) not registered.", key)) end 
    local instance = class(props) 
    -- this value for deserialization
    instance.type = key 
    return instance, function() self.instanced[tostring(instance:getId())] = instance end 
end 

-- @section static members

--- Return a global unique key
-- @treturn string
function ExchangerFactory.guid()
    return "facto.exchanger.exchangerfactory"
end 

local instance 
--- Get singleton instance
function ExchangerFactory.getInstance()
    if instance == nil then 
       instance = ExchangerFactory()
       instance:setup()      
    end 
    return instance
end 

Event.on_nth_tick(60, function() 
    if instance then 
        for _,exchanger in pairs(instance.instanced) do 
            exchanger:exchange()
        end 
    end 
end)

-- @export
return ExchangerFactory