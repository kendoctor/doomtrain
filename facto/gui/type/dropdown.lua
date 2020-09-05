local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local DropDown = Class.extend({}, AbstractType)
DropDown.type = "dropdown"

DropDown.RuleSupports = {
    "color", "height", "width", "font"
}

function DropDown:getProps(props)
    props.type = "drop-down"
    props.items = self.options.items or {}
    return props
end 

-- @export
return DropDown