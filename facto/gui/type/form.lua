local Class = require("oop.class")
local ContainerType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local Form = Class.extend({}, ContainerType)
Form.type = "form"

function Form:getProps(props)
    props.type = "flow"
    props.direction = "vertical"
    return props
end

-- @export
return Form