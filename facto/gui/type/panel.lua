local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")
local Panel = Class.extend({}, ContainerType)
Panel.type = "panel"

function Panel:getProps(props)
    props.type = "frame"
    props.direction = self.options.direction or "vertical"
    return props
end 

function Panel:center()
    self.factoobj.force_auto_center()
end 

-- @export
return Panel