local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Switch = Class.extend({}, AbstractType)
Switch.type = "switch"

Switch.RuleSupports = {
    "color", "height", "width", "font"
}

function Switch:getProps(props)
    props.type = "switch"
    return props
end 

-- @export
return Switch