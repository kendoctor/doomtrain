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

local function table_overwrite_merge(origin, source)
    if source then 
        for k,v in pairs(source) do 
            origin[k] = v
        end 
    end 
    return origin
end

local function table_append_merge(origin, source)
    if source then 
        for k,v in pairs(source) do 
            if origin[k] == nil then origin[k] = v end
        end 
    end 
    return origin
end

local function table_exist_merge(origin, source)
    if source then 
        for k,v in pairs(source) do if origin[k] ~= nil then origin[k] = v end end 
    end 
    return origin
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
local function call_handler(class, ...)
    -- @todo considering less memory usage, lazy build default property members
    -- But, this will cause instancing object a little bit slow
    local instance = setmetatable(table_copy({}, class.__property_members), class)
    --- if ... has values, then override the instance's default values
    -- if ... ~= nil then 
    --     local default_properties 
    --     if type(...) ~= "table" then default_properties = { ... }
    -- end 
    -- @todo add event __pre__init and __post_init
    if class.__init then
        instance:__init(...)
    elseif ... ~= nil then
        local default_values = ...
        if type(...) ~= "table" then default_values = { ... } end      
        table_exist_merge(instance, default_values)           
    end 
    return instance
end 

--- if not overrided this function, will be called here.
function class_pairs_handler(class, tbl, k)
   assert(class ~= nil)
   local super = class.super
   if super then 
        local handler =  super.__class_metatable.__pairs
        if handler then return handler(tbl, k) end 
   end 
end 

--- if not overrided this function, will be called here.
-- find implementation if object' class has superclass
function object_pairs_handler(class, tbl, k)     
    assert(class ~= nil)
    local super = class.super 
    if super and super.__pairs then 
        return super.__pairs(tbl, k)
    end 
end 

--- Private function for init class
--  newly created Class always be blank, 
-- metatable members of Class should be declared and implemented after Class created 
-- @todo hide __property_members, __metalize into class's metatable
local function initClass(property_members, superclass)
    local class = {}
    property_members = property_members or {}
    if superclass then table_append_merge(property_members, superclass.__property_members) end 
    class.__index = class
    class.__metalize = Class.__metalize     
    class.__property_members = property_members
    --- @todo every class has different handler 
    -- class.__pairs = object_pairs_handler
    -- class.__object_pairs_handler = function(class, tbl, k )
    class.__pairs = function(tbl, k)
        -- if this class overwrote __pairs, here will be not called of this class
        -- otherwise, if the class does not implement __pairs
        return object_pairs_handler(class, tbl, k)
    end         
    return class
end

local MetaClass = { __call = call_handler }

--- Consistent interface for class to get metatable
Class.classof = getmetatable

--- Check whether a table is an object created from class which created by Class.create
function Class.isClass(class)
    local metaclass = classof(class)
	if metaclass and metaclass.__call == call_handler then return true end
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
function Class.extend(property_members, superclass)
    local metatable = { __call = call_handler } -- , __pairs = class_pairs_handler 
    local class = initClass(property_members, superclass)
    if superclass then 
        class.super = superclass
        metatable.__index = superclass
    end 
    metatable.__pairs = function(tbl, k)
        return class_pairs_handler(class, tbl, k)
    end 
    -- Note: Should avoid this, __metatable field is reserved by Lua    
    class.__class_metatable = metatable
    return setmetatable(class, metatable)
end 

--- Create a new Class with default properties which have default values for its instances.
-- after class creation, could define metatable members for this class
-- NOTE: property members of an instance could have different values with others
-- metatable members are derived from Class via setmetatable, they are shared in all its instances
-- @tparam table property_members 
function Class.create(property_members)
    return Class.extend(property_members)
    -- return setmetatable(initClass(property_members), MetaClass) 
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