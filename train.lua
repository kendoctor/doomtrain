-- debug function 
local n_uid = 0 
local function debug(message)
  game.print(string.format('UID#%s --> %s', n_uid, message))
  n_uid = n_uid + 1
end

function explode(d,p)
    local t, ll, l
    t={}
    ll=0
    if(#p == 1) then
       return {p}
    end
    while true do
       l = string.find(p, d, ll, true) -- find the next d in the string
       if l ~= nil then -- if "not not" found then..
          table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
          ll = l + 1 -- save just after where we found it for searching next time.
       else
          table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
          break -- Break at end, as it should be, according to the lua manual.
       end
    end
    return t
 end

local function ucfirst(str)
    return string.upper( string.sub( str, 1,  1) ) .. 
        string.sub(str, 2)
end

local function camelize(str)
    local tokens = {}
    for i,v in pairs(explode("-", str)) do 
        tokens[i] = ucfirst(v)
    end 
    return table.concat( tokens, "")
end


--- Carriage Door Class.
-- @classmod Door
local Door = {}

--- Create a new door.
-- @tparam Carriage carriage
-- @treturn Door
function Door:new(carriage, entity)
    local o = {
        entity = entity,
        unit_number = nil, -- @todo maybe removed using  getUnitNumber
        carriage = carriage
    }
    setmetatable(o, self)      
    self.__index = self
    return o
end 

--- Initialize door.
-- unit_nubmer and entity property available only when door initialized
-- @tparam Table tiles
-- @tparam LuaPosition position
function Door:init(tiles, position)
    local door 
    local main_tile_name = 'black-refined-concrete'

    if self.entity then 
        self.unit_number = self.entity.unit_number
    else 
        tiles[#tiles+1] =  { name = main_tile_name, position = { position.x, position.y - 1 } }
        tiles[#tiles+1] =  { name = main_tile_name, position = { position.x, position.y } }
        
        door =
            self.carriage:getTrainSurface().create_entity(
            {
                name = 'player-port',
                position = position,
                force = 'neutral',
                create_build_effect_smoke = false
            }
        )

        door.destructible = false
        door.minable = false
        door.operable = false
        
        self.unit_number = door.unit_number
        self.entity = door
    end 
end 

function Door:getUnitNumber()
    if not self.entity or not self.entity.valid then error("Invalid door entity.") end 
    return self.entity.unit_number
end 

--- Carriage Class.
-- @classmod Carriage
local Carriage = {}

-- @section Carriage members

--- Create a new carriage from facto builtin carriage for holding extra information.
-- @tparam Train train The carriage which is attached
-- @tparam LuaEntity builtin_carriage The facto builtin carriage 
-- @tparam int order The order of the carriage in the sequence of the train
-- @treturn Carriage
function Carriage:new(train, builtin_carriage, order)
    local o = {
        train = train,
        builtin_carriage = builtin_carriage,
        order = order,
        doors = {}, -- doors of this carriage 
        unit_number = builtin_carriage.unit_number -- @todo maybe removed using getUnitNumber()
    }
    setmetatable(o, self)      
    self.__index = self
    return o
end 

function Carriage:build(tiles)
    -- create room 
    -- create doors
    -- create entities for different type carriage
    -- type 1. locomotive
    -- type 2. cargo-wagon
    -- type 3. fluid-wagon
    -- type 4. artillery-wagon
    self:createRoom(tiles)
    self:createDoors(tiles)
    -- self:buildCarriageByType()
end 

function Carriage:restore()
    -- find door entities and rebuild doors table
    self:restoreDoors()
end 

function Carriage:buildCarriageByType()
    local type = self.builtin_carriage.type 
    -- camelize 
    local func_name = string.format( "build%s", camelize(type))
    self[func_name]()
end 

-- Build locomotive carriage 
function Carriage:buildLocomotive()
    debug("invoke")
end 

function Carriage:buildCargoWagon()
end 

function Carriage:buildFluidWagon()
end 

function Carriage:buildArtilleryWagon()
end 


--- Get uint_number of this carriage.
-- @treturn uint unit_number
function Carriage:getUnitNumber()
    return self.unit_number
end

--- The area which allows players to build stuffs.
-- @treturn BoundingBox
function Carriage:getBuildingArea()
    -- the area can be configured if put the info into another table, here, hardcoded
    local area = { left_top = {x = -20, y = 0 }, right_bottom = { x = 20, y = 60 } }
    area.left_top.y = ( self.order - 1 ) * 60 
    area.right_bottom.y = self.order * 60
    return area
end 

--- The area which includes building area and other areas such as doors, input and output chests, fluid tanks etc.
-- @todo this function will be removed
-- @treturn BoundingBox
function Carriage:getClonedArea()
    local area = self:getBuildingArea()
    return { { area.left_top.x-2, area.left_top.y }, { area.right_bottom.x+2, area.right_bottom.y } }
end

--- Convenient function for get the surface of the train which this carriage is attached.
function Carriage:getTrainSurface()
    return self.train:getSurface()
end 

--- Get the surface on which this carriage stays on.
-- @treturn LuaSurface
function Carriage:getSurfaceOn()
    if not self.builtin_carriage or not self.builtin_carriage.valid then error("Invalid builtin carriage") end
    return self.builtin_carriage.surface
end 

--- Check whether this carriage is a locomotive.
-- @treturn bool
function Carriage:isLocomotive()
    if not self.builtin_carriage or not self.builtin_carriage.valid then 
        error("Invalid builtin carriage entity")
    end 
    return self.builtin_carriage.type == "locomotive"
end 

--- Get driver of this carriage.
-- @treturn nil|LuaPlayer|LuaEntity
function Carriage:getDriver()
    if not self.builtin_carriage or not self.builtin_carriage.valid then 
        error("Invalid builtin carriage entity")
    end
    return self.builtin_carriage.get_driver()
end 

--- Check whether this carriage has a dirver
-- @treturn bool
function Carriage:hasDriver()
    return not(not self:getDriver())
end 


--- Clone room from the old carriage which has the same builtin_carriage.
-- @tparam Carriage old_carriage
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
function Carriage:cloneArea(old_carriage) 
    local source_area = old_carriage:getClonedArea()
    local destination_area = self:getClonedArea()

    old_carriage:getTrainSurface().clone_area({
        source_area = source_area,
        destination_area = destination_area,
        destination_surface = self:getTrainSurface(),
        clone_tiles = true,
        clone_entities = true,
        clone_decoratives = true,
        clear_destination_entities = true,
        clear_destination_decoratives = true,
        expand_map = true
    })
    
end 
--- Create room for this carriage, such as tiles, decoratives, doors etc.
-- If this carriage is newly created or first initialized(lazy mode, when any player enters the train which this carriage attached in the first time)
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
function Carriage:createRoom(tiles)
    tiles = tiles or {}
    local area = self:getBuildingArea()    
    
    -- @todo decoratives could be configurable
    local main_tile_name = 'black-refined-concrete'

    -- main room tiles
    for x = area.left_top.x, area.right_bottom.x - 1, 1 do
        for y = area.left_top.y + 2, area.right_bottom.y - 3, 1 do
            tiles[#tiles + 1] = {name = main_tile_name, position = {x, y}}
        end
    end

    -- tiles between carriage gaps
    for x = -3, 2, 1 do
        tiles[#tiles + 1] = {name = main_tile_name, position = {x, area.left_top.y + 1}}
        tiles[#tiles + 1] = {name = main_tile_name, position = {x, area.right_bottom.y - 2}}
    end
    for x = -3, 2, 1 do
        tiles[#tiles + 1] = {name = 'hazard-concrete-right', position = {x, area.left_top.y}}
        tiles[#tiles + 1] = {name = 'hazard-concrete-right', position = {x, area.right_bottom.y-1 }}
    end

end

--- Restore doors from exisiting entities
-- if carriage area is cloned from the old or loaded from save
function Carriage:restoreDoors()
    local surface = self:getTrainSurface()
    local door_entities = surface.find_entities_filtered({ area = self:getClonedArea(), name = "player-port" })
    for i, door_entity in pairs(door_entities) do 
        local door = Door:new(self, door_entity)
        door:init()  
        self.doors[door.unit_number] = door
        -- @todo before carriage removed from table, should remove its door in this table
        self.train.trains.doors[door.unit_number] = door
    end 
end 

--- Create doors of the carriage for players to exit out.
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
function Carriage:createDoors(tiles)
    local area = self:getBuildingArea()
    local surface = self:getTrainSurface()
    tiles = tiles or {}

    for _, x in pairs( { area.left_top.x - 1, area.right_bottom.x + 0.5 } ) do

        local door = Door:new(self)
        door:init(tiles, { x = x, y = area.left_top.y + ((area.right_bottom.y - area.left_top.y) * 0.5) } )
  
        self.doors[door:getUnitNumber()] = door
        -- @todo before carriage removed from table, should remove its door in this table
        self.train.trains.doors[door:getUnitNumber()] = door
    end
end 

--- Let player enter into the carriage
-- @tparam LuaPlayer player
function Carriage:LetPlayerEnter(player)
    local surface = self:getTrainSurface()
    local area = self:getBuildingArea()
    local x_vector = self.builtin_carriage.position.x - player.position.x
    local center_pos

    -- left door
    if x_vector > 0 then
        center_pos = { area.left_top.x + 0.5, area.left_top.y + ((area.right_bottom.y - area.left_top.y) * 0.5) }
    else
        center_pos = { area.right_bottom.x - 0.5, area.left_top.y + ((area.right_bottom.y - area.left_top.y) * 0.5) }
    end
    local target_pos = surface.find_non_colliding_position('character', center_pos, 128, 0.5)

    target_pos = target_pos or center_pos
    player.teleport(target_pos, surface)

end

--- Let player exit out the carriage when the player touches the door
-- @tparam LuaPlayer player
function Carriage:LetPlayerExitFromDoor(player, door)
    local surface = self:getSurfaceOn()
    -- @fixme if the train aligns horizontally
    local x_vector = (door.entity.position.x / math.abs(door.entity.position.x)) * 2
    local center_pos = { self.builtin_carriage.position.x + x_vector, self.builtin_carriage.position.y }
    local target_pos = surface.find_non_colliding_position('character', center_pos, 128, 0.5)

    if target_pos then 
        local result = player.teleport(target_pos, surface)
    end 
end 

function Carriage:__tostring()
    return string.format(
        "Carriage > type: %s, unit_number: %s, attached train's id: %s, order: %s",
        self.builtin_carriage.type,
        self:getUnitNumber(),
        self.train:getId(),
        self.order
    )
end 


--- Train Class.
-- @classmod Train
local Train = {}

-- @section Train members

--- Create a new train from facto built-in train object.
-- @tparam LuaTrain builtin_train facto built-in train
-- @tparam Trains trains 
-- @tparam LuaSurface 
-- @treturn Train
function Train:new(builtin_train, trains)
    local o = {
        is_load_from_save = false, -- if this train loaded from save
        id = builtin_train.id, -- @fixme maybe builtin_train not valid
        builtin_train = builtin_train,
        trains = trains,
        carriages = {} -- carriages of the train
    }
    setmetatable(o, self)
    self.__index = self
    return o
end 

--- Get Id of the train.
-- @treturn uint
function Train:getId()
    return self.id
end

--- Get surface name of this train.
-- This should be unique, for convient, using prefix to identify this surface which belongs to one train
-- @treturn string
function Train:getSurfaceName()
    return self.trains.constants.TRAIN_SURFACE_PREFIX_NAME..self:getId()
end

-- Get surface of this train.
-- @treturn LuaSurface
function Train:getSurface()
    if not self.surface or not self.surface.valid then error("Invalid surface.") end
    return self.surface
end

-- @todo
function Train:getMainLocomotive()
    return 
end 

--- Initialize the train data, such as surface, tiles and entities, etc. 
-- 1. train destoryed, the surface released
-- 2. train's carriage destoryed or mined and no another train created, the old surface can be reused
-- 3. trains' carriage destoryed or disconnected or mined and another train created, the old surface can be resused and created a new one for another train
-- 4. trains' carriages connected, one of the trains' surface can be reused and another one could be release or be reserved for later usage
-- these conditions above, should be considered for performance refactoring
function Train:init()
    local tiles = {}

    self:createSurface(tiles)
    self:createCarriages(tiles)

    if #tiles > 0 then 
        self.surface.set_tiles(tiles, true)
    end 
end 

--- Create surface for the train.
-- When game loaded, the surface of trains recreated by game from save
-- If new train created, create a new surface for this train
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
function Train:createSurface(tiles)
    local surface_name = self:getSurfaceName()
    local surface = game.surfaces[surface_name]

    -- @todo chart surface if the train.force == player.force
    if not surface then
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
    else
        self.is_load_from_save = true
    end  

    self.surface = surface 
    return surface
end

--- Create carriage from facto built-in carriage enity
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
-- @tparam LuaEntity builtin_carriage
-- @tparam uint carriage_order
-- @treturn Carriage
function Train:createCarriage(tiles, builtin_carriage, carriage_order)

    if not builtin_carriage or not builtin_carriage.valid then error("Invalid builtin carriage entity.") end 

    local new_carriage = Carriage:new(self, builtin_carriage, carriage_order )
    -- if the train load from save 

    local old_carriage = self.trains:getCarriageByBuiltinCarriage(builtin_carriage)  
    if old_carriage then new_carriage:cloneArea(old_carriage) end 

    if self.is_load_from_save or old_carriage then 
        new_carriage:restore()
    else 
        new_carriage:build(tiles)     
    end 
    
    return new_carriage
end 

--- Create carriages for this train.
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
function Train:createCarriages(tiles)
    if not self.builtin_train or not self.builtin_train.valid then 
        error("Invalid builtin train")
    end 
    -- since newly created train maybe will reorder its carriages due to connecting locomotives
    -- this maybe will disorder all layouts in the carriage which can be fixed manually
    -- but, here, if first layout put down in carriage, do remember its direction ?
    local carriage_order = 1
    for _, builtin_carriage in pairs(self.builtin_train.carriages) do

        local new_carriage = self:createCarriage(tiles, builtin_carriage, carriage_order)

        self.carriages[carriage_order] = new_carriage
        -- @todo if the same unit_number old carriage exists, before new carriage replacing it in the table
        -- should clear the old carriage data
        self.trains.carriages[new_carriage:getUnitNumber()] = new_carriage
        carriage_order = carriage_order + 1
        debug(new_carriage)
    end
end 

--- Get train meta info
-- @treturn string
function Train:__tostring()
    return string.format(
        "Train > id: %s, surface name: %s, count of carriages: %s",
        self:getId(),
        self:getSurfaceName(),
        #self.carriages
    )
end


--- Trains Class.
-- @classmod Trains this class only has one global object using singleton pattern
-- manage all trains in game 

local Trains = {}

-- constants 
Trains.constants = {
    TRAIN_SURFACE_PREFIX_NAME = 'train-surface-'
}

-- @section Trains members

--- Create trains object.
-- @treturn Trains
function Trains:new()
    local o = {
        is_loaded = false, -- loaded once when game started
        trains = {}, -- hold all trains info
        carriages = {}, -- this table which holds all carriages for easy finding 
        doors = {} -- this table which holds all doors of carriage for easy finding carriage which the door belongs to 
    }
    setmetatable(o, self)
    self.__index = self
    return o
end 

--- Create a global object for Trains class.
-- static function 
-- singleton pattern, only exists one trains object in global
-- @treturn Trains
function Trains.getInstance()
    if not Trains._instance then 
        Trains._instance = Trains:new()
    end 
    return Trains._instance
end 

--- Count all the trains in the table.
-- @treturn uint 
function Trains:getCountOfTrains()
    local c = 0
    for _,v in pairs(self.trains) do
        c = c + 1
    end 
    return c
end 

--- Count all the carriages in the table.
-- @treturn uint 
function Trains:getCountOfCarriages()
    local c = 0
    for _,v in pairs(self.carriages) do
        c = c + 1
    end 
    return c
end 


--- Get carriage by the unit_number of one builtin carriage.
-- @tparam uint unit_number
-- @treturn Carriage 
function Trains:getCarriageByUnitNumber(unit_number)
    return self.carriages[unit_number]
end

--- Get carriage by the builtin carriage which is bound.
-- @tparam LuaEntity bultin_carriage
-- @treturn Carriage 
function Trains:getCarriageByBuiltinCarriage(builtin_carriage)
    if not builtin_carriage or not builtin_carriage.valid then error("Invalid builtin carriage") end 
    return self:getCarriageByUnitNumber(builtin_carriage.unit_number)
end 

--- Get train by the unit_number of one builtin carriage.
-- @tparam LuaEntity bultin_carriage
-- @treturn Train 
function Trains:getTrainByBuiltinCarriage(builtin_carriage)
    local carriage = self:getCarriageByBuiltinCarriage(builtin_carriage)
    if carriage then return carriage.train end 
    return nil
end 

--- Get carriage by one door entity which belongs to this carriage
-- @tparam LuaEntity door_entity 
-- @treturn Door
function Trains:getDoorByEntity(door_entity)
    if not door_entity or not door_entity.valid then error("Invalid door entity") end  
    return self.doors[door_entity.unit_number]
end

--- Remove carriage from the table by its unit_number.
-- @tparam uint unit_number
function Trains:removeCarriageByUnitNumber(unit_number)
    self.carriages[unit_number] = nil
end 

--- Load train from save with facto builtin train for holding extra info.
-- @tparam LuaTrain builtin_train 
-- @treturn Train
function Trains:createTrain(builtin_train)
    if not builtin_train or not builtin_train.valid then error("Invalid builtin train.") end 
    local new_train = Train:new(builtin_train , self)
    new_train:init()
    self.trains[new_train:getId()] = new_train
    return new_train 
end 

--- Initialize all trains of all expected surfaces
-- since each train has its surface attched, expected surfaces should not be train surfaces
-- building train in train's carriage is not allowed
-- @tparam table surfaces an array of surfaces which trains stay on
function Trains:load(surfaces)
    if not self.is_loaded then 
        self.is_loaded = true 
        surfaces = surfaces or { game.surfaces[1] }
        for _, surface in pairs(surfaces) do 
            for _, builtin_train in pairs(surface.get_trains()) do 
                self:createTrain(builtin_train)
            end 
        end 
        debug(self)
    end 
end

--- Remove train by its id.
-- remove the train and clear its data
-- @tparam uint train_id
function Trains:removeTrain(train_id)
    -- clear train from table
    -- clear old carriages(obsolote or invalid) from table
    local train_to_remove = self.trains[train_id]
    if train_to_remove then 
        --if the carriage of one train was disconnected, that will trigger two defines.events.on_train_created events
        -- L-2-3-4  => L-2 and 3-4, old_train_id_1 and old_train_id_2 all will be valid
        -- if all old carriages cleared in the table in one event will cause in another event, can not find old carriages information
        -- that will lose area clone data, how to keep consistency of trains.carriages table
        -- self.carriages[carriage:getUnitNumber()] = nil
        -- It only consider destoryed or mined carriage, its data will not be recovered for new train
        -- otherwise, trains.carriages table will be fixed properly at last after two on_train_created events triggered
        -- it means old carriages which are still exisiting will be all replaced by newly-created carriages in trains.carriages table

        -- @todo: train_to_remove.destory()
        self.trains[train_id] = nil
    end 
end 

--- Get trains meta info
-- @treturn string
function Trains:__tostring()
    return string.format(
        "Trains > _instance: %s, loaded: %s, counts of trains: %s, count of carriages: %s", 
        not(not self._instance), 
        self.is_loaded, 
        self:getCountOfTrains(), 
        self:getCountOfCarriages()
    )
end 


--- singleton for Trains Class
local trains = Trains.getInstance()

--- static functions
-- @section Event handlers

--- Event handler when player exit the train
-- @tparam Event e
function Trains.on_player_exits_train(e)
    local player = game.get_player(e.player_index)
    -- check if the player stays on a train's surface
    -- if the surface of one train named like "train-surface-" + train_id, only check the prefix which can determine whether the player stays on one train
    local surface_on  = player.surface  
  
    -- if string.starts(surface_on.name, Trains.constants.TRAIN_SURFACE_PREFIX_NAME) then 
    local prefix = string.sub (surface_on.name, 1, string.len(Trains.constants.TRAIN_SURFACE_PREFIX_NAME))
    if prefix ==  Trains.constants.TRAIN_SURFACE_PREFIX_NAME then
        -- player stays on one train 
        -- find the exit portal by the current position of the player
        -- via the player port entity found which plays as a door, get carriage of this door
        -- teleport the player to the surface which the carriage stays on and nearby this carriage
        local door_entity = surface_on.find_entity('player-port', player.position)
        if door_entity then 
            local door = trains:getDoorByEntity(door_entity)
            if door then door.carriage:LetPlayerExitFromDoor(player, door) end 
        end 
    end 
end 


--- Event handler when player enters the train.
-- listen event defines.events.on_player_driving_changed_state
-- if the player enter into a locomotive
-- first press enter key, be a driver or a passenger
-- second press enter key, enter the carriage room
-- @tparam Event e
function Trains.on_player_enters_train(e)
    -- if Players defined, should be like this players.getByIndex(e.player_index)
    local player = game.get_player(e.player_index)
    -- vehicle including cars, tanks, but, here expects carriages of train
    -- check types of each vehicle which can determine this vehicle is type of rolling stock
    -- but, here, using another way, check whether the entity.train is nil or valid one
    -- local vehicle = e.entity 
    local carriage = trains:getCarriageByBuiltinCarriage(e.entity)
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

-- Event handler when player mined the train or the train was destoryed.
-- if train only has one carriage, when player mined this carriage or destroyed
-- facto has no on_destoryed event for train
-- @tparam Event e
function Trains.on_player_mined_or_destroyed(e)
    if e.entity and e.entity.train then
      if #e.entity.train.carriages == 1 then
        trains:removeTrain(e.entity.train.id)
      end 
      trains:removeCarriageByUnitNumber(e.entity.unit_number)
      debug(trains)
    end
end 


--- Event handler when new train/s created(disconnection or connection of carriages will cause creating new trains).
-- this event will be triggered when train built by players, 
-- train disconnecting or connecting, one of carriages of train mined or destoryed
-- (at least still have another carriage left for this train(but this train actually is  a new one with a new train id) )
-- @tparam Event e
function Trains.on_created(e)

    trains:createTrain(e.train)

    trains:removeTrain(e.old_train_id_1)
    trains:removeTrain(e.old_train_id_2)
    debug(trains)
end


--- Event handler when game loaded.
-- When game started, initialize trains of surfaces
-- since facto api has no on_loaded event, only on_tick event can be used for initialization
-- @tparam Event e
function Trains.on_init(e)
    -- default, only one nauvis surface 
    -- it can accept more open world map surfaces for surfaces parameters
    trains:load()
   
end 

-- @export trains
return trains
