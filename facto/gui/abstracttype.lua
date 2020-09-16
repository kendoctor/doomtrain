local Class = require("facto.class")
local AbstractType = Class.create()

AbstractType.GuiBuilder = require("facto.gui.guibuilder")

AbstractType.ColorPresets = {
    maroon = {r = 128, g = 0, b = 0},
    dark_red = {r = 139, g = 0, b = 0},
    brown = {r = 165, g = 42, b = 42},
    firebrick = {r = 178, g = 34, b = 34},
    crimson = {r = 220, g = 20, b = 60},
    red = {r = 255, g = 0, b = 0},
    tomato = {r = 255, g = 99, b = 71},
    coral = {r = 255, g = 127, b = 80},
    indian_red = {r = 205, g = 92, b = 92},
    light_coral = {r = 240, g = 128, b = 128},
    dark_salmon = {r = 233, g = 150, b = 122},
    salmon = {r = 250, g = 128, b = 114},
    light_salmon = {r = 255, g = 160, b = 122},
    orange_red = {r = 255, g = 69, b = 0},
    dark_orange = {r = 255, g = 140, b = 0}
}

AbstractType.ColorRules = {
    "color"
}

AbstractType.RuleSupports = {
    "height", "width"
}

local function color_value_translator(value)
    -- if type(value) == "table" then return value end 
    local color = AbstractType.ColorPresets[value]
    if color == nil then error(string.format("Invalid color(%s).", value)) end 
    return color
end 

local function int_value_translator(value)
    return tonumber(value)
end 

local function string_value_translator(value)
    return tostring(value)
end 

local function boolean_value_translator(value)
    if value == "on" then return true 
    else return false end 
end 

AbstractType.RuleTranslations = {
    { "color", "font_color", color_value_translator },
    { "height", "height", int_value_translator },
    { "weight", "weight", int_value_translator },
    { "nat-height", "natural_height", int_value_translator },
    { "max-height", "maximal_height", int_value_translator },
    { "min-width", "minimal_width", int_value_translator },
    { "hstretch", "horizontally_stretchable", boolean_value_translator },
    { "font", "font", string_value_translator }
}

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

function AbstractType.buildGui(builder, options)
end 

function AbstractType.buildZones(builder)
end 

function AbstractType:__constructor(id, name, data, options, root)
    self.id = id
    self.name = name 
    self.data = data 
    self.options = options    
    self.root = root
    self.handlers = {}    
    self:initialize()
end 

function AbstractType:initialize()
    self.options.binding_disabled = self.options.binding_disabled or true
end 

function AbstractType:getName()
    return self.name
end 

function AbstractType:isContainer()
    return false
end 

function AbstractType:isRoot()
    if self == self.root then return true end 
    return false 
end 

function AbstractType:getId()
   return self.id
end 

function AbstractType:findById()
end 

function AbstractType:findByName(name, found)
    found = found or {}
    if self.name == name then return table.insert(found, self) end 
    return nil
end 

function AbstractType:getProps(props)
    error("AbstractType:getProps should be overridden.")
end 

function AbstractType:attach(parent)
    local props = { name = self.name, style = self.options.style, caption = self.options.caption }
    self.factoobj = parent.add(self:getProps(props))
    -- @todo apply style
    return self
end 

function AbstractType:onclick(handler)
    if not self:isRoot() then error("AbstractType.onclick, only root gui can add event handler.") end 
    if not is_valid_serialization_function(handler) then error("AbstractType.onclick, invalid handler for serialization.") end 
    self.handlers["onclick"] = self.handlers["onclick"] or {}
    table.insert(self.handlers["onclick"], string.dump(handler))
    return self
end 

function AbstractType:onattached(gui)
end 

function AbstractType:applyStyle(style)
   style:apply(self)
end 

function AbstractType:isColorRule(prop)
    if self.ColorRules[prop] then return true end 
    return false 
end 

function AbstractType:getTranslator(prop)
    for _, translation in pairs(self.RuleTranslations) do 
        if prop == translation[1] then 
            return translation[2], translation[3]
        end 
    end     
end 

function AbstractType:applyRule(prop, value)
    if not self:isRuleSupported(prop) then return end 
    if not self.factoobj then return end
    local prop, translator = self:getTranslator(prop)
    -- prop translator
    -- value translator
    if prop then 
        self.factoobj.style[prop] = translator(value)
    end 
end 

function AbstractType:isRuleSupported(prop)
    for _,rule in pairs(self.RuleSupports) do
        if rule == prop then return true end 
    end 
    return false
end 

function get_binding_data(self)
    return self.data
end 

function AbstractType:getData()
    if self:isRoot() then return get_binding_data(self) end
end 

-- get field presentation data
function AbstractType:getFieldValue()
end 

function AbstractType:submitData()
    -- game.print(self.name..":"..tostring(self.options.binding_disabled))
    if self.data and not self.options.binding_disabled and not self:isForm() then self.data[self.name] = self:getValue() end
end

function submit(self)
    self:submitData()
    if type(self.children) ~= "table" then return end
    for name, child in pairs(self.children) do
        submit(child)
    end
end 

function AbstractType:submit()
    if self:isRoot() then submit(self) end
end

function AbstractType:isForm()
    return false
end 

function AbstractType:setData(data)
    if self:isRoot() then 
        self.data = data
        self:updateData()
    end
end 

function AbstractType:updateData()
    if self.data == nil then return end
    local value = self.data[self.name] 
    -- value could be nil, maybe to clear the field
    -- not auto generated name or binding disabled
    if not self:isForm() and not self.options.binding_disabled then self:setValue(value) end 
    if type(self.children) ~= "table" then return end
    for name, child in pairs(self.children) do
        if self:isForm() and type(value) == "table" then 
            child.data = value
        elseif not self:isForm() then 
            child.data = self.data
        end
        child:updateData()
    end
end 

function AbstractType:getValue()
end 

function AbstractType:setValue(value)
end

function AbstractType:show()
    self.factoobj.visible = true
end 

function AbstractType:hide()
    self.factoobj.visible = false
end 

function AbstractType:toggle()
    if self.factoobj.visible == true then self:hide() else self:show() end
end 

function AbstractType:isValid()
    return self.factoobj and self.factoobj.valid
end 

function AbstractType:close()
    self:destroy()
end 

function AbstractType:destroy()
    self.factoobj.destroy()
    -- @fixme change the scope to remove gui types
    local factory = self.factory:remove(self)
end 

function AbstractType:move(x,y)
    if self.factoobj.location then 
        self.factoobj.location = { x, y }
    end 
end 

function AbstractType:__tostring()
    return string.format("Gui Type(%s), id(%s), name(%s)", self.type, self.id, self.name)
end

-- @export
return AbstractType