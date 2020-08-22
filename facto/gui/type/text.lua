local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local Text = Class.extend({}, AbstractType)
Text.type = "text"
-- Gui.Type.Text = Text

function Text:buildLuaGuiElement(name)
    local props = {}    
    return { name = name, type = "textfield", caption = "text" }
end 

-- function Text:attach(name, parent)
--     local lua_gui_element = parent.add(self:buildLuaGuiElement(name))
--     -- --- lua_gui_element.sytle()
--     -- for name, gui in pairs(self.children) do 
--     --     gui:attach(name, lua_gui_element)
--     -- end 
-- end 

-- @export
return Text