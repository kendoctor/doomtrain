local Class = require("facto.class")

local Body = Class.create()
function Body:__constructor(color)
    self.color = color
end 

local Wheel = Class.create()

local Engine = Class.create()
function Engine:__constructor(power)
    self.power = power
end 

local Car = Class.create()
function Car:__constructor(body, engine, wheels)
    self.body = body
    self.engine = engine
    self.wheels = wheels or {}
end 

function Car:__tostring()
    return string.format("Car color(%s), engine power(%s) with %d wheels", self.body.color, self.engine.power, #self.wheels)
end 

local CarBuilder = Class.create()

function CarBuilder:__constructor()
    self:reset()
end 

function CarBuilder:reset(body, engine, wheels)
    self.body = nil
    self.engine = nil
    self.wheels = {}
end 

function CarBuilder:addBody(color)
    self.body = Body(color)
    return self
end 

function CarBuilder:addEngine(power)
    self.engine = Engine(power)
    return self
end 

function CarBuilder:addWheel()
    table.insert(self.wheels, Wheel())
    return self
end 

function CarBuilder:getCar()
    if self.body == nil then error("A car should have one body") end 
    if self.engine == nil then error("A car should have one engine") end 
    if #self.wheels < 3 then error("A car should have at least 3 wheels") end 
    local new_car = Car(self.body, self.engine, self.wheels)
    self:reset()
    return new_car
end 

local car = CarBuilder()
    :addBody("white")
    :addEngine("1.34BHP")
    :addWheel()
    :addWheel()
    :addWheel()
    :getCar()
print(car)