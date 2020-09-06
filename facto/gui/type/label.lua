local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Label = Class.extend({}, AbstractType)
Label.type = "label"

function Label:getProps(props)
    props.type = "label"
    return props
end 

-- @export
return Label