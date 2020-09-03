local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local ProgressBar = Class.extend({}, AbstractType)
ProgressBar.type = "progressbar"

function ProgressBar:buildLuaGuiElement(name)
    local props = { name = name, type = "progressbar", value = 0.4}
    props.caption = self.options.caption
    return props
end 

-- @export
return ProgressBar