local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Radio = Class.extend({}, AbstractType)
Radio.type = "radio"

Radio.RuleSupports = {
}

function Radio:initialize()
    self.options.binding_disabled = self.options.binding_disabled or false
end 

function Radio:getValue()
    return self.factoobj.state
end

function Radio:getProps(props)
    props.type = "radiobutton"
    props.state = false
    return props
end 

function Radio:setValue(value)
    if not type(value) == "boolean" then value  = false end
    self.factoobj.state = value
end 

-- @export
return Radio