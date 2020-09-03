local Class = require("oop.class")
local ContainerType = require("facto.gui.containertype")

--- A form represents HTML-like form.
--- A form stores its data in a table, table's fields will be bond to form's children.
-- @classmod Form
local Window = Class.extend({}, ContainerType)
Window.type = "window"

function Window.buildGui(builder, options)
    builder
    :add("header", "hflow", nil, function(cb) 
        cb:add("title", "label", { caption = options.title } )
        cb:add("drag-element", "empty-widget", { horizontally_stretchable = "true"  })
        cb:add("collapse", "sprite-button", { default = "utility/collapse", clicked = "utility/expand", style ="frame_action_button" } )
        cb:add("close", "sprite-button", { default = "utility/close_white", style ="frame_action_button"  } )
    end)
    :add("client", "form")
    :style(function(sb)
        sb:add("drag-element", "hstretch:on;min-width:0;nat-height:24;")
    end)
    :onclick(function(gui, target)
        if target.name == "close" then gui:close() end 
        if target.name == "collapse" then 
            local found = {}
            gui:findByName("client", found)
            found[1]:toggle()
        end 
    end)
end 

function Window.buildZones(builder)
    return { client = builder:get("client") }
end 

function Window:getProps(props)
    props.type = "frame"
    props.direction = "vertical"
    return props
end

function Window:close()
    if self.options.hideclose then self:hide() 
    else self:destroy() end 
end 

function Window:onattached(gui)
    local found = {}
    -- @todo mutiple names finding
    gui:findByName("drag-element", found)
    gui:findByName("title", found)    
    found[1].factoobj.drag_target = gui.factoobj
    gui.factoobj.location = {x = 300, y = 200}
    found[2].factoobj.drag_target = gui.factoobj
    Window.super.onattached(self, gui)
end 

-- @export
return Window