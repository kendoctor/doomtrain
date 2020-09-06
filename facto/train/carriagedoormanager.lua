local Class = require("facto.class")
local AbstractFactory = require("facto.abstractfactory")
local CarriageDoor = require("facto.train.carriagedoor")

--- Carriage door manager for centralized management of door instances and facto data serialization.
-- @classmod CarriageDoorManager
CarriageDoorManager = Class.extend({}, AbstractFactory)

--- Create carriage door with properties.
-- @tparam table props
-- @treturn class<CarriageDoor>
function CarriageDoorManager:create(props)    
    local instance = CarriageDoor(props)    
    self.instanced[tostring(instance:getId())] = instance
    return instance
end 

--- Create carriage door in lazy added mode.
-- Considering creating facto entities and tiles in one call
-- When in final creation of all entities, invoke the returned closure
-- @tparam table props
-- @treturn class<CarriageDoor>, closure 
function CarriageDoorManager:createLazyAdded(props)    
    local instance = CarriageDoor(props)    
    return instance, function() self.instanced[tostring(instance:getId())] = instance end 
end 

--- Setup 
function CarriageDoorManager:setup()
end 

--- Metalize doors when game save loaded.
-- @tparam string guid
-- @tparam table data
function CarriageDoorManager:load(guid, data)
    self.instanced = data.instanced
    for id, data in pairs(self.instanced) do 
        CarriageDoor:__metalize(data)
    end 
end 

--- Return a global unique key.
-- @treturn string
function CarriageDoorManager.guid()
    return "facto.train.carriagedoormanager"
end 

local instance 
--- Get singleton instance.
function CarriageDoorManager.getInstance()
    if instance == nil then 
       instance = CarriageDoorManager()
       instance:setup()
    end 
    return instance
end 

-- @export
return CarriageDoorManager