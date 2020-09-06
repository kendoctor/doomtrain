local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Container = Class.extend({}, AbstractType)
Container.type = "container"

function Container:add(gui)
    self.children[gui:getName()] = gui
    gui.parent = self
    gui.root = self.root
end 

function Container:initialize()
    self.children = {}
end 

function Container:getProps(props)
    return { name = self.name, type = "flow" }
end 

-- function Container:attach(name, parent)
--     name = name or self.name
--     local lua_gui_element = Container.super.attach(self, name, parent)
--     for _, gui in pairs(self.children) do 
--         gui:attach(nil, lua_gui_element)
--     end 
--     return lua_gui_element
-- end 

function Container:show(name, root)
    if not root[name] then 
        self:attach(name, root)
    end 
end 

-- @export
return Container