local Class = require("oop.class")
local GuiBuilder = require("facto.gui.guibuilder")
local GuiFactory = Class.create()

--- Constructor.
function GuiFactory:__constructor()
    self.registered = {}
    -- self.instanced = {}
end 

function GuiFactory:register(key, class)
    self.registered[key] = class
end 

function GuiFactory:getClass(key)
    return self.registered[key]
end 

function GuiFactory:setup()
    local class = require("facto.gui.type.container")
    self:register(class.type, class)
    class = require("facto.gui.type.hpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.vpanel")
    self:register(class.type, class)
    class = require("facto.gui.type.text")
    self:register(class.type, class)
    class = require("facto.gui.type.label")
    self:register(class.type, class)
    class = require("facto.gui.type.hflow")
    self:register(class.type, class)
    class = require("facto.gui.type.vflow")
    self:register(class.type, class)
    class = require("facto.gui.type.button")
    self:register(class.type, class)
end 
-- require("utils")
function GuiFactory:create(name, type, data, options)
    local class = self:getClass(type)
    if class == nil then error(string.format("GuiFactory:create, GuiType(%s) not found.", type)) end 
    -- debug(serpent.block(options))
    return class({ name = name, data = data, options = options })
end 

function GuiFactory:createBuilder(type, data, options)
    return GuiBuilder({ type = type, data = data,  options = options, guiFactory = self })
end 

local instance 
--- Get singleton instance.
function GuiFactory.getInstance()
    if instance == nil then 
       instance = GuiFactory()
       instance:setup()
    end 
    return instance
end 

-- @export
return GuiFactory