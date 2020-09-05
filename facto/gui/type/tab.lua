local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local Tab = Class.extend({}, AbstractType)
Tab.type = "tab"

Tab.RuleSupports = {
    "color", "height", "width", "font"
}

function Tab:getProps(props)
    props.type = "tab"
    return props
end 

-- @export
return Tab