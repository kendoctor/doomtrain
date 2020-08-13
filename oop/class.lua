--- Class module for creating classes.
-- Only supports single inheritance now.
-- @classmod
local Class = {}

--- Consistent interface for class to get metatable
Class.classof = getmetatable

--- Instance Class object
-- This function only used internally
--[[-- @usage
    local Dog = Class.create({ name = "default name for all newly instanced objects" })
    local black = Dog:new() -- or 
    local white = Dog()
    assert(black.name == white.name)
]]
-- @tparam table class
---@param ... variable parameters passed into oneClass:__init(...)
function Class.new(class, ...)
    local instance = setmetatable({}, class)
    if class.__init then instance:__init(...) end
    return instance
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

local MetaClass = { __call = Class.new }
--- Create a new class with default values for its instanced objects
-- @tparam table defaults 
function Class.create(defaults)
    return setmetatable(Class.initClass(defaults), MetaClass) 
end 

--- Private function for init class
function Class.initClass(class, superclass)
    class = class or {}
    class.__index = class.__index or class
    class.__metalize = class.__metalize or Class.__metalize 
    class.super = class.super or superclass
    return class
end

--- Check whether a table is an object created from class which created by Class.create
function Class.isClass(class)
    local metaclass = classof(class)
	if metaclass and metaclass.__call == Class.new then return true end
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
function Class.extend(defaults, superclass)
    if superclass then 
        return setmetatable(Class.initClass(defaults, superclass), { __call = Class.new, __index = superclass })
    else 
        return Class.create(defaults)
    end
end 

-- @export 
return Class