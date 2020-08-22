local Class = require("oop.class")
local Container = require("facto.gui.type.container")
local HPanel = Class.extend({}, Container)
HPanel.type = "hpanel"

function HPanel:buildLuaGuiElement(name)
    local props = { name = name, type = "frame", direction = "horizontal"  }
    props.caption = self.options.caption
    return props
end 

-- @export
return HPanel