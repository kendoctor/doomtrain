local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local Container = Class.extend({}, AbstractType)
Container.type = "container"
-- Gui.Type.Container = Container
require("utils")
function Container:add(gui)
    --- check if already exists with the name
    -- self.children[name] = gui
    table.insert(self.children, gui)
    gui.parent = self
end 

function Container:initialize()
    self.children = {}
end 

function Container:buildLuaGuiElement(name)
    return { name = name, type = "flow" }
end 

function Container:attach(name, parent)
    name = name or self.name
    local lua_gui_element = Container.super.attach(self, name, parent)
    for _, gui in pairs(self.children) do 
        gui:attach(nil, lua_gui_element)
    end 
    return lua_gui_element
end 

function Container:show(name, root)
    if not root[name] then 
        self:attach(name, root)
    end 
end 

-- @export
return Container