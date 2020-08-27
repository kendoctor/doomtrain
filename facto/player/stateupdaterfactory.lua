local Class = require("oop.class")
local Event = require("facto.event")
local AbstractFactory = require("facto.abstractfactory")

--- StateUpdater factory for creating different types of train
-- Centralized management of StateUpdater instances for facto data serialization
-- @classmod StateUpdaterFactory
local StateUpdaterFactory = Class.extend({}, AbstractFactory)

--- Initialization
function StateUpdaterFactory:initialize()
    self.uid = 0
end 

function StateUpdaterFactory:genUid()
    self.uid = self.uid + 1
    return self.uid
end

function StateUpdaterFactory:create(key, props)
    props = props or {}
    props.id = self:genUid()
    return StateUpdaterFactory.super.create(self, key, props)
end 

--- Setup StateUpdater factory
-- @todo using cfg
function StateUpdaterFactory:setup()    
    local class = require("facto.player.stateupdater.physiologicalneedsupdater")
    self:register(class.type, class)
    class = require("facto.player.stateupdater.staminarecoveryupdater")
    self:register(class.type, class)
    class = require("facto.player.stateupdater.runningconsumptionupdater")
    self:register(class.type, class)
    class = require("facto.player.stateupdater.energyphaseupdater")
    self:register(class.type, class)
    class = require("facto.player.stateupdater.fooddigestingupdater")
    self:register(class.type, class)
end 

function StateUpdaterFactory:init(guid, storage)  
    StateUpdaterFactory.super.init(self, guid, storage)
    storage.uid = self.uid
end 

function StateUpdaterFactory:load(guid, data)  
    StateUpdaterFactory.super.load(self, guid, data)
    self.uid = data.uid
end 

local instance 
--- Get singleton instance
function StateUpdaterFactory.getInstance()
    if instance == nil then 
       instance = StateUpdaterFactory()
       instance:setup()      
    end 
    return instance
end 

Event.on_nth_tick(1, function() 
    if instance then 
        -- for _,player in pairs(instance.online) do 
          
        -- end 
    end 
end)

-- @export
return StateUpdaterFactory