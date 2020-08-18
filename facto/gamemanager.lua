require "utils"
local Class = require("oop.class")
local Event = require("facto.event")

--- Manage the game objects and resources.
-- @classmod GameManager
local GameManager = Class.create()
local persisted_classes = {}

-- GameManager.persisted_classes = persisted_classes
-- config : new game cfg, and cfg could be changed in game
--- modules should be registered 
--- modules could be registered lately
--- modules registered according to a cfg set
function GameManager.setup(cfg)
--- modules need to be registered
--- modules need only to be required
    -- for _, module  in pairs(cfg.modules)  
    --     local class = require(module)
    --     -- assert(Class.subclass(class) == PersistedClass)  
    --     if is_persisted_class then 
    --         GameManager.register(class.guid(), class)
    --     end 
    -- end 
    local class = require("facto.train.trainfactory")
    GameManager.register(class)
    class = require("facto.train.carriagefactory")
    GameManager.register(class)    
    class = require("facto.train.carriagedoormanager")
    GameManager.register(class)
end 

--- Register persisted class singleton.
function GameManager.register(class)
    -- assert(Class.isclass(class))    
    persisted_classes[class.guid()] = class.getInstance()
end 

--- Invoked when script.on_init triggered.
function GameManager.init()
    -- via cfg. init feature     
    global.facto = global.facto or {} 
    for guid, persisted in pairs(persisted_classes) do
        -- if global.facto[guid] == nil, that means some features added
        -- should not change this data in on load        
        if global.facto[guid] == nil then global.facto[guid] = {} end
        persisted:init(guid, global.facto[guid])
    end     
end 

-- Inovked when script.on_load triggered
function GameManager.load()   
    log(serpent.block(global.facto, {comment=true}))
    -- if global.facto == nil, that means game already broken
    for guid, persisted in pairs(persisted_classes) do
        -- if global.facto[guid] == nil, that means some features added
        -- should not change this data in on load        
        persisted:load(guid, global.facto[guid])
    end 
end 

--- @todo if new features added into scenario, could we still load old save game ?
-- 1. on_init will not trigger, if not scenario changed ?
-- on_configuration_changed ? need to test this event when will be triggered
-- local Train = GlobalObjectManager.createSerializableClass("facto.train", {}, SelfCollection)
function GameManager.run()    
    GameManager.setup(cfg)    
    Event.on_init(function()
        GameManager.init()
    end)
    Event.on_load(function()
        GameManager.load()
    end)
end 

-- @export
return GameManager