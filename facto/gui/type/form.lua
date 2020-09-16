local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local Form = Class.extend({}, ContainerType)
Form.type = "form"

function Form:initialize()
    self.children = {}
    self.options.binding_disabled = self.options.binding_disabled or false
end 

function Form:getProps(props)
    props.type = "flow"
    props.direction = "vertical"
    return props
end

function Form:isForm()
    return true
end

-- @export
return Form