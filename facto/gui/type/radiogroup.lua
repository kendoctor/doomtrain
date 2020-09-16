local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local RadioGroup = Class.extend({}, ContainerType)
RadioGroup.type = "radiogroup"

function RadioGroup:initialize()
    self.children = {}
    self.options.binding_disabled = self.options.binding_disabled or false
end 

function RadioGroup.buildGui(builder, options)
    for index, item in pairs(options.items) do
        builder:add(nil, "radio", { caption = item.description, binding_disabled = true } )
    end
    builder:onclick(function(gui, target)
        if target.parent and target.parent.type == "radiogroup" then
            target.parent:switchRadio(target)
        end
    end)
end

function RadioGroup:switchRadio(target)
    for name, child in pairs(self.children) do
        if child == target then target:setValue(true) else child:setValue(false) end
    end
end

function RadioGroup:getValue()
    local index = 0
    for name, child in pairs(self.children) do
        index = index + 1
        if child:getValue() == true then return self.options.items[index].id end
    end
    return nil
end

function RadioGroup:setValue(value)
    local index = 0
    local item
    for name, child in pairs(self.children) do
        index = index + 1
        item = self.options.items[index]
        if item.id == value then child:setValue(true) end
    end
end 

function RadioGroup:getProps(props)
    props.type = "flow"
    props.direction = "horizontal"
    return props
end

-- @export
return RadioGroup