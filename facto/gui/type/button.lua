local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local Button = Class.extend({}, AbstractType)
Button.type = "button"

function Button:buildLuaGuiElement(name)
    local props = { name = name, type = "button" }
    props.caption = self.options.caption
    return props
end 

-- @export
return Button