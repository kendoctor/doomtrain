local Class = require("oop.class")
local Container = require("facto.gui.type.container")
local VPanel = Class.extend({}, Container)
VPanel.type = "vpanel"

function VPanel:buildLuaGuiElement(name)
    local props = { name = name, type = "frame", direction = "vertical"  }
    props.caption = self.options.caption
    return props
end 

-- @export
return VPanel