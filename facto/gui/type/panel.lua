local Class = require("oop.class")
local Container = require("facto.gui.type.container")
local Panel = Class.extend({}, Container)
Panel.type = "panel"

function Panel:buildLuaGuiElement(name)
    return { name = name, type = "frame", caption = "something" }
end 

-- @export
return Panel