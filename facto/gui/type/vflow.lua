local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")
local VFlow = Class.extend({}, ContainerType)
VFlow.type = "vflow"

function VFlow:getProps(props)
    props.type = "flow"
    props.direction = "vertical"
    return props
end 

-- @export
return VFlow