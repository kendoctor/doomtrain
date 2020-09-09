local Class = require("facto.class")
local Event = require("facto.event")
local StateModifiers = require("facto.player.statemodifiers")
-- local StatePhases = require("facto.player.statephases")
local playerFactory = require("facto.player.playerfactory").getInstance()
local stateUpdaterFactory = require("facto.player.stateupdaterfactory").getInstance()

require("utils")
local Player = Class.create()
Player.type = "player"

-- Player.

-- {
--     Vigorous = { 0, 5, function() end },
--     Normal = 2,
--     Tired = 3,
--     Exhausted = 4,
--     Unconscious = 5
-- }

function Player:__constructor(props)
    self.props = props.factoobj
    self.id = props.factoobj.index
    -- self.count_joined
    -- self.last_time_joined (game tick)
    -- self.time_joined
    self.max_health = 100
    self.energy = 4160
    self.max_energy = 4160
    self.stamina = 0
    self.max_stamina = 200
    self.brainpower = 0
    self.max_brainpower = 100
    self.eating_capacity = 100
    self.drinking_capacity = 100
    self.eatens = {}

    
    self.state_updaters = {}

    self.runningSpeedModifiers = StateModifiers()
    self.craftingSpeedModifiers = {}
    self.miningSpeedModifiers = {}


    -- self.last_move_tick = nil
    self:initialize()
end 

function Player:initialize()
    local updater = stateUpdaterFactory:create("physiological-needs-updater")
    table.insert(self.state_updaters, updater)
    updater = stateUpdaterFactory:create("stamina-recovery-updater")
    table.insert(self.state_updaters, updater)
    updater = stateUpdaterFactory:create("running-consumption-updater")
    table.insert(self.state_updaters, updater)
    updater = stateUpdaterFactory:create("energy-phase-updater")
    table.insert(self.state_updaters, updater)
    updater = stateUpdaterFactory:create("food-digesting-updater")
    table.insert(self.state_updaters, updater)
end 

function Player:getId()
    return self.id
end 

function Player:hasCharacter()
    if not self.factoobj or not self.factoobj.character then return false end 
    return true
end 

function Player:isValid()
end 

function Player:getRunningSpeed()
end 

function Player:getRunningSpeedModifier()
end 

function Player:getCraftingSpeedModifier()
end 

function Player:getMiningSpeedModifier()
end 

function Player:isMoving()
    return self.factoobj.walking_state.walking
end 

function Player:udpateEnergyPhase()
    local previous_phase 
    local current_phase
    if previous_phase == nil or previous_phase ~=  current_phase then 
        current_phase:update()
    end 
    previous_phase = current_phase
end 

--- Decrease amount of energy.
-- @tparam number amount
-- @treturn number actual decreased amount
function Player:decEnergy(amount)
    local origin = self.energy
    self.energy = self.energy - amount 
    if self.energy < 0 then self.energy = 0 end
    return origin - self.energy
end 

--- Increase amount of energy.
-- @tparam number amount
-- @treturn number actual increased amount
function Player:incEnergy(amount)
    local origin = self.energy
    self.energy = self.energy + amount        
    if self.energy > self.max_energy then self.energy = self.max_energy end 
    return self.energy - origin
end 

function Player:getEnergyPhase()
end 

function Player:getEnergyRatio()
    return self.energy/self.max_energy
end 

--- Decrease amount of stamina.
-- @tparam number amount
-- @treturn number actual decreased amount
function Player:decStamina(amount)
    local origin = self.stamina
    self.stamina = self.stamina - amount 
    --- raise event, stamina is over consumed
    if self.stamina < 0 then self.stamina = 0 end
    return origin - self.stamina
end 

--- Increase amount of stamina.
-- @tparam number amount
-- @treturn number actual increased amount
function Player:incStamina(amount)
    local origin = self.stamina
    self.stamina = self.stamina + amount        
    if self.stamina > self.max_stamina then self.stamina = self.max_stamina end 
    return self.stamina - origin
end 

function Player:isStaminaEmpty()
    return self.stamina == 0
