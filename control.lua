-- control.lua
-- require("test.eventcomponent")

function abc()
    game.print("hello")
end 
script.on_event(defines.events.on_player_joined_game,function(e)

end)


-- @section demo1


-- Event = Gm.Event
-- GuiFactory = Gm.GuiFactory
-- -- Event.on(Event.facto.on_player_joined_game, function() 
-- --     game.print("joined")    
-- --     Event.on(Event.facto.on_player_mined_entity,function() 
-- --         game.print("mined")        
-- --     end)
-- -- end)
-- local Window = require("facto.gui.type.window")

-- Event.on(Event.facto.on_player_joined_game, function(e)
--     local player = game.get_player(e.player_index)
--     -- local pop = GuiFactory:get(name, player, GuiFactory.ROOT_TOP, function(builder)
--     --     builder:add()
--     -- end)
    
--     GuiFactory:getGui("hello", player, GuiFactory.ROOT_SCREEN, function(factory) 
--         return factory:createBuilder(Window, { player_name = "kendoctor" }, { title = "hello", hideclose = true })
--             :add("player_name", "text")
--             :add(nil, "text")
--             :add(nil, "button", { caption = "ok" })            
--             :onclick(function(root, target) 
--                 local style = GuiFactory:createStyleBuilder()
--                 :add("button", "color:red;font:default-large")
--                 :add("text", "width:30;height:50")
--                 :getStyle()

--                 local style2 = GuiFactory:createStyleBuilder()
--                 :add("button", "color:crimson;font:default")
--                 :add("text", "width:10;height:150")
--                 :getStyle()
--                 if game.tick % 2 == 0 then 
--                     root:applyStyle(style)
--                 else
--                     root:applyStyle(style2)
--                 end 
--             end)
--     end)

--     GuiFactory:getGui("topbar", player, GuiFactory.ROOT_TOP, function(factory)
--         return factory:createBuilder("button", {}, { caption = ">" } )
--         -- :add("togglebutton", "button", { caption = ">" } )
--         :onclick(function(root, target, player) 
--             GuiFactory:getGui("hello", player, GuiFactory.ROOT_SCREEN):toggle()
--         end)
--     end)
--     -- game.print("hello")
--     -- popup:toggle()

--     -- local popup = GuiFactory:getGui("hello", player, GuiFactory.ROOT_TOP) or 
--     --     GuiFactory:createBuilder("hpanel", { player_name = "kendoctor" }, { caption = "hello" })
--     --         :add("player_name", "text")
--     --     -- :add(nil, "text")
--     --         :add(nil, "button", { caption = "ok" })
--     --     :getGui("hello", player, GuiFactory.ROOT_TOP)
--     --     :onclick(function(root, target) 
--     --         local style = GuiFactory:createStyleBuilder()
--     --         :add("button", "color:red;font:default-large")
--     --         :add("text", "width:30;height:50")
--     --         :getStyle()
--     --         root:applyStyle(style)
--     --     end)
--         -- :applyStyle(style)
--         -- :style(GuiFactory:createStyle(

--         -- ))
--         -- :onsubmit()
--         -- :ondatachanged()


--         -- popup:show()
--     -- local flow = player.gui.top.add({name = "p1", caption= "yes", type = "flow" })
--     -- flow.add({name = "p1", caption= "yes", type = "button" } )
--     -- player.gui.left.add({name = "p1", caption= "yes", type = "button" })
--     -- local popup = Gui:createBuilder(name)
--     -- :add()
--     -- :add(type, options, name, function(builder)
            
--     -- end)
--     -- :on(event, function(e)
--     --     e.gui:hide()
--     -- end)
--     -- :applyStyle()
--     -- :style(function(sb) -- selector builder
--     --     sb.add("selector", "color:red;")
--     -- end)
--     -- :getGui()
--     -- popup:show(name, player, Gui.ROOT_TOP)
--     -- popup:hide(name, player, Gui.ROOT_LEFT)
-- end)

-- Event.on(Event.facto.on_gui_click, function(e)
--     game.print(e.element.name)
-- end)

-- Gui = Gm.gui

-- local popup = Gui.createBuilder()
--     :getGui()

-- popup - should be serialized




-- require("utils")
-- require("test.event")


-- @section test
-- require("test.event")

-- local Event = require("facto.event")
-- local GameManager = require("facto.gamemanager")
-- GameManager.run()
-- local guiFactory = require("facto.gui.guifactory").getInstance()
-- -- local Player = require("facto.player.player")

