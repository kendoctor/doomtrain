--- Class module for creating classes.
-- Only supports single inheritance now.
-- @author kendoctor, some ideas inspired from Renato Maia <maia@inf.puc-rio.br> 
-- @classmod
local Class = {}

local function table_copy(destiny, source)
    if source then
        if not destiny then destiny = {} end
        for field, value in pairs(source) do
            rawset(destiny, field, value)
        end
    end
    return destiny
end 

--- Instance Class object
-- This function only used internally
-- if OneClass:__init exists, variable parameters will be passed in
-- else will be automatically assigend to property members if the property exists
--[[-- @usage
    local Dog = Class.create({ name = "default name for all newly instanced objects" })
    local black = Dog:new() -- or 
    local white = Dog()
    assert(black.name == white.name)
]]
-- @tparam table class
---@param ... variable parameters passed into oneClass:__init(...)
local function new(class, ...)
    local instance = setmetatable(table_copy({}, class.__default_properties), class)
    --- if ... has values, then override the instance's default values
    -- if ... ~= nil then 
    --     local default_properties 
    --     if type(...) ~= "table" then default_properties = { ... }
    -- end 
    if class.__init then 
        instance:__init(...) 
    elseif ... ~= nil then 
        local default_values = ...
        if type(...) ~= "table" then default_values = { ... } end 
        for k,v in pairs(default_values) do if instance[k] ~= nil then instance[k] = v end end 
    end 
    return instance
end 

--- Private function for init class
--  newly created Class always be blank, 
-- metatable members of Class should be declared and implemented after Class created 
local function initClass(default_properties, superclass)
    -- newly created Class always be blank
    local class = {}
    class.__index = class
    class.__metalize = Class.__metalize 
    class.__default_properties = default_properties or {}
    class.super = class.super or superclass
    return class
end

local MetaClass = { __call = new }
--- Create a new none metatable members Class with default properties which have default values for its instances.
-- after class creation, could define metatable members for this class
--[[--@usage    
    local Train = Class.create() -- create a blank Train class
    -- create a Dog Class with some default properties
    local Dog = Class.create({ name = "juejue", age = 1 }) 
    -- create a method(function) member which will bed shared overall of its instances
    function Dog:bark()
        print(self.name)
    end 
    -- instance a dog 
    local black = Dog()
    assert(black.name == "juejue")
    -- create a new property only for this dog
    black.weight = 10
    local white = Dog()
    white:bark()
]]
-- NOTE: property members of an instance could have different values with others
-- metatable members are derived from Class via setmetatable, they are shared in all its instances
-- @tparam table default_properties 
function Class.create(default_properties)
    return setmetatable(initClass(default_properties), MetaClass) 
end 

--- Consistent interface for class to get metatable
Class.classof = getmetatable

--- Check whether a table is an object created from class which created by Class.create
function Class.isClass(class)
    local metaclass = classof(class)
	if metaclass and metaclass.__call == new then return true end
	return false
end 

--- Check whether the class is derived from super or is the super
function Class.subclassof(class, super)
	while class do
		if class == super then return true end
		class = class.super
	end
	return false
end

--- Check whether object is an instance of this class or its derived class
function Class.instanceof(object, class)
	return Class.subclassof(classof(object), class)
end

-- Extand one class from another class with default values
function Class.extend(default_properties, superclass)
    if superclass then 
        return setmetatable(initClass(default_properties, superclass), { __call = new, __index = superclass })
    else 
        return Class.create(default_properties)
    end
end 

--- Metalize one table into a class object
--[[-- @usage
    local Dog = Class.create()
    local plain_table = { name = "juejue", age = 1 }
    local dog = Dog:__metalize(plain_table)
    assert(dog == plain_table)
    assert(getmetatable(dog) == Dog)
]]
-- @tparam Class class
-- @tparam table tbl
function Class.__metalize(class, tbl)
    return setmetatable(tbl or {}, class)
end 

-- @export 
return Class