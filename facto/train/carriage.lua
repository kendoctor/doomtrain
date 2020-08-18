local Class = require("oop.class")
local Event = require("facto.event")
local carriageFactory = require("facto.train.carriagefactory").getInstance()
local carriageDoorManager = require("facto.train.carriagedoormanager").getInstance()

--- Carriage base class which could be extended for special carriages.
-- @classmod Carriage
local Carriage = Class.create()
-- Carriage type, classes derived from Carriage should have a different type.
Carriage.type = "rolling-stock"

--- Constructor.
function Carriage:__constructor(props)
    props = props or {}
    props.doors = props.doors or {}
    for k,v in pairs(props) do self[k] = v end 
    self:initialize()
end 

--- Initialization for carriage.
function Carriage:initialize()
end 

--- Build carriage such room, doors.
-- @tparam class<Carriage> old_carriage
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function Carriage:build(old_carriage, tiles, lazycalls)
    if old_carriage then 
        self:clone(old_carriage)
    else
        print("building room")
        self:buildRoom(tiles, lazycalls)
        print("building doors")
        self:buildDoors(tiles, lazycalls)
    end 
end 

--- Build the room which is mainly for building stuff.
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function Carriage:buildRoom(tiles, lazycalls)
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

--- Build doors of the carriage for players to exit out.
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function Carriage:buildDoors(tiles, lazycalls)
    local area = self:getBuildingArea()
    local surface = self:getTrainSurface()    
   
    for _, x in pairs( { area.left_top.x - 1, area.right_bottom.x + 0.5 } ) do        
        self:createDoor({ carriage = self }, { x = x, y = area.left_top.y + ((area.right_bottom.y - area.left_top.y) * 0.5) }, tiles, lazycalls)
    end
end 

--- Buildd carriage door.
-- @tparam table props door properties
-- @tparam LuaPosition position door position
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
-- @treturn class<CarriageDoor>
function Carriage:createDoor(props, position, tiles, lazycalls)
    local door, addedcall = carriageDoorManager:createLazyAdded(props)
    door:build(position, tiles, lazycalls, function() 
        self.doors[tostring(door:getId())] = door
        addedcall()
    end)
    return door
end 

--- Clone door from the old surface area.
-- @tparam class<CarriageDoor> source_door
-- @tparam table props properties of the door
function Carriage:createDoorByClone(source_door, props)
    local door = carriageDoorManager:create(props)
    self.doors[tostring(door:getId())] = door
    carriageDoorManager:remove(source_door)
end 

--- Clone carriage from the old.
-- @tparam class<Carriage> old_carriage
function Carriage:clone(old_carriage)
    local restore = function(e)
        -- @todo more accurate and flexiable is to check unit_number in CarriageDoorManager
        if e.source.name ~= "player-port" then return end
        local old_doors = old_carriage.doors
        for k, door in pairs(old_doors) do 
            if door.factoobj == e.source then self:createDoorByClone(door, { factoobj = e.destination, carriage = self }) end 
        end         
    end 
    Event.on(defines.events.on_entity_cloned, restore)
    self:cloneArea(old_carriage)    
    Event.remove(defines.events.on_entity_cloned, restore)
end 

--- Clone area of the source carraige.
-- @tparam class<Carriage> source_carriage
function Carriage:cloneArea(source_carriage)
    print("clone carriage area")
    local source_area = source_carriage:getClonedArea()
    local destination_area = self:getClonedArea()

    source_carriage:getTrainSurface().clone_area({
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

--- Let player enter into the carriage
-- @todo teleport nearby a door
-- @tparam LuaPlayer player
function Carriage:LetPlayerEnter(player)
    local surface = self:getTrainSurface()
    local area = self:getBuildingArea()
    local x_vector = self.factoobj.position.x - player.position.x
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
-- @tparam class<CarriageDoor>
function Carriage:LetPlayerExitFromDoor(player, door)
    local surface = self:getSurfaceOn()
    local door_factoobj = door.factoobj
    local carriage_factoobj = self.factoobj
    -- @fixme if the train aligns horizontally
    local x_vector = (door_factoobj.position.x / math.abs(door_factoobj.position.x)) * 2
    local center_pos = { carriage_factoobj.position.x + x_vector, carriage_factoobj.position.y }
    local target_pos = surface.find_non_colliding_position('character', center_pos, 128, 0.5)
    -- @fixme if failed to teleport
    if target_pos then local result = player.teleport(target_pos, surface) end 
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

--- Convenient function for getting the surface of the train which this carriage is attached.
-- @treturn LuaSurface
function Carriage:getTrainSurface()
    return self.train:getSurface()
end 

--- Get the surface on which this carriage stays on.
-- @treturn LuaSurface
function Carriage:getSurfaceOn()
    if not self.factoobj or not self.factoobj.valid then error("Invalid builtin carriage") end
    return self.factoobj.surface
end 

function Carriage:setTrain(train)
    self.train = train
end 

function Carriage:getTrain()
    return self.train
end 

--- Clear carriage data.
function Carriage:destroy()
    for id, door in pairs(self.doors) do 
        self.doors[id] = nil
        carriageDoorManager:remove(door)
        door:destroy() 
    end 
end 

--- Get id of the carriage.
-- @treturn string|number
function Carriage:getId()
    return tostring(self.factoobj.unit_number)
end 

--- Check if this carriage is a locomotive.
-- @treturn boolean
function Carriage:isLocomotive()
    return false 
end 

-- @export
return Carriage