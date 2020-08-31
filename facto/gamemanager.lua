local Class = require("oop.class")

--- Manage the game objects and resources.
-- @classmod GameManager
local GameManager = Class.create()
local services
local config 

function GameManager:__constructor(cfg)
    services = {}
    config = cfg
end 

--- Setup game manager.
function GameManager:setup()
--- modules need to be registered
--- modules need only to be required
    -- for _, module  in pairs(cfg.modules)  
    --     local class = require(module)
    --     -- assert(Class.subclass(class) == PersistedClass)  
    --     if is_persisted_class then 
    --         GameManager.register(class.guid(), class)
    --     end 
    -- end 
    local class = require("facto.event")
    self.event = self:register(class)
    -- class = require("facto.train.trainfactory")
    -- self:register(class)
    -- class = require("facto.train.carriagefactory")
    -- self:register(class)    
    -- class = require("facto.train.carriagedoormanager")
    -- self:register(class)
    -- class = require("facto.exchanger.exchangerfactory")
    -- self:register(class)
    -- class = require("facto.player.playerfactory")
    -- self:register(class)
end 

--- Register services
function GameManager:register(class)
    local instance = class.getInstance()
    services[class.guid()] = instance
    return instance
end 

--- Invoked when script.on_init triggered.
function GameManager:init()
    -- via cfg. init feature     
    global.facto = global.facto or {} 
    for guid, persisted in pairs(services) do
        -- if global.facto[guid] == nil, that means some features added
        -- should not change this data in on load        
        -- if global.facto[guid] == nil then global.facto[guid] = {} end
        persisted:init(guid, global.facto)
    end     
end 

-- Inovked when script.on_load triggered
function GameManager:load()   
    log(serpent.block(global.facto, {comment=true}))
    -- if global.facto == nil, that means game already broken
    for guid, persisted in pairs(services) do
        -- if global.facto[guid] == nil, that means some features added
        -- should not change this data in on load        
        persisted:load(guid, global.facto)
    end 
end 

--- @todo if new features added into scenario, could we still load old save game ?
-- 1. on_init will not trigger, if not scenario changed ?
-- on_configuration_changed ? need to test this event when will be triggered
-- local Train = GlobalObjectManager.createSerializableClass("facto.train", {}, SelfCollection)
function GameManager:run()    
    self:setup()    
    self.event.on_init(function()
        self:init()
    end)
    self.event.on_load(function()
        self:load()
    end)
end 

local instance 
--- Get singleton instance
function GameManager.getInstance(cfg)
    if instance == nil then 
       instance = GameManager(cfg)
       instance:run()
    end 
    return instance
end 

-- @export
return GameManager