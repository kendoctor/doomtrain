local Class = require("oop.class")
local Event = require("facto.event")
local CarriageFactory = CarriageFactory or require("facto.train.carriagefactory")
local CarriageDoorManager = require("facto.train.carriagedoormanager")

local Carriage = Class.create()
Carriage.type = "rolling-stock"

function Carriage:__constructor(props)
    props = props or {}
    props.doors = props.doors or {}
    for k,v in pairs(props) do self[k] = v end 
    self:initialize()
end 

function Carriage:initialize()
end 

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

--- Create doors of the carriage for players to exit out.
-- @tparam table tiles a reference table for holding all tiles data of the train, since consider to surface.set_tiles only once
function Carriage:buildDoors(tiles, lazycalls)
    local area = self:getBuildingArea()
    local surface = self:getTrainSurface()    
   
    for _, x in pairs( { area.left_top.x - 1, area.right_bottom.x + 0.5 } ) do        
        self:createDoor({ carriage = self }, { x = x, y = area.left_top.y + ((area.right_bottom.y - area.left_top.y) * 0.5) }, tiles, lazycalls)
        -- local door = Door:new({ carriage = self })
        -- door:create(tiles, lazyCalls, { x = x, y = area.left_top.y + ((area.right_bottom.y - area.left_top.y) * 0.5) })        
        -- lazyCalls[#lazyCalls+1] = function()
        --     self.doors[door:getUnitNumber()] = door
        --     -- @todo before carriage removed from table, should remove its door in this table
        --     self.train.trains.doors[door:getUnitNumber()] = door
        -- end 
    end
end 

function Carriage:createDoor(props, position, tiles, lazycalls)
    local door, addedcall = CarriageDoorManager.createLazyAdded(props)
    door:build(position, tiles, lazycalls, function() 
        self.doors[tostring(door:getId())] = door
        addedcall()
    end)
    return door
end 

function Carriage:createDoorByClone(source_door, props)
    local door = CarriageDoorManager.create(props)
    self.doors[tostring(door:getId())] = door
    CarriageDoorManager.remove(source_door)
end 

function Carriage:clone(old_carriage)
    local restore = function(e)
        if e.source.name ~= "player-port" then return end
        local old_doors = old_carriage.doors
        for k, door in pairs(old_doors) do 
            if door.factoobj == e.source then 
                self:createDoorByClone(door, { factoobj = e.destination, carriage = self })
                -- -- local new_door = Door:new({ builtin_entity = e.destination, carriage = self })
                -- self.doors[new_door:getUnitNumber()] = new_door
                -- -- @todo before carriage removed from table, should remove its door in this table
                -- self.train.trains.doors[new_door:getUnitNumber()] = new_door
                -- -- clear old door
                -- self.train.trains.doors[e.source.unit_number] = nil
            end 
        end         
    end 
    Event.on(defines.events.on_entity_cloned, restore)
    self:cloneArea(old_carriage)    
    Event.remove(defines.events.on_entity_cloned, restore)
end 

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

--- Convenient function for get the surface of the train which this carriage is attached.
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

function Carriage:destroy()
    for id, door in pairs(self.doors) do 
        self.doors[id] = nil
        CarriageDoorManager.remove(door)
        door:destroy() 
    end 
end 

function Carriage:getId()
    return tostring(self.factoobj.unit_number)
end 

function Carriage:isLocomotive()
    return false 
end 

function Carriage.load()
    for key, value in pairs(Carriage.all) do 
        local class = CarriageFactory.getCarriageClass(value.factoobj.type)
        class:__metalize(value)
    end 
end 

-- serialize, normally when system save, notify all serializable ROOT objects to serialized itself
-- but in facto, there's no this notification mechanism. if this ROOT objec want to save itself, should pass a reference of itself to 
-- global[key] = one_serializable_root_object.
-- NOTE: this only can be done after on_load event triggered, if it will be triggered
function Carriage.setup(class, guid)
    assert(Carriage.guid == guid)
    assert(Carriage == class)
    return Carriage.all
end

-- deseralize, in facto, serialized data only store in global.
-- before script.on_load event tick ended, you can not change data inside which will cause CRC desync problems
-- except attaching metatable for these plain data
function Carriage.metalize(class, guid, data)
    assert(Carriage.guid == guid)
    -- assert(Carriage == class)
    if type(data) ~= "table" then 
        -- if code changed, new class added, could we using lazy method to resetup the data ?
        -- for example, resetup in on_loaded event
        return 
    end 
    Carriage.all = Map:__metalize(data)
    Carriage.load()    
end 

-- @export
return Carriage