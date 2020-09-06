local Class = require("facto.class")
local Event = require("facto.event")
local AbstractFactory = require("facto.abstractfactory")

--- Train factory for creating different types of train
-- Centralized management of train instances for facto data serialization
-- @classmod TrainFactory
local PlayerFactory = Class.extend({}, AbstractFactory)

--- Initialization
function PlayerFactory:initialize()
    self.online  = {}
    self.offline = {}
    -- self.instance = self.online + self.offline
    -- self.banned = {}
end 

function PlayerFactory:join(factoobj)
    local player = self:get(factoobj.index)
    assert(player ~= nil)
    player.factoobj = factoobj
    -- debug(serpent.block(player))
    self.online[tostring(id)] = player    
end 

function PlayerFactory:left(factoobj)
    local player = self:get(factoobj.index)
    assert(player ~= nil) 
    player.factoobj = factoobj
    -- debug(serpent.block(player))
    self.online[tostring(id)] = nil
end 

--- Setup train factory
-- @todo using cfg
function PlayerFactory:setup()    
    local class = require("facto.player.player")
    self:register(class.type, class)
end 

-- @section static members

--- Return a global unique key
-- @treturn string
function PlayerFactory.guid()
    return "facto.player.playerfactory"
end 

local instance 
--- Get singleton instance
function PlayerFactory.getInstance()
    if instance == nil then 
       instance = PlayerFactory()
       instance:setup()      
    end 
    return instance
end 

Event.on_nth_tick(1, function() 
    if instance then 
        for _,player in pairs(instance.online) do 
            if player:hasCharacter() then  player:update(game.tick) end 
        end 
    end 
end)

-- @export
return PlayerFactory