local Class = require("oop.class")
-- local Map = require("oop.map")
local CarriageDoor = require("facto.train.carriagedoor")

CarriageDoorManager = Class.create() -- persisted 
local instanced = {}
CarriageDoorManager.instanced = instanced


function CarriageDoorManager.create(props)    
    local instance = CarriageDoor(props)    
    instanced[tostring(instance:getId())] = instance
    return instance
end 

-- lazycall mode
function CarriageDoorManager.createLazyAdded(props)    
    local instance = CarriageDoor(props)    
    return instance, function() instanced[tostring(instance:getId())] = instance end 
end 

function CarriageDoorManager.get(id)
    return instanced[tostring(id)]
end 

function CarriageDoorManager.remove(object)
    local id = tostring(object:getId())
    local instance = instanced[id]
    -- if instance then instance:destory() end 
    instanced[id] = nil
end 

function CarriageDoorManager.setup()
end 

function CarriageDoorManager.init(guid, storage)
    storage.instanced = instanced
end 

function CarriageDoorManager.load(guid, data)
    instanced = data.instanced
    for id, data in pairs(instanced) do 
        CarriageDoor:__metalize(data)
    end 
end 

function CarriageDoorManager.guid()
    return "facto.train.carriagedoormanager"
end 

CarriageDoorManager.setup()

-- @export
return CarriageDoorManager