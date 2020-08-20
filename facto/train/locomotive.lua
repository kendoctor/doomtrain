local Class = require("oop.class")
local Event = require("facto.event")
local Carriage = require("facto.train.carriage")

--- Locomotive carriage which can have a driver in it.
-- @classmod Locomotive
local Locomotive = Class.extend({}, Carriage)

-- @section property members
-- @property string the type of carriage which is for train factory registration
Locomotive.type = "locomotive"

-- @section metatable members
--- Initialization, this will be called in object creation
function Locomotive:initialize()
end 

--- This is locomotive.
-- @treturn boolean
function Locomotive:isLocomotive()
    return true 
end 

--- Build Locomotive such room, doors, pond
-- @tparam class<Locomotive> old_carriage
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function Locomotive:build(old_carriage, tiles, lazycalls)
    if old_carriage then 
        self:clone(old_carriage)
    else
        print("building room")
        self:buildRoom(tiles, lazycalls)
        print("building doors")
        self:buildDoors(tiles, lazycalls)
        self:buildPond(tiles, lazycalls)
    end 
end 

--- Build a pond with some fresh fishes.
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
function Locomotive:buildPond(tiles, lazycalls)
    local fishes = {}
    local surface = self:getTrainSurface()
    for x = -3, 2, 1 do
        for y = 10, 12, 1 do
            tiles[#tiles + 1] = { name = 'water', position = { x, y } }
            fishes[#fishes + 1] = { name = 'fish', position = { x, y } }            
        end
    end
    lazycalls[#lazycalls + 1] = function() 
        for _, fish in pairs(fishes) do 
            surface.create_entity(fish)
        end 
    end 
end 

-- @export
return Locomotive