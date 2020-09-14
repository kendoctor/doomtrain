local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Label = Class.extend({}, AbstractType)
Label.type = "label"

function Label:getProps(props)
    props.type = "label"
    return props
end 

function Label:setValue(value)
    if value == nil or self.options.caption then return end 
    self.factoobj.caption = tostring(value)
end 

-- @export
return Label