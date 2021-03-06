local Class = require("facto.class")
local Event = require("facto.event")
local Carriage = require("facto.train.carriage")
local exchangerFactory = require("facto.exchanger.exchangerfactory").getInstance()

--- Cargo wagon implementation.
-- @classmod CargoWagon
local CargoWagon = Class.extend({}, Carriage)
-- @property members
-- @property string the type of carriage which is for factory registration.
CargoWagon.type = "cargo-wagon"
-- @property table table for holds exchangers for the carriage.
-- Note: here should be nil, only for property definition. 
CargoWagon.exchangers = nil 

-- @metatable members
--- Initialization.
function CargoWagon:initialize()
    self.exchangers = {}
end 

--- Build carriage such as room, doors, exchangers.
-- @tparam class<CargoWagon> old_carriage
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function CargoWagon:build(old_carriage, tiles, lazycalls)
    if old_carriage then 
        self:clone(old_carriage)
    else
        print("building room")
        self:buildRoom(tiles, lazycalls)
        print("building doors")
        self:buildDoors(tiles, lazycalls)
        self:buildExchangers(tiles, lazycalls)
    end 
end 

--- Clone carriage from the old.
-- @tparam class<CargoWagon> old_carriage
function CargoWagon:clone(old_carriage)
    local restore = function(e)
        for k, exchanger in pairs(old_carriage.exchangers) do 
            if exchanger.factoobj2 == e.source then 
                self:createExchangerByClone(exchanger, { carriage = self, factoobj2 = e.destination, is_output = exchanger.is_output })
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

--- Build exchangers.
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function CargoWagon:buildExchangers(tiles, lazycalls)
    local area = self:getBuildingArea()
    local ltx, lty, rbx, rby = area.left_top.x, area.left_top.y, area.right_bottom.x, area.right_bottom.y 
    local meta = {
        { props = { is_output = true } , position = { ltx + 3, lty + 1 } },
        { props = { is_output = true } , position = { ltx + 4, lty + 1 } },
        { props = { is_output = false } , position = { rbx - 5, lty + 1 } },
        { props = { is_output = false } , position = { rbx - 4, lty + 1 } },
        { props = { is_output = true } , position = { ltx + 3, rby - 2 } },
        { props = { is_output = true } , position = { ltx + 4, rby - 2 } },
        { props = { is_output = false } , position = { rbx - 5, rby - 2 } },
        { props = { is_output = false } , position = { rbx - 4, rby - 2 } }
    }

    for _, data in pairs(meta)  do 
        data.props.carriage = self
        self:createExchanger(data.props, data.position, tiles, lazycalls)
    end 
end 

--- Create exchanger.
-- @tparam table props exchanger properties
-- @tparam LuaPosition position exchanger position
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function CargoWagon:createExchanger(props, position, tiles, lazycalls)
    local exchanger, addedcall = exchangerFactory:createLazyAdded("cargo-wagon-exchanger", props)
    exchanger:build(position, tiles, lazycalls, function() 
        self.exchangers[tostring(exchanger:getId())] = exchanger
        addedcall()
    end)
end 

--- Clone exchanger from the old surface area.
-- @tparam class<CargoWagonExchanger> source_exchanger
-- @tparam table props properties of the exchanger
function CargoWagon:createExchangerByClone(source_exchanger, props)
    local exchanger = exchangerFactory:create(source_exchanger.type, props)
    self.exchangers[tostring(exchanger:getId())] = exchanger
    self.exchangers[tostring(source_exchanger:getId())] = nil
    exchangerFactory:remove(source_exchanger)
end 

--- Clear carriage data.
function CargoWagon:destroy()
    CargoWagon.super.destroy(self)
    for id, exchanger in pairs(self.exchangers) do 
        self.exchangers[id] = nil
        exchangerFactory:remove(exchanger)
        exchanger:destroy() 
    end  
end 

-- @export
return CargoWagon