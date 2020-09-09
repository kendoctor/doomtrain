local Class = require("facto.class")    
local Dog = Class.create()

function Dog:__constructor(name, age)
    self.name = name or "JueJue"
    self.age = age or 2
end 

function Dog:bark()
    print(string.format("wang wang, i'm %s and %d years old.", self.name, self.age))
end 

Dog():bark()
local black = Dog("Black", 5)
black:bark()


local Vehicle = Class.create()

function Vehicle:__constructor(speed)
    self.speed = speed or 0
end 

function Vehicle:run()
    print(string.format("Running speed is %d", self.speed))
end 

local Car = Class.extend({}, Vehicle)
Car.Directions = {
    Forward = 1,
    Backward = 2,
    Left = 3,
    Right = 4
}

function Car:__constructor(speed, direction)
    self:changeDirection(direction)
    Car.super.__constructor(self, speed)    
    self.direction = self.direction or self.Directions.Forward
end 

function Car:changeDirection(direction)
    if direction ~= nil and direction ~= self.direction then
        for k,v in pairs(self.Directions) do 
            if v == direction then 
                self.direction = direction
                print("direction is changed")
            end             
        end         
    end
end 

function Car:run(direction)
    Car.super.run(self)
    self:changeDirection(direction)
    print(string.format("Running direction is %d", self.direction))
end 

Car():run()
Car(10):run(Car.Directions.Right)
Car(20, Car.Directions.Left):run()