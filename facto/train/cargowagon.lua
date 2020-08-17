local Class = require("oop.class")
local Carriage = require("facto.train.carriage")

local CargoWagon = Class.extend({}, Carriage)
CargoWagon.type = "cargo-wagon"

function CargoWagon:isLocomotive()
    return false 
end 

-- @export
return CargoWagon