local Class = require("facto.class")
local ContainerType = require("facto.gui.containertype")


local TabPanel = Class.extend({}, ContainerType)
TabPanel.type = "tabpanel"
TabPanel.GuiBuilder = require("facto.gui.guitabpanelbuilder")

function TabPanel:initialize()
    TabPanel.super.initialize(self)
    self.tabs = {}
end 

function TabPanel:getProps(props)
    props.type = "tabbed-pane"
    return props
end

-- @todo
function TabPanel:activateTabByName(tab_name)
end 

-- @todo
function TabPanel:activateTab(tab)
end 

function TabPanel:activateTabByIndex(index)
    if self.active_tab_index == index then return true end
    self.factoobj.selected_tab_index = index
    self.active_tab_index = index
    return true 
end 

function TabPanel:addTab(tab, content)    
    self:add(tab)
    self:add(content)
    self.factoobj.add_tab(tab.factoobj, content.factoobj)
    -- table.insert(self.tabs, { tab = tab, content = content })
    -- if tab.name == self.options.active_tab then 
    --     self:activateTabByIndex(#self.tabs)
    -- end 
    return self
end 

-- @export
return TabPanel