local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Submit = Class.extend({}, AbstractType)
Submit.type = "submit"

Submit.RuleSupports = {
    "color", "height", "width", "font"
}

function Submit:initialize()
    self.options.binding_disabled = self.options.binding_disabled or true
    self.options.caption = self.options.caption or "submit"
end 

function Submit:getProps(props)
    props.type = "button"
    return props
end 

function Submit:setValue(value)
    -- if value == nil or self.options.caption then return end 
    self.factoobj.caption = self.options.caption
end 

-- @export
return Submit