end 

function Player:isStaminaFull()
    return self.stamina == self.max_stamina
end 

function Player:isEnergyEmpty()
    return self.energy == 0
end 

function Player:getStaminaRatio()
    return self.stamina/self.max_stamina
end

function Player:updateStatus()

end 

function Player:updateByQueue(game_tick, player)
    -- frequency , lasting_ticks
    -- if current update will let later update unneeded?
    for key, updater in pairs(self.state_updaters) do 
        if game_tick % updater.cycle_ticks == 0 then 
            updater:update(game_tick, player)
            if not updater:isContinued() then 
                self.state_updaters[key] = nil
            end 
        end 
    end 
end 

function Player:update(game_tick)
    self:updateByQueue(game_tick, self)
    --- @todo raise event for extension to do extra work

    local left = self.factoobj.gui.left
    local p = left["p1"] 
    if not p  then p = left.add({ name = "p1", type="progressbar" }) end 
    p.value = self:getEnergyRatio()

    local p2 = left["p2"] 
    if not p2  then p2 = left.add({ name = "p2", type="progressbar" }) end 
    p2.value = self:getStaminaRatio()

    local b1 = left["b1"] 
    if not b1  then b1 = left.add({ name = "b1", type="button", caption = "eat" }) end 
end 

function Player:getHealth()
end 

function Player:setHealth(health)
end 

-- function Player:cons

function Player:eat(food)
    food = {
        energy = 100,
        digest_time = 1000
    }

    debug("eat food")
    table.insert(self.eatens, { food = food, absorbed_energy = 0 })
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
    debug(factoobj.character ~= nil)
    debug(factoobj.connected)
end 

function Player.on_created(e)
    debug("created")
    local factoobj = game.players[e.player_index]
    assert(factoobj ~= nil)
    debug(factoobj.character ~= nil)
    debug(factoobj.connected)
    -- should be valid player ? maybe still not join the game.    
    playerFactory:create("player", { factoobj = factoobj })
end 

function Player.on_left(e)
    debug("left game")
    -- debug(serpent.block( game.players[e.player_index].valid))
    local factoobj = game.players[e.player_index]
    assert(factoobj ~= nil)
    debug(factoobj.character ~= nil)
    playerFactory:left(factoobj)
end 

function Player.on_built()
end 

local last_move_tick 
function Player.on_moving(e)
    -- -- last_move_tick = last_move_tick or e.tick
    -- -- debug(e.tick - last_move_tick)
    -- -- last_move_tick = e.tick
    -- local player = playerFactory:get(e.player_index)
    -- if player then 
    --     player.last_move_tick = e.tick
    -- end 
end 

Event.on(defines.events.on_player_joined_game, Player.on_joined)
Event.on(defines.events.on_player_created, Player.on_created)
Event.on(defines.events.on_player_left_game, Player.on_left)
Event.on(defines.events.on_player_changed_position, Player.on_moving)
Event.on(defines.events.on_player_respawned, function(e)
    local factoobj = game.players[e.player_index]
    debug("respawned")
    debug(factoobj.character ~= nil)
end)
Event.on(defines.events.on_gui_click, function(e) 
    local player = playerFactory:get(e.player_index)
    player:eat()
end)
Event.on(defines.events.on_player_mined_item, function(e)
    local factoobj = game.players[e.player_index]
    debug("mines item")
end)

Event.on(defines.events.on_player_mined_entity, function(e)
    local factoobj = game.players[e.player_index]
    debug("mines entity")
end)

Event.on(defines.events.on_pre_player_mined_item, function(e)
    local factoobj = game.players[e.player_index]
    -- e.entity.minable = false 
    debug("pre mined item")
end)


-- @export
return Player


-- t = current time
-- b = start value
-- c = change in value
-- d = duration

--  function (float time, float startValue, float change, float duration) {
--      time /= duration / 2;
--      if (time < 1)  {
--           return change / 2 * time * time + startValue;
--      }

--      time--;
--      return -change / 2 * (time * (time - 2) - 1) + startValue;
--  };