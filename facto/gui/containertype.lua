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

function ContainerType:onattached(gui)
    ContainerType.super.onattached(self, gui)
    for _,child in pairs(self.children) do child:onattached(gui) end
end 

function ContainerType:findByName(name, found)    
    local matched = ContainerType.super.findByName(self, name, found)
    if matched then table.insert(found, matched) end 
    for _, child in pairs(self.children) do 
        child:findByName(name, found)
    end 
end 

--- Check whether the gui is container type.
-- @treturn boolean should return true
function ContainerType:isContainer()
    return true
end 

function ContainerType:destroy()
    for _,child in pairs(self.children) do 
        child:destroy()
    end 
    ContainerType.super.destroy(self)
end 

-- @export
return ContainerType