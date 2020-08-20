local Class = require("oop.class")
local Event = require("facto.event")
local AbstractFactory = require("facto.abstractfactory")

--- Exchanger factory class for registering, creating different exchangers, and centralized managing all exchanger instances.
-- @classmod ExchangerFactory
local ExchangerFactory = Class.extend({}, AbstractFactory)

-- @section property members

-- @section metatable members
--- Setup exchanger factory.
-- @todo using cfg
function ExchangerFactory:setup()    
    local class = require("facto.exchanger.cargowagonexchanger")
    self:register(class.type, class)
    class = require("facto.exchanger.fluidwagonexchanger")
    self:register(class.type, class)
end 

--- Create exchanger in lazy added mode.
-- Considering creating facto entities and tiles in one call
-- When in final creation of all entities, invoke the returned closure
-- @tparam table props
-- @treturn class<Exchanger>, closure 
function ExchangerFactory:createLazyAdded(key, props)    
    local class = self:getClass(key)
    if class == nil then error(string.format("Key(%s) not registered.", key)) end 
    local instance = class(props) 
    -- this value for deserialization
    instance.type = key 
    return instance, function() self.instanced[tostring(instance:getId())] = instance end 
end 

--- Return a global unique key.
-- @treturn string
function ExchangerFactory.guid()
    return "facto.exchanger.exchangerfactory"
end 

local instance 
--- Get singleton instance.
-- @treturn class<ExchangerFactory>
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