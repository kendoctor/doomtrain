local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Slider = Class.extend({}, AbstractType)
Slider.type = "slider"

Slider.RuleSupports = {
    "color", "height", "width", "font"
}

function Slider:getProps(props)
    props.type = "slider"
    return props
end 

-- @export
return Slider