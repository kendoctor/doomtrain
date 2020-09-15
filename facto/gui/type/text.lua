local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Text = Class.extend({}, AbstractType)
Text.type = "text"

Text.RuleSupports = {
    "color", "height", "width", "font"
}

function Text:initialize()
    self.options.binding_disabled = self.options.binding_disabled or false
end 

function Text:getProps(props)    
    props.type = "textfield"
    return props
end 

function Text:setValue(value)
    if value == nil then return end
    self.factoobj.text = tostring(value)
end 

function Text:getValue()
    return self.factoobj.text
end

-- @export
return Text