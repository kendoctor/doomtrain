local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Separator = Class.extend({}, AbstractType)
Separator.type = "separator"

Separator.RuleSupports = {
}

function Separator:getProps(props)
    props.type = "line"
    props.direction = self.options.direction or "horizontal"
    return props
end 

-- @export
return Separator