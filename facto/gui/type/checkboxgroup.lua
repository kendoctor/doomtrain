local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local CheckBoxGroup = Class.extend({}, ContainerType)
CheckBoxGroup.type = "checkboxgroup"

function CheckBoxGroup:initialize()
    self.children = {}
    self.options.binding_disabled = self.options.binding_disabled or false
end 

function CheckBoxGroup.buildGui(builder, options)
    for index, item in pairs(options.items) do
        builder:add(nil, "checkbox", { caption = item.description, binding_disabled = true } )
    end
end

function CheckBoxGroup:getValue()
    local value = {}
    local index = 0
    for name, child in pairs(self.children) do
        index = index + 1
        if child:getValue() == true then table.insert(value, self.options.items[index].id) end
    end
    return value
end

function CheckBoxGroup:setValue(value)
    local index = 0
    local item
    value = value or {}
    function in_array(id)
        for index, item_id in pairs(value) do
            if item_id == id then return true end
        end
        return false
    end 
    for name, child in pairs(self.children) do
        index = index + 1
        item = self.options.items[index]
        child:setValue(in_array(item.id))
    end
end 

function CheckBoxGroup:getProps(props)
    props.type = "flow"
    props.direction = "horizontal"
    return props
end

-- @export
return CheckBoxGroup