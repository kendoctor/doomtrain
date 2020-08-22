local Class = require("oop.class")
local GuiBuilder = Class.create()

function GuiBuilder:__constructor(props)
    self.guiFactory = props.guiFactory
    if self.guiFactory == nil then error("GuiBuilder:__constructor, invalid guiFactory.") end 
    self.type = props.type or "container"
    self.data = props.data
    self.options = props.options
    self.parent = props.parent
    self.children = {}
    self.cached_gui = nil
    self.locked = false 
end 

function GuiBuilder:add(type, options, name)
    return self:In(type, options, name).parent
end 


function GuiBuilder:In(type, options, name)
     -- if Class.subclassof(child) == "GuiBuilder" then 
    local child = self.guiFactory:createBuilder(type, nil, options)    
    child.name = name 
    child.parent = self
    table.insert(self.children, child)
    return child
end 

function GuiBuilder:Out()
    --- parent nil 
    return self.parent
end 

function GuiBuilder:isRoot()
    return self.parent == nil
end 

function GuiBuilder:getGui()
    if self.locked then return self.cached_gui end 
    --- type is string or function ?
    -- self.cached_gui = self.type(self.name, self.data)

    self.cached_gui = self.guiFactory:create(self.name, self.type, nil, self.options)
    -- @fixme if gui is an container
    -- if Class.subclassof(classof(self.cached_gui), )
    if self.children then 
        for _, builder in pairs(self.children) do 
            self.cached_gui:add(builder:getGui())
        end 
    end 
    self.locked = true
    return self.cached_gui
end 

-- @export
return GuiBuilder