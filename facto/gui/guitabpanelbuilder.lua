local Class = require("facto.class")
local typeof = type
local GuiBuilder = require("facto.gui.guibuilder")

local GuiTabPanelBuilder = Class.extend({}, GuiBuilder)

function GuiTabPanelBuilder:__constructor(type, data, options, factory, root)
    GuiTabPanelBuilder.super.__constructor(self, type, data, options, factory, root)
    self.tabs = {}
end 

-- type should be TabPanel or derived classes, options.tab_type should be Tab or derviced classes
function GuiTabPanelBuilder:add(name, type, options, children_builder_callback)
    options = options or {}
    name = name or self.factory:generateName()
    local tab_type = options.tab_type or "tab"
    local tab_caption = options.tab_caption 
    local content_name = options.content_name or name.."_content"
    local tabcontent = {}
    GuiTabPanelBuilder.super.add(self, name, tab_type, { caption = tab_caption })
    GuiTabPanelBuilder.super.add(self, content_name, type, options, children_builder_callback)
    tabcontent.tab = self.children[name]
    tabcontent.content = self.children[content_name]
    table.insert(self.tabs, tabcontent)
    return self
end 

function GuiTabPanelBuilder:createGui(parent_factoobj, root)
    if root then self.id = string.format("%s_%s", self.parent.id, self.name)  end 
    self.gui = self.factory
        :create(self.id, self.name, self.type, self.data, self.options, root)
        :attach(parent_factoobj)
    if root == nil then self.gui.root = self.gui end 
    -- @fixme if gui is an container
    local active_tab_index 
    local index = 0
    if self.tabs then 
        for _, tabcontent in pairs(self.tabs) do 
            index = index + 1
            if self.options.active_tab == tabcontent.tab.name then active_tab_index = index end 
            self.gui:addTab(
                tabcontent.tab:createGui(self.gui.factoobj, self.gui.root),
                tabcontent.content:createGui(self.gui.factoobj, self.gui.root)
            )
        end 
        if index ~= 0 and active_tab_index == nil then active_tab_index = 1 end 
        self.gui:activateTabByIndex(active_tab_index)
        ---@todo default_selected_tab
    end 
    return self.gui
end 

-- @export
return GuiTabPanelBuilder
