local Class = require("oop.class")
local AbstractType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local Form = Class.extend({}, AbstractType)
Form.type = "form"

function Form:getProps()
    return { name = self.name, type = "flow", direction = "vertical" }
end

-- @export
return Form