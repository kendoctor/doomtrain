local Class = require("facto.class")
local Event = require("facto.event")
-- Avoid circular require
local trainFactory = require("facto.train.trainfactory").getInstance()
local carriageFactory = require("facto.train.carriagefactory").getInstance()
local carriageDoorManager = require("facto.train.carriagedoormanager").getInstance()

--- Train class
-- It could be extended for special train
-- @classmod Train
local Train = Class.create()
-- Train type, classes derived from Train should have a different type.
Train.type = "common-train"

-- @section Constants
Train.constants = {
    TRAIN_SURFACE_PREFIX_NAME = "train-surface-"
}

-- @section Members
--- Constructor
function Train:__constructor(props)
    props = props or {}
    for k,v in pairs(props) do self[k] = v end 
    self:initialize()
end 

--- Initialize the train.
function Train:initialize()
    local tiles, lazycalls = {}, {}

    if self.factoobj == nil then error("Train:initialize, invalid factoobj") end 
    self.id = self.factoobj.id
    self.carriages = {}
    self:createSurface(tiles, lazycalls)
    self:build(tiles, lazycalls)     
end 

--- Get Id of the train.
-- @treturn string|number
function Train:getId()
    return self.id
end 

--- Create surface of the train.
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
-- @treturn LuaSurface
function Train:createSurface(tiles, lazycalls)
    -- @fixme should trigger error info
    if game == nil then return end 
    local surface_name = self:getSurfaceName()
    local surface 
    local map_gen_settings = {
        ['width'] = 2,
        ['height'] = 2,
        ['water'] = 0,
        ['starting_area'] = 1,
        ['cliff_settings'] = {cliff_elevation_interval = 0, cliff_elevation_0 = 0},
        ['default_enable_all_autoplace_controls'] = true,
        ['autoplace_settings'] = {
            ['entity'] = {treat_missing_as_default = false},
            ['tile'] = {treat_missing_as_default = true},
            ['decorative'] = {treat_missing_as_default = false}
        }
    }

    surface = game.create_surface(surface_name, map_gen_settings)
    surface.freeze_daytime = true
    surface.daytime = 0.1
    surface.request_to_generate_chunks({16, 16}, 1)
    surface.force_generate_chunk_requests()
    -- clear default tiles 
    for _, tile in pairs(surface.find_tiles_filtered({area = {{-2, -2}, {2, 0}}})) do
        tiles[#tiles+1] = { name = 'out-of-map', position = tile.position } 
    end
    self.surface = surface 
    return surface
end

--- Build the train,such as room, doors, decoratives of ground.
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function Train:build(tiles, lazycalls)
    local facto_carriages     

    if self.factoobj then facto_carriages = self.factoobj.carriages end 
    facto_carriages = facto_carriages or {}
    for order, factoobj in ipairs(facto_carriages) do
        self:addCarriage({ factoobj = factoobj, train = self, order = order }, tiles, lazycalls)        
    end 
    if #tiles > 0 then self.surface.set_tiles(tiles, true) end 
    if #lazycalls > 0 then 
        for _,lazycall in ipairs(lazycalls) do lazycall()  end 
    end 
end 

--- Add carriage for the train.
-- @tparam table props carriage properties
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
-- @treturn class<Carriage>
function Train:addCarriage(props, tiles, lazycalls)
    local old_carriage = carriageFactory:get(props.factoobj.unit_number)        
    local new_carriage = carriageFactory:create(props.factoobj.type, props)
    new_carriage:build(old_carriage, tiles, lazycalls)
    self.carriages[props.order] = new_carriage
    if old_carriage then old_carriage.train:removeCarriage(old_carriage) end
    return new_carriage
end 

--- Remove carriage from the train, when destroyed, mined, or train destroyed.
-- If the carriage is the last one of the train, also destroy the train
-- @tparam class<Carriage>
function Train:removeCarriage(carriage)
    self.carriages[carriage.order] = nil
    carriageFactory:remove(carriage)
    carriage:destroy()
    if next(self.carriages) == nil then self:destroy() end    
end 

--- Clear train data.
function Train:destroy()
    if self.surface then game.delete_surface(self.surface) end 
    trainFactory:remove(self)
end 

--- Get surface of the train.
function Train:getSurface()
    return self.surface
end 

--- Get surface name of this train.
-- This should be unique, for convient, using prefix to identify this surface which belongs to one train
-- @treturn string
function Train:getSurfaceName()
    if self.surface and self.surface.valid then return self.surface.name end 
    return Train.constants.TRAIN_SURFACE_PREFIX_NAME..self:getId()
end

--- Check if the train has a valid facto object.
-- If invalid, that means this train already outdated
-- @treturn boolean
function Train:isValid()
    if self.factoobj and self.factoobj.valid then return true end 
    return false 
end 

--- Event handler when new train/s created(disconnection or connection of carriages will cause creating new trains).
-- this event will be triggered when train built by players, 
-- train disconnecting or connecting, one of carriages of train mined or destoryed
-- (at least still have another carriage left for this train(but this train actually is  a new one with a new train id) )
-- @tparam Event e
function Train.on_created(e)
    trainFactory:create(Train.type, { factoobj = e.train })
end

--- Event handler when player mined the train or the train was destoryed.
-- if train only has one carriage, when player mined this carriage or destroyed
-- facto has no on_destroyed event for train
-- @fixme if any player stays on this carriage, teleport them to a proper position of the surface which this carriage was on
-- @tparam Event e
function Train.on_player_mined_or_destroyed(e)
    if e.entity and e.entity.train then
        local carriage = carriageFactory:get(e.entity.unit_number)
        if carriage then carriage.train:removeCarriage(carriage) end 
    end
end 

--- Event handler when player enters the train.
-- listen event defines.events.on_player_driving_changed_state
-- if the player enter into a locomotive
-- first press enter key, be a driver or a passenger
-- second press enter key, enter the carriage room
-- @tparam Event e
function Train.on_player_enters_train(e)
    -- if Players defined, should be like this players.getByIndex(e.player_index)
    local player = game.get_player(e.player_index)
    -- vehicle including cars, tanks, but, here expects carriages of train
    -- check types of each vehicle which can determine this vehicle is type of rolling stock
    -- but, here, using another way, check whether the entity.train is nil or valid one
    -- local vehicle = e.entity 
    local carriage = carriageFactory:get(e.entity.unit_number)
    if not carriage then return end 
    -- if not vehicle or not vehicle.valid then error("Invalid vehicle") end 
    if not player or not player.valid then  error("Invalid player ") end 
    if player.driving and carriage:isLocomotive() then return end 
    -- player ready to enter the train room    
    if carriage and player.surface == carriage:getSurfaceOn() then 
        -- @todo needs Player class to hold extra info for which side the player entered from
        -- solution : when enter the locomotive, directly let player enter the room, 
        -- when the player exit out, set the player as driver if there's no driver in this locomotive
        -- if player.driving and carriage:isLocomotive() then return end 
        carriage:LetPlayerEnter(player)
    end
end

--- Event handler when player exit the train
-- entity -> door -> carrige -> exit
-- @tparam Event e
function Train.on_player_exits_train(e)
    local player = game.get_player(e.player_index)
    -- check if the player stays on a train's surface
    -- if the surface of one train named like "train-surface-" + train_id, only check the prefix which can determine whether the player stays on one train
    local surfaceon  = player.surface  
  
    -- if string.starts(surface_on.name, Trains.constants.TRAIN_SURFACE_PREFIX_NAME) then 
    local prefix = string.sub (surfaceon.name, 1, string.len(Train.constants.TRAIN_SURFACE_PREFIX_NAME))
    if prefix ==  Train.constants.TRAIN_SURFACE_PREFIX_NAME then
        -- player stays on one train 
        -- find the exit portal by the current position of the player
        -- via the player port entity found which plays as a door, get carriage of this door
        -- teleport the player to the surface which the carriage stays on and nearby this carriage
        local factoobj = surfaceon.find_entity('player-port', player.position)
        if factoobj then 
            local door = carriageDoorManager:get(factoobj.unit_number)
            if door then door.carriage:LetPlayerExitFromDoor(player, door) end 
        end 
    end 
end 

Event.on(defines.events.on_train_created, Train.on_created)
Event.on(defines.events.on_entity_died, Train.on_player_mined_or_destroyed)
Event.on(defines.events.on_player_mined_entity, Train.on_player_mined_or_destroyed)
Event.on(defines.events.on_player_driving_changed_state, Train.on_player_enters_train)
Event.on(defines.events.on_player_changed_position, Train.on_player_exits_train)

-- @export
return Train