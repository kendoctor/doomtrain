local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local Text = Class.extend({}, AbstractType)
Text.type = "text"

Text.RuleSupports = {
    "color", "height", "width", "font"
}

function Text:getProps(props)    
    props.type = "textfield"
    if self.data ~= nil then props.text = tostring(self.data) end 
    return props
end 

-- @export
return Text