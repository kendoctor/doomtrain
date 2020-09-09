local Class = require("facto.class")
local Car = Class.extend()
local Bus = Class.create()
local Train = Class.create()
local VehicleFactory = Class.create()

function VehicleFactory:__constructor()
    self.registered_classes = {}
    self:setup()
end 

function VehicleFactory:setup()
    self:register("car", Car)
    self:register("bus", Bus)
    self:register("train", Train)
end 

function VehicleFactory:register(key, class)
    self.registered_classes[key] = class
end 

function VehicleFactory:getClass(key)
    return self.registered_classes[key]
end 

function VehicleFactory:create(key)
    local class = self:getClass(key)
    if class == nil then error(string.format("Class not found for key(%s)", key)) end 
    return class()
end 

local f = VehicleFactory()
local c, b, t = f:create("car"), f:create("bus"), f:create("train")
assert(getmetatable(c) == Car)
assert(getmetatable(b) == Bus)
assert(getmetatable(t) == Train)
