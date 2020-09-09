local Class = require("facto.class")
local AbstractFactory = require("facto.abstractfactory")

-- @classmod UpdaterFactory
local UpdaterFactory = Class.extend({}, AbstractFactory)

-- function UpdaterFactory:__constructor(event)
-- end 

--- Initialization
function UpdaterFactory:initialize()
    self.serialize.token = 0
end 

function UpdaterFactory:generateId()
    self.serialize.token = self.serialize.token + 1
    return tostring(self.serialize.token)
end

function UpdaterFactory:create(key, ...)
    local class = self:getClass(key)
    if class == nil then error(string.format("Key(%s) not registered.", key)) end 
    local instance = class(...) 
    instance.id = self:generateId()
    instance.type = key 
    self.serialize.instanced[instance:getId()] = instance
    return instance
end 

--- Setup StateUpdater factory
-- @todo using cfg
function UpdaterFactory:setup()    
    local class = require("facto.updater.updater")
    self:register(class.type, class)
    local Event = self.Event
    Event.on(Event.facto.on_tick, function(e) self:update(e) end)
    return self
end 

function UpdaterFactory:update(e)
    local instanced = self.serialize.instanced
    for id, instance in pairs(instanced) do
        if e.tick % instance.frequency == 0 then        
            if instance:update(e.tick) or not instance:isContinued() then 
                self:remove(instance)            
            end         
        end 
    end 
end 

function UpdaterFactory.guid()
    return "facto.updater.updaterfactory"
end 

-- @export
return UpdaterFactory