-- local flips = {}
-- for key, value in pairs(defines.events) do 
--     flips[value] = key 
-- end 
-- script.on_event(defines.events, function(e) 
--     log(string.format("name(%s), tick(%s)", flips[e.name], e.tick))
-- end)
--1. data binding 
--2. event 
--3. style
-- Event.on_loaded(function() 
--         local player = game.players[1]
--         player.gui.center.clear()
        
--         local gui = guiFactory:createBuilder(nil, { name = "something" })
--             :In("hpanel")
--                 :In("hflow")
--                     :add("label", { caption = "Health"} )
--                     :add('progressbar')
--                     :add("label", { caption = "[color=red]red[/color]"} )
--                     :add('progressbar')
--                     :add("label", { caption = "Energy"} )
--                     :add('progressbar')
--                 :Out()
--                 -- :In("hflow")
--                 --     :add("label", { caption = "Address"} )
--                 --     :add("text", {}, "name_2")
--                 -- :Out()
--                 -- :add("button", { caption = "Confirm" })
                
--             :Out()
--             :getGui()
--             -- :on("submit", function(e) 
--                 -- e.data 
--                 -- e.gui:isValid()
--                 -- e.gui:getData()
--                 -- e.gui:update()
--             -- end)
--         gui:show("popup2", player.gui.top)

-- end)

-- local Class = require("facto.class")

-- local GuiBuilderFactory = Class.create()
-- local GuiBuilder = Class.create()
-- local Gui = Class.create()
-- Gui.Type = {}

-- local Base = Class.create()
-- Gui.Type.Base = Base

-- function Base:__constructor(props)
--     props = props or {}
--     for k,v in pairs(props) do self[k] = v end 
--     self.children = {}
--     self:initialize()
-- end 
-- function Base:initialize()
-- end 

-- local Text = Class.extend({}, Base)
-- Gui.Type.Text = Text

-- function Text:buildLuaGuiElement(name)
--     return { name = name, type = "textfield" }
-- end 

-- function Text:attach(name, parent)
--     local lua_gui_element = parent.add(self:buildLuaGuiElement(name))
--     -- --- lua_gui_element.sytle()
--     -- for name, gui in pairs(self.children) do 
--     --     gui:attach(name, lua_gui_element)
--     -- end 
-- end 

-- local Label = Class.extend({}, Text)
-- Gui.Type.Label = Label

-- function Label:buildLuaGuiElement(name)
--     return { name = name, type = "label", caption = "something" }
-- end 

-- local Container = Class.extend({}, Base)
-- Gui.Type.Container = Container

-- function Container:add(name, gui)
--     --- check if already exists with the name
--     self.children[name] = gui
--     gui.parent = self
-- end 

-- -- function Container:addIn(name, gui)
-- --     self.children[name] = gui
-- --     gui.parent = self
-- -- end 

-- function Container:buildLuaGuiElement(name)
--     return { name = name, type = "flow" }
-- end 

-- function Container:attach(name, parent)
--     local lua_gui_element = parent.add(self:buildLuaGuiElement(name))
--     --- lua_gui_element.sytle()
--     for name, gui in pairs(self.children) do 
--         gui:attach(name, lua_gui_element)
--     end 
-- end 

-- function Container:show(name, root)
--     if not root[name] then 
--         self:attach(name, root)
--     end 
-- end 

-- local Panel = Class.extend({}, Container)
-- Gui.Type.Panel = Panel


-- function Panel:buildLuaGuiElement(name)
--     return { name = name, type = "frame" }
-- end 

-- -- Gui.Type.Text = Class.create()

-- -- --- prix[name]
-- function GuiBuilderFactory:createBuilder(type, data, options)
--     return GuiBuilder()
-- end 

-- function GuiBuilder:__constructor(props)
--     self.type = props.type or Container
--     self.data = props.data
--     self.options = props.options
--     self.parent = props.parent
--     self.children = {}
--     self.cached_gui = nil
--     self.locked = false 
-- end 
-- function GuiBuilder:add(name, type, options)
--     -- if Class.subclassof(child) == "GuiBuilder" then 
--     if self.children[name] then error(string.format("Field %s already exisits.", name)) end 
--     self.children[name] = GuiBuilder({ type = type, parent = self })
--     return self
-- end 

