local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local CheckBox = Class.extend({}, AbstractType)
CheckBox.type = "checkbox"

CheckBox.RuleSupports = {
    "color", "height", "width", "font"
}

function CheckBox:initialize()
    self.options.binding_disabled = self.options.binding_disabled or false
end 

-- @todo sync field data into model data if not binding_disabled
function CheckBox:getValue()
    return self.factoobj.state
end

function CheckBox:getProps(props)
    props.type = "checkbox"
    -- @fixme should check data type
    props.state = false
    return props
end 

function CheckBox:setValue(value)
    if not type(value) == "boolean" then value  = false end
    self.factoobj.state = value
end 

-- @export
return CheckBox