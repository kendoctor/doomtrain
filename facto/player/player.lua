local Class = require("oop.class")
local Event = require("facto.event")
local playerFactory = require("facto.player.playerfactory").getInstance()

require("utils")
local Player = Class.create()
Player.type = "player"

function Player:__constructor(props)
    self.props = props.factoobj
    self.id = props.factoobj.index
    -- self.count_joined
    -- self.last_time_joined (game tick)
    -- self.time_joined
    self.max_health = 100
    self.energy = 416
    self.max_energy = 416
    self.max_stamina = 100
    self.eating_capacity = 100
    self.drinking_capacity = 100
    self.digesting_queque = {}
    self.state_update_queue = {}
    self:initialize()
end 

function Player:initialize()
    local basic_energy_consumption = {
        cycle_ticks = 60,
        update = function() 
            self:decEnergy(1)
            debug('updated')
        end,
        update_cycles = 0,
        updated_cycles = 0
    }
    table.insert(self.state_update_queue, basic_energy_consumption)
end 

function Player:getId()
    return self.id
end 

function Player:isValid()
end 

function Player:decEnergy(amout)
    self.energy = self.energy - amout 
    if self.energy < 0 then self.energy = 0 end
    return self.energy
end 

function Player:incEnergy(amout)
    self.energy = self.energy + amout
    if self.energy > self.max_energy then self.energy = self.max_energy end 
    return self.energy
end 

function Player:getEnergyRatio()
    return self.energy/self.max_energy
end 

function Player:updateStatus()

end 

function Player:updateByQueue(game_tick)
    -- frequency , lasting_ticks
    -- if current update will let later update unneeded?
    for key,state_update in pairs(self.state_update_queue) do 
        if game_tick % state_update.cycle_ticks == 0 then 
            if state_update.update_cycles == 0 or (state_update.update_cycles - state_update.updated_cycles) > 0 then 
                --- if update return true, then remove this update
                state_update.update()
                state_update.updated_cycles = state_update.updated_cycles + 1
            else
                self.state_update_queue[key] = nil
            end 
        end 
    end 
end 


function Player:update(game_tick)
    self:updateByQueue(game_tick)
    --- @todo raise event for extension to do extra work

    local left = self.factoobj.gui.left
    local p = left["p1"] 
    if not p  then p = left.add({ name = "p1", type="progressbar" }) end 
    p.value = self:getEnergyRatio()

    --- update state 
    --- trigger events, such die, hungry...
    -- local p
    
    -- p[cycle_ticks] = {}

    -- for cycle_ticks, updates in pairs(state_update_table) do 
    --     if game.tick % cycle_ticks == 0 then 
    --         for _, update in pairs(updates) do 

    --         end 
    --     end 
    -- end 

    --- for one state : energy, health, stamina
    --- mutiple state 
    --- permanent 
    -- local c = { cycle_ticks = 10, consumption = 10, cycle_times = 100, cycle_finished = 1 }
    -- if game.tick % c.tick == 0 then 
    --     -- energy = energy - c.consumption could be negative
    -- end 
    
    -- tick, consumption
    -- constantly consume energy ,  basic energy consuming
    -- constantly recovery energy , food digesting
    -- action consume energy, for example, walking, mining, running, attacking
    -- tick action, and status action
    

end 

function Player:getHealth()
end 

function Player:setHealth(health)
end 

-- function Player:cons

function Player:eat(food)
    -- Action
    -- Food : energy, digesting time
    -- raise event 
    -- eaten 
    -- digesting queue of eaten foods
    -- when digested one food -> transformed into energy    
end 

function Player:drink(drink)
end 

function Player:getSpeed()
end 

function Player:setSpeed(speed)
end 

function Player.on_joined(e)
    debug("joined")
    -- debug(serpent.block( game.players[e.player_index].valid))
    local factoobj = game.players[e.player_index]
    assert(factoobj ~= nil)
    playerFactory:join(factoobj)
end 

function Player.on_created(e)
    debug("created")
    --- player meta data of this map 
    --- player meta data of the new game 
    --- Should be nil, if the game create a new one
    -- local player = playerFactory:get(e.player_index)
    -- if player then 
    -- end 
    local factoobj = game.players[e.player_index]
    assert(factoobj ~= nil)
    -- should be valid player ? maybe still not join the game.
    playerFactory:create("player", { factoobj = factoobj })
end 

function Player.on_left(e)
    debug("left game")
    -- debug(serpent.block( game.players[e.player_index].valid))
    local factoobj = game.players[e.player_index]
    assert(factoobj ~= nil)
    playerFactory:left(factoobj)
end 

function Player.on_built()
end 

Event.on(defines.events.on_player_joined_game, Player.on_joined)
Event.on(defines.events.on_player_created, Player.on_created)
Event.on(defines.events.on_player_left_game, Player.on_left)


-- @export
return Player
