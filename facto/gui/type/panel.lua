local Class = require("oop.class")
local Container = require("facto.gui.type.container")
local Panel = Class.extend({}, Container)
Panel.type = "panel"

function Panel:getProps()
    local props = { name = self.name, type = "frame" }
    props.caption = self.options.caption
    return props
end 

-- @export
return Panel