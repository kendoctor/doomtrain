local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Minimap = Class.extend({}, AbstractType)
Minimap.type = "minimap"

Minimap.RuleSupports = {
    "color", "height", "width", "font"
}

function Minimap:getProps(props)
    props.type = "minimap"
    return props
end 

-- @export
return Minimap