Event = Event or require("facto.event")
local count = 0
function dbg(message)
    count = count + 1
    message = string.format("ID#%s, %s", count, message)
    log(message)
    if Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME then game.print(message) end 
end 

-- assert(Event.LIFECYCLE == Event.LIFECYCLE_CONTROLE_INIT)

-- -- Test script.on_init
-- Event.on_init(function() 
--     dbg("on_init1")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_SCRIPT_INIT)
-- end)

-- --- Test multiple handlers
-- Event.on_init(function() 
--     dbg("on_init2")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_SCRIPT_INIT)
-- end)

-- -- Test script.on_init
-- Event.on_load(function() 
--     dbg("on_load1")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_SCRIPT_LOAD)
-- end)

-- --- Test multiple handlers
-- Event.on_load(function() 
--     dbg("on_load2")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_SCRIPT_LOAD)
-- end)

-- -- Test script.on_init
-- Event.on_configuration_changed(function() 
--     dbg("on_configuration_changed1")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_SCRIPT_CONFIGURATION)
-- end)

-- --- Test multiple handlers
-- Event.on_configuration_changed(function() 
--     dbg("on_configuration_changed2")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_SCRIPT_CONFIGURATION)
-- end)

-- --- Test runtime events
-- Event.on(Event.facto.on_player_joined_game, function(e) 
--     dbg("on_player_joined_game1")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME)
-- end)

-- --- Test multiple handlers
-- Event.on(Event.facto.on_player_joined_game, function(e) 
--     dbg("on_player_joined_game2")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME)
-- end)

-- --- Test facto intrinsic defines.events
-- Event.on(defines.events.on_player_joined_game, function(e) 
--     dbg("defines.events.on_player_joined_game")
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME)
-- end)

-- --- Test remove event handler by token
-- local h1 = function(e) 
--     assert(false)
-- end
-- local token1 = Event.on(Event.facto.on_player_joined_game, h1)
-- Event.remove(Event.facto.on_player_joined_game, token1)

-- --- Test remove all handlers of one event
-- Event.on(Event.facto.on_player_changed_position, function() assert(false) end)
-- Event.on(Event.facto.on_player_changed_position, function() assert(false) end)
-- Event.remove(Event.facto.on_player_changed_position, nil)


-- --- Test add event handler in event
-- Event.on(Event.facto.on_player_mined_entity, function(e)
--     Event.on(Event.facto.on_player_changed_position, function()
--         -- MUST use global scope upvalues, any local upvalue not allowed
--         dbg("event hander in event")
--     end)
-- end)

-- --- Test Complex vars
-- Dog = { name = "juejue" }
-- function Dog:bark(name) 
--     dbg("wangwang"..self.name..":"..name)
-- end 
-- Event.on(Event.facto.on_player_mined_entity, function(e)
--     Event.on(Event.facto.on_player_changed_position, function(e)
--         -- MUST use global scope upvalues, any local upvalue not allowed
--         local player = game.players[e.player_index]
--         Dog:bark(player.name)
--     end)
-- end)


-- --- Test nth tick events
-- Event.on_nth_tick(120, function() 
--     dbg("120 ticks per cycle1") 
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME)
-- end )

-- --- Test multiple handlers
-- Event.on_nth_tick(120, function() 
--     dbg("120 ticks per cycle2") 
--     assert(Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME)
-- end )

-- local h2 = function(e) 
--     assert(false)
-- end
-- --- Test remove nth tick handler
-- local token2 = Event.on_nth_tick(30, h2)
-- local h3 = Event.remove_nth_tick(30, token2)
-- assert(h2 == h3)

-- -- --- Test remove all handlers of nth tick
-- Event.on_nth_tick(30, function() assert(false) end)
-- Event.on_nth_tick(30, function() assert(false) end)
-- Event.on_nth_tick(30, function() assert(false) end)
-- Event.remove_nth_tick(30)

-- --- Test customized events
-- Event.register({
--     "on_my_event",
--     "on_your_event"
-- })
-- Event.on(Event.custom.on_my_event, function(e) 
--     dbg(string.format("on_my_event, name:%s, tick:%s, data:%s", e.name, e.tick, e.data)) 
-- end)
-- --- Test can not raise event at Event.LIFECYCLE_CONTROLE_INIT stage
-- --  Event.raise(Event.custom.on_my_event, { data = "my_event" })
-- Event.on_init(function() 
--     dbg("on_init")
--     -- it's not allowed to raise event at on_init stage
--     -- Event.raise(Event.custom.on_my_event, { data = "raised in on_init" })
-- end)
-- Event.on_load(function() 
--     dbg("on_init")
--     -- it's not allowed to raise event at on_load stage
--     -- Event.raise(Event.custom.on_my_event, { data = "raised in on_load" })
-- end)
-- local b = true
-- Event.on_nth_tick(120, function() 
--     -- if b == true then 
--         Event.raise(Event.custom.on_my_event, { data = "raised in on_nth_tick" })
--         -- b = false
--     -- end
-- end)

-- --- Test invalid serialization handler 
-- x = 1
-- Event.on(Event.facto.on_player_mined_entity, function(e)
--     Event.on(Event.facto.on_player_changed_position, function(e)
--         x = x + 1
--     end)
-- end)

--- Test a simple time Timer implementation, using nth_tick is not perfect, should use on_tick
Event.on(Event.facto.on_player_mined_entity, function(e)
    global.timers = global.timers or {}
    global.timers[#global.timers+1] = Event.on_nth_tick(300, function() 
        dbg("Timer is out.")
        Event.remove_nth_tick(300, global.timers[#global.timers])
        global.timers[#global.timers] = nil
    end) 
end)