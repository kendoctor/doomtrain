local Class = require("oop.class")
local AbstractType = Class.create()

function AbstractType:__constructor(props)
    props = props or {}
    for k,v in pairs(props) do self[k] = v end 
    self.options = self.options or {}
    self:initialize()
end 

function AbstractType:initialize()
    
end 

function AbstractType:buildLuaGuiElement(name)
    error("AbstractType:buildLuaGuiElement should be overriden.")
end 

-- require("utils")
function AbstractType:attach(name, parent)
    local lua_gui_element = parent.add(self:buildLuaGuiElement(name))
    -- @todo apply style
    return lua_gui_element
end 

-- @export
return AbstractType