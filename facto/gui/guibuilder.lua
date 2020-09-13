local Class = require("facto.class")
local typeof = type

--- A builder for creating Gui instances.
-- The root builder should be creating a form type.
-- @classmod
local GuiBuilder = Class.create()

local function is_valid_serialization_function(fnc)
    local i = 1
    while true do
        local name, value = debug.getupvalue(fnc, i)
        if name and name ~= "_ENV" then return false end 
        if not name then break end
        i = i + 1
    end
    return true
end

--- Class constructor.
-- @tparam string type
-- @tparam table data
-- @tparam table options
-- @tparam class<GuiFactory> factory
function GuiBuilder:__constructor(type, data, options, factory, root)
    local class 
    if factory == nil then error("GuiBuilder:__constructor, invalid factory.") end 
    self.factory = factory
    if typeof(type) == "table" then  -- and -- check type is derived from abstract type
        factory:register(type.type, type)
        class = type
        self.type = class.type
    else
        self.type = type or "form"
        class = factory:getClass(self.type)    
        if class == nil then error("GuiBuilder:__constructor, Gui type not registered.") end 
    end 
    self.data = data
    self.options = options or {}    
    self.parent = nil
    self.root = root or self
    self.children = {}
    self.handlers = {}
    self.gui = nil
    self.locked = false 
    self.current_zone = self
    class.buildGui(self, self.options)
    self.zones = class.buildZones(self)
    self.current_zone = self:currentZone() 
end 

function GuiBuilder:currentZone()
    if typeof(self.zones) ~= "table" then return self end 
    local index, zone = next(self.zones)
    if zone == nil then return self else return zone end 
end 

function GuiBuilder:add(name, type, options, children_builder_callback)
    -- return self:In(type, options, name).parent
    -- check self is a container
    local data, zone
    zone = self.current_zone
    -- form1, subform
    if typeof(self.data) == "table" then data = self.data[name] end
    name = name or self.factory:generateName()
    local cb = self.factory:createBuilder(type, data, options, self.root)
    cb.name = name
    cb.parent = zone
    zone.children[name] = cb
    -- check type is container type
    if typeof(children_builder_callback) == "function" then 
        children_builder_callback(cb)
    end 
    return self
end 

function GuiBuilder:get(name)    
    return self.children[name]
end 

--@todo the current solution for customized type is combining all styles, top level style has more priority.
function GuiBuilder:buildStyle(style_builder_callback)
    if typeof(style_builder_callback) ~= "function" then error("GuiBuilder:buildStyle, style_builder_callback should be function type.") end 
    local sb = self.factory:createStyleBuilder()
    style_builder_callback(sb)
    if self.style then 
        self.style = sb:getStyle():merge(self.style)
    else 
        self.style = sb:getStyle()
    end
    return self
end 

--- @todo id could be manually set, filter for specific element
function GuiBuilder:onclick(handler)
    if self:isRoot() then
        if typeof(handler) ~= "function" then error(" GuiBuilder:onclick, handler should be function type.") end
        if not is_valid_serialization_function(handler) then error("AbstractType.onclick, invalid handler for serialization.") end 
        self.handlers["onclick"] = self.handlers["onclick"] or {}    
        table.insert(self.handlers["onclick"], string.dump(handler))
    else
        self.root:onclick(handler)
    end 
    return self
end 

function GuiBuilder:isRoot()
    return self == self.root
end 

function GuiBuilder:getGui(name, player, root)
    local parent_factoobj
    if self.locked then return self.gui end     
    self.locked = true
    if not self:isRoot() then error("GuiBuilder:getGui, only root builder can call this function.") end 
    if typeof(name) ~= "string" then error("GuiBuilder:getGui, name is invalid.") end
    if player == nil then error("GuiBuilder:getGui, player is invalid.") end 
    parent_factoobj = player.gui[root] 
    if parent_factoobj == nil then error("GuiBuilder:getGui, root is invalid.") end
    if parent_factoobj[name] ~= nil then error(string.format("GuiBuilder:getGui, player.gui[%s].%s already exisits.", root, name)) end 
    self.name = name 
    self.id = string.format("%s_%s_%s", root, player.index, name)
    self:createGui(parent_factoobj)
    self.gui.handlers = self.handlers
    if self.style then self.gui:applyStyle(self.style) end 
    self.gui:onattached(self.gui) --- notify all children when attached
    return self.gui
end 

function GuiBuilder:createGui(parent_factoobj, root)
    if root then self.id = string.format("%s_%s", self.parent.id, self.name)  end 
    self.gui = self.factory
        :create(self.id, self.name, self.type, self.data, self.options, root)
        :attach(parent_factoobj)
    if root == nil then self.gui.root = self.gui end 
    if self.style then self.style:fix(self.name) end 
    if not self:isRoot() and self.style then  
        if self.root.style then self.root.style:merge(self.style)
        else self.root.style = self.style end
    end
    -- @fixme if gui is an container
    if self.children then 
        for _, builder in pairs(self.children) do 
            self.gui:add(builder:createGui(self.gui.factoobj, self.gui.root))
        end 
    end 
    return self.gui
end 

-- @export
return GuiBuilder