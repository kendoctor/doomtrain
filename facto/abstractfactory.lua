local Class = require("facto.class")
local Serializable = require("facto.serializable")

--- Abstract factory for extending concrete factories
-- Basic behaviors for factory 
--   1. Register class
--   2. Create object using a type which was registered
--   3. Get registered class by type
--   4. Setup factory, considering using cfg to register all desired classes
--   5. Remove object from cache
--   6. Give guid for GameManager 
--   7. Implementation of GameManager serialization event triggered
--   8. Implementation of GameManager deserialization event triggered
local AbstractFactory = Class.extend({}, Serializable)

--- Constructor.
function AbstractFactory:__constructor()
    AbstractFactory.super.__constructor(self)
    self.registered = {}
    self.serialize.instanced = {}
    self:initialize()
end 

--- Initialization
function AbstractFactory:initialize()
end 

--- Register one class with an unique key.
-- @tparam string key since word [type] is lua keyword, avoiding to use it
function AbstractFactory:register(key, class)
    -- @todo registered class should be derived form a base class
    if not self:hasClass(key) then self.registered[key] = class end 
end 

--- Get expected class by key.
-- @tparam string key since word [type] is lua keyword, avoiding to use it
-- @treturn class<Product>
function AbstractFactory:getClass(key)
    return self.registered[key]
end 

--- Get whether the class has been registered.
function AbstractFactory:hasClass(key)
    return self.registered[key] ~= nil
end 

--- Instance an object using registered class.
-- @tparam string key since word [type] is lua keyword, avoiding to use it
-- @tparam table props object's property values
-- @treturn object
function AbstractFactory:create(key, props)
    local class = self:getClass(key)
    if class == nil then error(string.format("Key(%s) not registered.", key)) end 
    local instance = class(props) 
    -- this value for deserialization
    instance.type = key 
    self.serialize.instanced[tostring(instance:getId())] = instance
    return instance
end 

--- Get object by id.
-- @tparam string | number id
-- @tparam object
function AbstractFactory:get(id)    
    return self.serialize.instanced[tostring(id)]
end 

--- Remove object from cache.
-- @tparam class<Product> object
function AbstractFactory:remove(object)    
    self.serialize.instanced[tostring(object:getId())] = nil 
end 

-- Setup factory, such as all expected classes registration.
-- An abstract method should be overrided by its derived classes
function AbstractFactory:setup()
     -- Derived factory should have its own storage
    error("AbstractFactory.setup should be overridden.")
end 

--- When script.on_init triggered, GameManager will invoke this method for factory storing references to be serialized.
-- @tparam string guid a unique key for factory registration in GameManager
-- @tparam table storage a table for storing references to be serialized
-- function AbstractFactory:init(guid, facto)
-- end 

--- When script.on_load triggered, GameManager will invoke this method for factory getting data from save.
-- @tparam string guid a unique key for factory registration in GameManager
-- @tparam table data a table storing data loaded from save
function AbstractFactory:load(guid, facto)
    AbstractFactory.super.load(self, guid, facto)    
    -- if data is not table, that means the game data already broken
    -- self.instanced = data.instanced
    for id, data in pairs(self.serialize.instanced) do 
        local class = self:getClass(data.type)
        if class == nil then error(string.format("Key(%s) not registered.", data.type)) end         
        class:__metalize(data)        
    end 
end 

--- Return an unique key for factory regsitration in GameManager.
-- An abstract method should be overrided by its derived classes
function AbstractFactory.guid()   
    error("AbstractFactory.guid should be overried.")
end 

-- @export
return AbstractFactory