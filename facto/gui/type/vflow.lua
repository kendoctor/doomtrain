local Class = require("oop.class")
local Container = require("facto.gui.type.container")
local VFlow = Class.extend({}, Container)
VFlow.type = "vflow"

function VFlow:buildLuaGuiElement(name)
    local props = { name = name, type = "flow", direction = "vertical"  }
    return props
end 

-- @export
return VFlow