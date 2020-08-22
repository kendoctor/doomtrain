local Class = require("oop.class")
local Container = require("facto.gui.type.container")
local HFlow = Class.extend({}, Container)
HFlow.type = "hflow"

function HFlow:buildLuaGuiElement(name)
    local props = { name = name, type = "flow", direction = "horizontal"  }
    return props
end 

-- @export
return HFlow