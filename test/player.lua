local Class = require("facto.class")
local Player = Class.create()

function Player:__constructor(lua_object)
    self.joined_times = 0
    self.lua_object = lua_object
end 

function Player:incJoinedTimes()
    self.joined_times = self.joined_times + 1
end 

function Player:isValid()
    return self.lua_object and self.lua_object.valid
end 

function Player:isOnline()
    return self:isValid() and self.lua_object.connected
end 

function Player:hasCharacter()
    return self:isOnline() and self.character ~= nil
end 

local players = {}

function get_player(index)
    return players[tostring(index)]
end

script.on_init(function()
    global.players = players
end)

script.on_load(function()
    players = global.players
    for index, player in pairs(players) do 
        Player:__metalize(player)
    end 
end)

script.on_event(defines.events.on_player_created, function(e)
    players[tostring(e.player_index)] = Player(game.get_player(e.player_index))
end)

script.on_event(defines.events.on_player_joined_game, function(e)
    local player = get_player(e.player_index)
    player:incJoinedTimes()
    game.print(player.joined_times)
    game.print("valid "..tostring(player:isValid()))
    game.print("online "..tostring(player:isOnline()))
    game.print("has character "..tostring(player:hasCharacter()))
end)