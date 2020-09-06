local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")
local HFlow = Class.extend({}, ContainerType)
HFlow.type = "hflow"

function HFlow:getProps(props)
    props.type = "flow"
    props.direction = "horizontal"
    return props
end 

-- @export
return HFlow