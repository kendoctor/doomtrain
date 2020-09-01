local Class = require("oop.class")

local Serializable = Class.create()

function Serializable:__constructor()
    self.serialize = {}
end 

--- When script.on_init triggered, GameManager will invoke this method for factory storing references to be serialized.
-- @tparam string guid a unique key for factory registration in GameManager
-- @tparam table facto the root facto data storage table
function Serializable:init(guid, facto)
    facto[guid] = self.serialize
end 

--- When script.on_load triggered, GameManager will invoke this method for factory getting data from save.
-- @tparam string guid a unique key for factory registration in GameManager
-- @tparam table facto the root facto data storage table
function Serializable:load(guid, facto)
    self.serialize = facto[guid]
end 

--- Return an unique key for factory regsitration in GameManager.
-- An abstract method should be overrided by its derived classes
function Serializable.guid()   
    error("Serializable.guid should be overridden.")
end 

-- @export
return Serializable