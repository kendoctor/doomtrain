local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")
local HPanel = Class.extend({}, ContainerType)
HPanel.type = "hpanel"

function HPanel:getProps(props)
    props.type = "frame"
    props.direction = "horizontal"
    return props
end 

-- @export
return HPanel