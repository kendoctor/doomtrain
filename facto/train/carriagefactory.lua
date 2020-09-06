local Class = require("facto.class")
local AbstractFactory = require("facto.abstractfactory")

--- Carriage factory for creating different types of carriages, such as locomotive, cargo wagon, etc.
-- Centralized management of carriage instances for facto data serialization
-- @classmod CarriageFactory
local CarriageFactory = Class.extend({}, AbstractFactory)

-- @section metatable members
--- Remove carriage from cache.
-- Check if the same id carriage already replaced before removed 
-- @tparam class<Carriage> carriage
function CarriageFactory:remove(carriage)
    local id = tostring(carriage:getId())
    local compare = self.instanced[id]
    if compare == carriage then self.instanced[id] = nil end 
end 

--- Setup carriage factory.
function CarriageFactory:setup()
    local class = require("facto.train.carriage")
    self:register(class.type, class)
    class = require("facto.train.cargowagon")
    self:register(class.type, class)   
    class = require("facto.train.locomotive")
    self:register(class.type, class)
    class = require("facto.train.fluidwagon")
    self:register(class.type, class)   
    class = require("facto.train.artillerywagon")
    self:register(class.type, class)   
end 

--- Return a global unique key.
-- @treturn string
function CarriageFactory.guid()
    return "facto.train.carriagefactory"
end 

local instance 
--- Get singleton instance.
function CarriageFactory.getInstance()
    if instance == nil then 
       instance = CarriageFactory()
       instance:setup()
    end 
    return instance
end 

-- @export
return CarriageFactory