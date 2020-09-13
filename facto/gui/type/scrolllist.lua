local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local ScrollList = Class.extend({}, ContainerType)
ScrollList.type = "scrolllist"

ScrollList.RuleSupports = {
    "color", "height", "width", "font"
}

function ScrollList.buildGui(builder, options)
    options.style = options.style or "scroll_pane"
    local list_options = options.list_options or {}
    list_options.items = list_options.items or options.list_items
    builder
    :add("list_box", "listbox", list_options)
    :buildStyle(function(sb)
        sb:add("@self", "height:160;width:240")
    end)
end 

function ScrollList:getProps(props)
    props.type = "scroll-pane"
    return props
end

function ScrollList:onattached(gui)

end 

-- @export
return ScrollList