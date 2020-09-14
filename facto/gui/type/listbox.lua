local Class = require("facto.class")
local AbstractType = require("facto.gui.abstracttype")
local ListBox = Class.extend({}, AbstractType)
ListBox.type = "listbox"

ListBox.RuleSupports = {
    "color", "height", "width", "font"
}

local function parse_items(items)
    local retval = {}
    for index, item in ipairs(items) do
        table.insert(retval, item.description)
    end
    return retval
end 

function ListBox:initialize()
    self.options.items = self.options.items or {}
end 

function ListBox:getProps(props)
    props.type = "list-box"
    props.items = parse_items(self.options.items)
    return props
end 

function ListBox:addItem(item, index)
    table.insert(self.options.items, item)
    self.factoobj.add_item(item.description)
end

function ListBox:clearItems()
    --@todo if dynamic binding, should update data
    self.options.items = {}
    self.factoobj.clear_items()
end

--[[
    function transformer(value)
        if type(value) == "table" then 
            return value:getId()
        else 
            return Service:getById(id)
        end
    end
]]
function ListBox:getValue()
    -- self.option.id_to_object
end

-- @todo before setValue, if value is object then, translate to id
function ListBox:setValue(value)
    -- self.options.object_to_id = function() end 
    local selected_index, item
    for index, item in pairs(self.options.items) do
        if item.id == value then 
            selected_index = index
            break
        end 
    end
    self.factoobj.selected_index = selected_index or 0
end

function ListBox:removeItemById(id)
    local remove_index, item
    for index, item in pairs(self.options.items) do
        if item.id == id then 
            remove_index = index
            break
        end 
    end
    if remove_index ~= nil then 
        table.remove(self.options.items. remove_index)
        self.factoobj.remove_item(remove_index) 
    end
end

-- @export
return ListBox