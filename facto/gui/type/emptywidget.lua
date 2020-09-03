local Class = require("oop.class")
local ContainerType = require("facto.gui.containertype")

local EmptyWidget = Class.extend({}, ContainerType)
EmptyWidget.type = "empty-widget"

EmptyWidget.RuleSupports = {
    "height", "width", "hstretch","nat-height","max-height","min-width"
}

function EmptyWidget:getProps(props)
    props.type = "empty-widget"
    -- props.horizontally_stretchable = true -- self.options.horizontally_stretchable
    return props
end

function EmptyWidget:onattached(gui)
    EmptyWidget.super.onattached(self, gui)
end 

-- @export
return EmptyWidget