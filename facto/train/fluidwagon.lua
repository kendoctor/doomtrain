local Class = require("facto.class")
local Event = require("facto.event")
local Carriage = require("facto.train.carriage")
local exchangerFactory = require("facto.exchanger.exchangerfactory").getInstance()

--- Fluid wagon implementation.
-- @classmod FluidWagon
local FluidWagon = Class.extend({}, Carriage)
-- @section property members
-- @property string the of type of carriage which is for factory registration.
FluidWagon.type = "fluid-wagon"
-- @property table table for holds exchangers for the carriage.
-- Note: here should be nil, only for property definition. 
FluidWagon.exchangers = nil 

-- @section private members
--- shuffle items in table
-- @tparam table tbl
-- @treturn table
local function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

-- @section metatable members
--- Initialization
function FluidWagon:initialize()
    self.exchangers = {}
end 

--- Clone carriage from the old.
-- @tparam class<FluidWagon> old_carriage
function FluidWagon:clone(old_carriage)
    local restore = function(e)
        for k, exchanger in pairs(old_carriage.exchangers) do 
            if exchanger.factoobj2 == e.source then 
                self:createExchangerByClone(exchanger, { carriage = self, factoobj2 = e.destination })
                return 
            end 
        end 
        if e.source.name ~= "player-port" then return end
        local old_doors = old_carriage.doors
        for k, door in pairs(old_doors) do 
            if door.factoobj == e.source then self:createDoorByClone(door, { factoobj = e.destination, carriage = self }) return end 
        end         
    end 
    Event.on(defines.events.on_entity_cloned, restore)
    self:cloneArea(old_carriage)    
    Event.remove(defines.events.on_entity_cloned, restore)
end 

--- Build carriage such as room, doors, exchanger.
-- @tparam class<FluidWagon> old_carriage
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function FluidWagon:build(old_carriage, tiles, lazycalls)
    if old_carriage then 
        self:clone(old_carriage)
    else
        print("building room")
        self:buildRoom(tiles, lazycalls)
        print("building doors")
        self:buildDoors(tiles, lazycalls)

        local area = self:getBuildingArea()
        local height = area.right_bottom.y - area.left_top.y
        local positions = {
            {area.right_bottom.x, area.left_top.y + height * 0.25},
            {area.right_bottom.x, area.left_top.y + height * 0.75},
            {area.left_top.x - 1, area.left_top.y + height * 0.25},
            {area.left_top.x - 1, area.left_top.y + height * 0.75}
        }
        positions = shuffle(positions)
        self:createExchanger({ carriage = self }, positions[1], tiles, lazycalls)
    end 
end 

--- Create exchanger
-- @tparam table props exchanger properties
-- @tparam LuaPosition position exchanger position
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function FluidWagon:createExchanger(props, position, tiles, lazycalls)
    local exchanger, addedcall = exchangerFactory:createLazyAdded("fluid-wagon-exchanger", props)
    exchanger:build(position, tiles, lazycalls, function() 
        self.exchangers[tostring(exchanger:getId())] = exchanger
        addedcall()
    end)
end 

--- Clone exchanger from the old surface area.
-- @tparam class<FluidWagonExchanger> source_exchanger
-- @tparam table props properties of the exchanger
function FluidWagon:createExchangerByClone(source_exchanger, props)
    local exchanger = exchangerFactory:create(source_exchanger.type, props)
    self.exchangers[tostring(exchanger:getId())] = exchanger
    self.exchangers[tostring(source_exchanger:getId())] = nil
    exchangerFactory:remove(source_exchanger)
end 

--- Clear carriage data.
function FluidWagon:destroy()
    FluidWagon.super.destroy(self)
    for id, exchanger in pairs(self.exchangers) do 
        self.exchangers[id] = nil
        exchangerFactory:remove(exchanger)
        exchanger:destroy() 
    end  
end 

-- @export
return FluidWagon