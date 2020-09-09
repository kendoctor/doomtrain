local Class = require("facto.class")
-- local Event = require("facto.event")
local AbstractFactory = require("facto.abstractfactory")

--- Player factory for creating different types of player
-- Centralized management of player instances for facto data serialization
-- @classmod TrainFactory
local PlayerFactory = Class.extend({}, AbstractFactory)
local Event
local Events = {
    "on_player_created",
    "on_player_joined_game",
    "on_player_left_game"
}

--- Initialization
function PlayerFactory:initialize()
    self.online  = {}
end 

function PlayerFactory:registerClasses()
    local class = require("facto.player.player")
    self:register(class.type, class)   
end 

--- Setup train factory
-- @todo using cfg
function PlayerFactory:setup()   
    self:registerClasses()
    Event = self.Event 
    Event.register(Events)
    Event.on(Event.facto.on_player_created, function(e) self:onPlayerCreated(e) end)
    Event.on(Event.facto.on_player_joined_game, function(e) self:onPlayerJoinedGame(e) end)
    Event.on(Event.facto.on_player_left_game, function(e) self:onPlayerLeftGame(e) end)
end 

function PlayerFactory:onPlayerCreated(e)
    local player = self:create("player", game.get_player(e.player_index))
    Event.dispatch(Event.custom.on_player_created, { player = player } )
end 

function PlayerFactory:onPlayerJoinedGame(e)
    local player = self:get(e.player_index)
    self.online[player:getId()] = player   
    player:incJoinedTimes() 
    Event.dispatch(Event.custom.on_player_joined_game, { player = player } )
end 

function PlayerFactory:onPlayerLeftGame(e)
    local player = self:get(e.player_index)
    self.online[player:getId()] = nil    
    Event.dispatch(Event.custom.on_player_left_game, { player = player } )
end 

-- @section static members
--- Return a global unique key
-- @treturn string
function PlayerFactory.guid()
    return "facto.player.playerfactory"
end 

-- @export
return PlayerFactory