-- Get game manager which provides services.
Gm = require("facto.gamemanager").getInstance()
-- Get event dispatcher service
Event = Gm.Event
-- Get gui service which is a GuiFactory type
GuiFactory = Gm.GuiFactory

Event.on(Event.facto.on_player_joined_game, function(e) 
    local player = game.get_player(e.player_index)
    game.print("joined")
    -- via gui service, create a GuiBuilder
    GuiFactory:createBuilder("panel", { editor = "something" }, { caption = "hello world", direction1 = "horizontal" } )      
        :add(nil, "separator", { direction1 = "vertical" })
        :add(nil, "progressbar", {  })
        :add(nil, "checkbox", {caption = "hello world"  })
        :add("r1", "radio", {caption = "hello world"  })
        :add("r2", "radio", {caption = "hello world"  })
        :add(nil, "sprite", { caption = "hello world", path = "utility/expand" })
        :add(nil, "dropdown", { caption = "hello world" , items = { "apple", "pearl", "banana" } })
        :add(nil, "listbox", { caption = "hello world" , items = { "apple", "pearl", "banana" } })
        :add("editor", "textbox", { caption = "hello world" })
        :add(nil, "slider", { caption = "hello world" })
        :add(nil, "minimap", { caption = "hello world" })
        :add(nil, "switch", { caption = "hello world" })
        :add(nil, "tabpanel", { active_tab = "tab1" }, function(cb)
            cb
            :add("tab1", "textbox", { tab_caption = "tab1", caption = "asdf" })
            :add("tab2", "textbox", { tab_caption = "tab2", caption = "zz" })
            :add("tab3", "textbox", { tab_caption = "tab3", caption = "zz" })
        end)
        :getGui("test", player, GuiFactory.ROOT_SCREEN)

end)

-- -- Since gui related to players, we need a context which can access players.
-- Event.on(Event.facto.on_player_joined_game, function(e) 
--     local player = game.get_player(e.player_index)
--     -- via gui service, create a GuiBuilder
--     GuiFactory:createBuilder("button", {}, { caption = "hello world" } )      
--         :getGui("hello_world_button", player, GuiFactory.ROOT_TOP)
-- end)

-- Event.on(Event.facto.on_player_joined_game, function(e) 
--     local player = game.get_player(e.player_index)
--     -- Get the previously created gui if exists
--     local sidebar = GuiFactory:getGui("sidebar", player, GuiFactory.ROOT_LEFT, function(factory)
--         return factory:createBuilder("panel", {}, { caption = "hello world" } )
--             :add("my_text_field", "text")
--             :add("my_button", "button", { caption = "Confirm" })
--     end)    
-- end)

-- Event.on(Event.facto.on_player_joined_game, function(e) 
--     local player = game.get_player(e.player_index)
--     -- Get the previously created gui if exists
--     local popup = GuiFactory:getGui("popup", player, GuiFactory.ROOT_SCREEN, function(factory)
--         return factory:createBuilder("panel", {}, { caption = "hello world" } )
--         :add("my_button", "button", { caption = "Move" } )
--         :onclick(function(gui, target, player) 
--             game.print(target.name)
--             game.print(player.name)
--             gui:move(300,300)
--         end)
--     end)    
--     popup:center()
--     game.print("joined")
-- end)