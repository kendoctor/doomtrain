local Class = require("facto.class")
local EventDispatcher = Class.create()

EventDispatcher.events = {
    on_player_offline = 1,
    on_player_created = 2,
    on_player_connecting = 3,
    on_player_connected = 4,
    on_player_joined = 5
}

function EventDispatcher:__constructor()
    self.handlers = {}
end 

function EventDispatcher:raise(event, data)
    local handler = self.handlers[event] 
    if handler ~= nil then handler(data) end     
end 

function EventDispatcher:on_event(event, handler)
    self.handlers[event] = handler
end 

local Event = EventDispatcher()

local Player = Class.create()
Player.States = {
    offline = 0,
    connecting = 1,
    connected = 2,
    joined = 3  
}

function Player:__constructor(name, is_admin)
    self.name = name or "anonymous"
    self.is_admin = is_admin or false
    self.state = Player.States.offline
end 

local PlayerManager = Class.create()

function PlayerManager:__constructor()
    self.players = {}
end 

function PlayerManager:createPlayer(name, is_admin)
    if self.players[name] ~= nil then return end
    local player = Player(name, is_admin)
    Event:raise(Event.events.on_player_created, { player = player, name = Event.events.on_player_created } )
    self.players[name] = player
    return player
end 

function PlayerManager:connectPlayer(name)
    local player = self.players[name]
    if player == nil or player.state ~= Player.States.offline then return end 
    player.state = Player.States.connecting
    Event:raise(Event.events.on_player_connecting, { player = player, name = Event.events.on_player_connecting } )
     --- connecting logics
     player.state = Player.States.connected
    Event:raise(Event.events.on_player_connected, { player = player, name = Event.events.on_player_connected } )
end 

function PlayerManager:joinPlayer(name)
    local player = self.players[name]
    if player == nil or player.state ~= Player.States.connected then return end
    player.state = Player.States.joined
    Event:raise(Event.events.on_player_joined, { player = player, name = Event.events.on_player_joined } )
end 

function PlayerManager:exitPlayer(name)
    local player = self.players[name]
    if player == nil or player.state == Player.States.offline then return end
    player.state = Player.States.offline
    Event:raise(Event.events.on_player_offline, { player = player, name = Event.events.on_player_offline } )
end 

local Pm = PlayerManager()
Pm:createPlayer("kendoctor")

Event:on_event(Event.events.on_player_created, function(e) 
    print(e.name, e.player.name)
end)

Event:on_event(Event.events.on_player_connecting, function(e) 
    print(e.name, e.player.name)
end)

Event:on_event(Event.events.on_player_connected, function(e) 
    print(e.name, e.player.name)
end)

Event:on_event(Event.events.on_player_joined, function(e) 
    print(e.name, e.player.name)
end)

Event:on_event(Event.events.on_player_offline, function(e) 
    print(e.name, e.player.name)
end)

Pm:createPlayer("jack")
Pm:connectPlayer("kendoctor")
Pm:connectPlayer("jack")
Pm:joinPlayer("jack")
Pm:exitPlayer("jack")
Pm:exitPlayer("kendoctor")