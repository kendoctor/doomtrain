-- TrainFactory Module
local Class = require("oop.class")
-- local Event = require("facto.event")

TrainFactory = Class.create() -- persisted 
local registered = {}
local instanced = {}
TrainFactory.registered = registered
TrainFactory.instanced = instanced

function TrainFactory.register(train_type, class)
    registered[train_type] = class
end 

function TrainFactory.getClass(train_type)
    return registered[train_type]
end 

function TrainFactory.create(train_type, props)
    local class = TrainFactory.getClass(train_type)
    if class == nil then error(string.format("Train type(%s) not supported", train_type)) end 
    local instance = class(props)  
    instance.type = train_type 
    instanced[tostring(instance:getId())] = instance
    return instance
end 

function TrainFactory.remove(train)    
    instanced[tostring(train:getId())] = nil 
end 

function TrainFactory.setup()
    local class = require("facto.train.train")
    TrainFactory.register(class.type, class)
end 

function TrainFactory.init(guid, storage)
    storage.instanced = instanced
end 

function TrainFactory.load(guid, data)
    -- log(serpent.block(data))
    instanced = data.instanced
    for id, data in pairs(instanced) do 
        local class = TrainFactory.getClass(data.type)
        if class == nil then error(string.format("Train type(%s) not supported", data.type)) end 
        class:__metalize(data)
    end 
end 

function TrainFactory.guid()
    return "facto.train.trainfactory"
end 


TrainFactory.setup()

-- @export
return TrainFactory