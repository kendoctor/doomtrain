local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local TextBox = Class.extend({}, AbstractType)
TextBox.type = "textbox"

TextBox.RuleSupports = {
    "color", "height", "width", "font"
}

function TextBox:getProps(props)
    props.type = "text-box"
    props.text = self.data 
    return props
end 

-- @export
return TextBox