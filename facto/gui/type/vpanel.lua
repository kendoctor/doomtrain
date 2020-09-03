local Class = require("oop.class")
local ContainerType = require("facto.gui.containertype")
local VPanel = Class.extend({}, ContainerType)
VPanel.type = "vpanel"

function VPanel:getProps(props)
    props.type = "frame"
    props.direction = "vertical"
    return props
end 

-- @export
return VPanel