local Class = require("oop.class")
-- local Map = require("oop.map")

CarriageFactory = Class.create() -- persisted 
local registered = {}
local instanced = {}
CarriageFactory.registered = registered
CarriageFactory.instanced = instanced

function CarriageFactory.register(carriage_type, class)
    registered[carriage_type] = class
end 

function CarriageFactory.getClass(carriage_type)
    return registered[carriage_type]
end 

function CarriageFactory.create(carriage_type, props)
    local class = CarriageFactory.getClass(carriage_type)
    if class == nil then error(string.format("Carriage type(%s) not supported", carriage_type)) end 
    local instance = class(props)
    instance.type = carriage_type 
    instanced[tostring(instance:getId())] = instance
    return instance
end 

function CarriageFactory.get(id)    
    return instanced[tostring(id)]
end 

function CarriageFactory.remove(carriage)
    local id = tostring(carriage:getId())
    local compare = instanced[id]
    if compare == carriage then instanced[id] = nil end 
end 

function CarriageFactory.setup()
    local class = require("facto.train.carriage")
    CarriageFactory.register(class.type, class)
    class = require("facto.train.cargowagon")
    CarriageFactory.register(class.type, class)    
end 

function CarriageFactory.init(guid, storage)
    storage.instanced = instanced
end 

function CarriageFactory.load(guid, data)
    instanced = data.instanced
    for id, data in pairs(instanced) do 
        local class = CarriageFactory.getClass(data.type)
        if class == nil then error(string.format("Carriage type(%s) not supported", data.type)) end 
        class:__metalize(data)
    end 
end 

function CarriageFactory.guid()
    return "facto.train.carriagefactory"
end 

CarriageFactory.setup()

-- @export
return CarriageFactory