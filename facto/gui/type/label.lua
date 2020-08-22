local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local Label = Class.extend({}, AbstractType)
Label.type = "label"

function Label:buildLuaGuiElement(name)
    local props = { name = name, type = "label" }
    props.caption = self.options.caption
    return props
end 

-- @export
return Label