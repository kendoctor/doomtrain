local Class = require("facto.class")
local AbstractFactory = require("facto.abstractfactory")
-- local GuiBuilder = require("facto.gui.guibuilder")
local StyleBuilder = require("facto.gui.stylebuilder")
local typeof = type

local GuiFactory = Class.extend({}, AbstractFactory)
GuiFactory.ROOT_TOP = "top"
GuiFactory.ROOT_LEFT = "left"
GuiFactory.ROOT_GOAL = "goal"
GuiFactory.ROOT_CENTER = "center"
GuiFactory.ROOT_SCREEN = "screen"

GuiFactory.events = {
    "on_gui_click"
}

--- Constructor.
function GuiFactory:__constructor(event)
    self.event = event
    GuiFactory.super.__constructor(self)
end 

function GuiFactory:initialize()
    self.serialize.token = 0
    -- self.event.register(GuiFactory.events)
    local Event = self.event
    Event.on(Event.facto.on_gui_click, function(e) self:on_gui_click(e) end)
    self:setup()
end 

-- @todo stopPropagation feature
function bubble_event(current_target, target)
    if current_target.options.onclick then 
        local h = (loadstring or load)(current_target.options.onclick)
        h(current_target.root, target, current_target.factoobj.gui.player)
    end
    if current_target.parent then bubble_event(current_target.parent, target) end
end

function GuiFactory:on_gui_click(e)
    -- @todo via e.element to get id 
    for id, instance in pairs(self.serialize.instanced) do 
        if instance.factoobj == e.element then 
            bubble_event(instance, instance)
            if instance.type == "submit" and instance.root.options.onsubmit then
                instance.root:submit()
                local h = (loadstring or load)(instance.root.options.onsubmit)
                h(instance.root, instance, instance.factoobj.gui.player)
            end
        end 
    end 
end 

function GuiFactory:setup()
    local AbstractType = require("facto.gui.abstracttype")
    AbstractType.factory = self
    local class = require("facto.gui.type.form")
    self:register(class.type, class)
    class = require("facto.gui.type.window")
    self:register(class.type, class)
    class = require("facto.gui.type.spritebutton")
    self:register(class.type, class)
    class = require("facto.gui.type.panel")
    self:register(class.type, class)
    class = require("facto.gui.type.hpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.vpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.radio")
    self:register(class.type, class)
    class = require("facto.gui.type.sprite")
    self:register(class.type, class)
    class = require("facto.gui.type.text")
    self:register(class.type, class)
    class = require("facto.gui.type.checkbox")
    self:register(class.type, class)
    class = require("facto.gui.type.separator")
    self:register(class.type, class)
    class = require("facto.gui.type.label")
    self:register(class.type, class)
    class = require("facto.gui.type.emptywidget")
    self:register(class.type, class)
    class = require("facto.gui.type.hflow")
    self:register(class.type, class)
    class = require("facto.gui.type.vflow")
    self:register(class.type, class)
    class = require("facto.gui.type.button")
    self:register(class.type, class)
    class = require("facto.gui.type.progressbar")
    self:register(class.type, class)
    class = require("facto.gui.type.dropdown")
    self:register(class.type, class)
    class = require("facto.gui.type.listbox")
    self:register(class.type, class)
    class = require("facto.gui.type.textbox")
    self:register(class.type, class)
    class = require("facto.gui.type.slider")
    self:register(class.type, class)
    class = require("facto.gui.type.minimap")
    self:register(class.type, class)
    class = require("facto.gui.type.switch")
    self:register(class.type, class)
    class = require("facto.gui.type.tab")
    self:register(class.type, class)
    class = require("facto.gui.type.tabpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.scrolllist")
    self:register(class.type, class)
    class = require("facto.gui.type.checkboxgroup")
    self:register(class.type, class)
    class = require("facto.gui.type.radiogroup")
    self:register(class.type, class)
    class = require("facto.gui.type.submit")
    self:register(class.type, class)
end 

function GuiFactory:generateName()
    self.serialize.token = self.serialize.token + 1
    return string.format("facto_auto_%s", self.serialize.token)
end 

function GuiFactory:getGui(name, player, root, children_builder_callback)
    local gui = self:get(string.format("%s_%s_%s", player.index, root, name))
    if gui ~= nil then return gui end 
    if typeof(children_builder_callback) == "function" then         
        local builder = children_builder_callback(self)        
        -- @fixme class check
        if builder then gui = builder:getGui(name, player, root) end
    end 
    return gui
end 

function GuiFactory:create(id, name, type, data, options, root)
    local class = self:getClass(type)
    if class == nil then error(string.format("GuiFactory:create, GuiType(%s) not found.", type)) end 
    local instance = class(id, name, data, options, root)
    instance.type = type
    self.serialize.instanced[instance:getId()] = instance
    return instance
end 

function GuiFactory:createBuilder(type, data, options, root)
    local class 
    -- @fixme Class.subclassof
    if typeof(type) == "table" then class = type else class = self:getClass(type) end 
    if class == nil or class.GuiBuilder == nil then error("GuiFactory:createBuilder, invalid type") end 
    return class.GuiBuilder(type, data, options, self, root)
end 

function GuiFactory:createStyleBuilder()
    return StyleBuilder()
end 

function GuiFactory:getDescriptionsOfAllGui()
    local all = {}
    for id, gui in pairs(self.serialize.instanced) do
        if gui:isRoot() then table.insert(all, gui:__tostring()) end  
    end
    return all
end 

function GuiFactory:getTypesRegistered()
    local all = {}
    for t, class in pairs(self.registered) do
        table.insert(all, { id = t, description = t })
    end
    return all
end 

function GuiFactory.guid()
    return "facto.gui.guifactory"
end 

local instance 
--- Get singleton instance.
function GuiFactory.getInstance()
    if instance == nil then 
       instance = GuiFactory()    
    --    instance:setup()
    end 
    return instance
end 

-- @export
return GuiFactory