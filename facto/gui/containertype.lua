local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")

--- A gui type for extending container gui type which has children gui.
-- NOTE: This is an abstract class, should not be instanced.
local ContainerType = Class.extend({}, AbstractType)

--- Adds a new child gui to this container.
-- @tparam class<AbstractType> child any concrete gui type derived from AbstractType or ContainerType
-- @treturn class<ContainerType> return itself for chain call
function ContainerType:add(child)
    self.children[child:getName()] = child
    child.parent = self
    child.root = self.root
    return self
end 

--- Initialization.
function ContainerType:initialize()
    self.children = {}
end 

--- Check whether the gui is container type.
-- @treturn boolean should return true
function ContainerType:isContainer()
    return true
end 

-- @export
return ContainerType