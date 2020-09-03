local Class = require("oop.class")
local AbstractFactory = require("facto.abstractfactory")
local GuiBuilder = require("facto.gui.guibuilder")
local StyleBuilder = require("facto.gui.stylebuilder")
local Style = require("facto.gui.style")

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

function GuiFactory:on_gui_click(e)
    -- @todo via e.element to get id 
    for id, instance in pairs(self.serialize.instanced) do 
        if instance.factoobj == e.element then 
            local handlers = instance.root.handlers
            if handlers.onclick then 
                for _, serialized_handler in pairs(handlers.onclick) do 
                    if not instance:isValid() then break end 
                    local h = (loadstring or load)(serialized_handler)
                    h(instance.root, instance)
                end 
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
    class = require("facto.gui.type.hpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.vpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.text")
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
end 

function GuiFactory:generateName()
    self.serialize.token = self.serialize.token + 1
    return string.format("facto_auto_%s", self.serialize.token)
end 

function GuiFactory:getGui(name, player, root, children_builder_callback)
    local gui = self:get(string.format("%s_%s_%s", player.index, root, name))
    if gui ~= nil then return gui end 
    if type(children_builder_callback) == "function" then         
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
    return GuiBuilder(type, data, options, self, root)
end 

function GuiFactory:createStyleBuilder()
    return StyleBuilder(Style())
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