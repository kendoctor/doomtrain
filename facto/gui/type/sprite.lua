local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local Sprite = Class.extend({}, AbstractType)
Sprite.type = "sprite"

Sprite.RuleSupports = {
    "height", "width"
}

function Sprite:getProps(props)
    props.type = "sprite"
    props.sprite = self.options.path 
    return props
end 

-- @export
return Sprite