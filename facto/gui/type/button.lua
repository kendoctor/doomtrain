local Class = require("oop.class")
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

-- @export
return Button