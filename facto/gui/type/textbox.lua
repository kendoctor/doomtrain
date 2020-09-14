local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local TextBox = Class.extend({}, AbstractType)
TextBox.type = "textbox"

TextBox.RuleSupports = {
    "color", "height", "width", "font"
}

function TextBox:getProps(props)
    props.type = "text-box"
    return props
end 

function TextBox:setValue(value)
    if value == nil then return end
    self.factoobj.text = tostring(value)
end 

-- @export
return TextBox