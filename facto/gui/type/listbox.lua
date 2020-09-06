local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local ListBox = Class.extend({}, AbstractType)
ListBox.type = "listbox"

ListBox.RuleSupports = {
    "color", "height", "width", "font"
}

function ListBox:getProps(props)
    props.type = "list-box"
    props.items = self.options.items or {}
    return props
end 

-- @export
return ListBox