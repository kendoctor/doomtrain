local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local CheckBox = Class.extend({}, AbstractType)
CheckBox.type = "checkbox"

CheckBox.RuleSupports = {
    "color", "height", "width", "font"
}

function CheckBox:getProps(props)
    props.type = "checkbox"
    -- @fixme should check data type
    props.state = (self.data ~= nil) or false
    return props
end 

-- @export
return CheckBox