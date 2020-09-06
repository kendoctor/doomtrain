local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local SpriteButton = Class.extend({}, AbstractType)
SpriteButton.type = "sprite-button"

SpriteButton.RuleSupports = {
    "color", "height", "width", "font"
}

function SpriteButton:getProps(props)
    props.type = "sprite-button"
    props.sprite = self.options.default
    props.clicked_sprite = self.options.clicked
    props.hovered_sprite = self.options.hovered
    -- props.style = "frame_action_button"
    return props
end 

-- @export
return SpriteButton