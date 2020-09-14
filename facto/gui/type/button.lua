local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Button = Class.extend({}, AbstractType)
Button.type = "button"

Button.RuleSupports = {
    "color", "height", "width", "font"
}

function Button:getProps(props)
    props.type = "button"
    return props
end 

function Button:setValue(value)
    if value == nil or self.options.caption then return end 
    self.factoobj.caption = tostring(value)
end 

-- @export
return Button