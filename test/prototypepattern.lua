local Class = require("facto.class")
local Prototype = Class.create()

function Prototype:clone()
    local class = getmetatable(self)
    return class()
end 

local Chest = Class.extend({}, Prototype)

function Chest:__constructor()
    self.name = "steel-chest"
    self.minable = true
    self.destructible = true
    self.inventory = { "wood", "coal", "iron" }
end 

function Chest:__tostring()
    return string.format("Chest: name(%s), minable(%s), destructible(%s), %d items in inventory", self.name, tostring(self.minable), tostring(self.destructible), #self.inventory)
end 

local Car = Class.extend({}, Prototype)

function Car:__constructor()
    self.color = "white"
    self.speed = 10
    self.inventory = { "ammo", "pistol" }
end

function Car:__tostring()
    return string.format("Car: color(%s), speed(%s), %d items in inventory", self.color, self.speed, #self.inventory)
end 

local chest_prototype = Chest()
local car_prototype = Car()

local cloned_chest = chest_prototype:clone()
local cloned_car = car_prototype:clone()
print(cloned_chest)
print(cloned_car)

local PrototypeManager = Class.create()

function PrototypeManager:__constructor()
    self.prototypes = {}
    self:setup()
end 

function PrototypeManager:registerPrototype(prototype_name, class)
    if self.prototypes[prototype_name] == nil then 
        self.prototypes[prototype_name] = class()
    end 
end 

function PrototypeManager:getPrototype(prototype_name)
    return self.prototypes[prototype_name]
end 

function PrototypeManager:setup()
    self:registerPrototype("chest", Chest)
    self:registerPrototype("car", Car)
end 

function PrototypeManager:clone(prototype_name)
    local prototype = self:getPrototype(prototype_name)
    if prototype == nil then error("Invalid prototype") end 
    return prototype:clone()
end

local Pm = PrototypeManager()
local car, chest = Pm:clone("car"), Pm:clone("chest")
print(car, chest)
