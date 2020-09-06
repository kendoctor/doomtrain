local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Radio = Class.extend({}, AbstractType)
Radio.type = "radio"

Radio.RuleSupports = {
}

function Radio:getProps(props)
    props.type = "radiobutton"
    props.state = (self.data ~= nil) or false
    return props
end 

-- @export
return Radio