-- function GuiBuilder:In(name, type, options)
--      -- if Class.subclassof(child) == "GuiBuilder" then 
--     if self.children[name] then error(string.format("Field %s already exisits.", name)) end 
--     local child = GuiBuilder({ type = type, parent = self })
--     self.children[name] = child 
--     return child
-- end 

-- function GuiBuilder:Out()
--     --- parent nil 
--     return self.parent
-- end 

-- function GuiBuilder:isRoot()
--     return self.parent == nil
-- end 

-- function GuiBuilder:getGui()
--     if self.locked then return self.cached_gui end 
--     --- type is string or function ?
--     self.cached_gui = self.type(self.name, self.data)
--     for name, builder in pairs(self.children) do 
--         self.cached_gui:add(name, builder:getGui())
--     end 
--     return self.cached_gui
-- end 

-- function Gui:applyStyle(lua_gui_element)
-- end 

-- -- gui:attach(player.gui.top)
-- -- same gui layout only can exist one at the same time 
-- -- or mutiple same gui layout ?
-- function Gui:attach(root)
--     -- name exists 
--     local lge = root.add(self:getProps())
--     self:applyStyle(lge)
--     for name, gui in pairs(self.children) do 
--         gui:attach(lge)
--     end 
-- end 

-- function Gui:show(name, root)
-- end

-- function Gui:hide()
-- end 

-- function Gui:destroy()
-- end 



-- Event.on_loaded(function() 
--     local player = game.players[1]
--     player.gui.center.clear()
    
--     local gui = GuiBuilder({})
--         :In("frame1", Panel)
--             :add("L-1", Label)
--             :add("T-1", Text)
--             :add("L-2", Label)
--             :add("T-2", Text)
--         :Out()
--         :getGui()
--     gui:show("popup2", player.gui.center)
--     -- local gui = GuiBuilder(type, data, options)
    --     :add("name_1", "label")
    --     :add("name_2", "text")
    --     :getGui()
    -- gui.show("popup", player.gui.screen)
    -- --more complex
    -- gui =  guiFactory:createBuilder(type, data, options)
    --     :add(...)
    --     :getGui()
    -- gui.show("popup", player.gui.screen)
    -- -- Vue style
    -- local template = [[
    --     <div >
    --         .....
    --     </div>
    -- ]]
    -- local style = [[
    --     .selection { color:red }
    --     ....
    -- ]]
    -- guiFactory:createTemplateBuilder(template, style)
    --     :getGui()




    -- local player = game.players[1]
    -- local e 
    -- debug(player.name)
    -- local top = player.gui.top
    -- -- local e = top.add({ type="label", name="label-name", caption="label_caption"} )
    -- -- e.style.font_color = {r = 139, g = 0, b = 0}
    -- local center = player.gui.center 
    
    -- if not center["Popup[name]"] then 
    --     debug("something....")
    --     local frame = center.add({name = 'Popup[name]', type = 'frame', direction = 'vertical', caption="frame"})
    -- end 
    -- center.clear()
-- end)
--     frame.add({ type="label", name="label-name", caption="label_caption"} )
--     frame.add({ type="button", name="button-name", caption="button_caption"} )
--     frame.add({ type="line", name="line-name", caption="checkbox_caption"} )
--     frame.add({ type="checkbox", name="checkbox-name", caption="checkbox_caption", state = true } )
--     frame.add({ type="radiobutton", name="radiobutton-name", caption="radiobutton_caption", state = true } )
--     frame.add({ type="progressbar", name="progressbar-name"} )
--     frame.add({ type="textfield", name="textfield-name"} )
--     frame.add({ type="text-box", name="textbox-name"} )
--     frame.add({ type="drop-down", name="drop-down-name"} )
--     e = frame.add({ type="list-box", name="list-box-name"} )
--     e.items = {"one","two"}
--     e = frame.add({ type="camera", position ={ x = 20, y = 20}, name="camera-name"} )
--     e = frame.add({ type="choose-elem-button",  name="choose-elem-button-name", elem_type = "item"} )
--     e = frame.add({ type="choose-elem-button",  name="choose-elem-button-name2", elem_type = "tile"} )
--     e = frame.add({ type="choose-elem-button",  name="choose-elem-button-name3", elem_type = "entity"} )
--     e = frame.add({ type="choose-elem-button",  name="choose-elem-button-name4", elem_type = "signal"} )
--     e = frame.add({ type="minimap",  name="minimap" } )
--     e = frame.add({ type="tab",  name="tab", badge_text="af"} )
--     e = frame.add({ type="switch",  name="switch"} )
   
-- end)


