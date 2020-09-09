Gm = require("facto.gamemanager").getInstance()
Event = Gm.Event

setmetatable(global, { __newindex = function(table, key, value)
    rawset(table,key,value)
    -- table[key] = value
    game.print(string.format("key(%s):vlaue(%s)", key, value))
end })

log(string.format(serpent.block(global)))

Event.on(Event.facto.on_player_created, function(e)
    game.print(string.format("on_player_created, player index(%s), event name(%s), game tick(%s)", e.player_index, e.name, e.tick))
end)

Event.on(Event.facto.on_player_joined_game, function(e)
    game.print(string.format("on_player_joined_game1, player index(%s), event name(%s), game tick(%s)", e.player_index, e.name, e.tick))
end)

Event.on(Event.facto.on_player_joined_game, function(e)
    game.print(string.format("on_player_joined_game2, player index(%s), event name(%s), game tick(%s)", e.player_index, e.name, e.tick))
end)

Event.onInit(function()
    global.my_data = global.my_data or {}
end)

Event.on(Event.facto.on_player_created, function(e)
    global.my_data[e.player_index] = { player = game.get_player(e.player_index), tick = e.tick, joined_times = 0 }
end)

Event.on(Event.facto.on_player_joined_game, function(e)
    local player = global.my_data[e.player_index]
    player.joined_times = player.joined_times + 1
end)

Event.onLoad(function()
    log(serpent.block(global.my_data))
end)

-- Event.on(Event.facto.on_player_mined_entity, function(e)
--     global.start_timeout_tick = e.tick
--     if global.token_of_timeout_timer then Event.remove(Event.facto.on_tick, global.token_of_timeout_timer) end 
--     global.token_of_timeout_timer = Event.on(Event.facto.on_tick, function(e)
--         if e.tick - global.start_timeout_tick > 180 then 
--             game.print("180 ticks elapsed")
--             game.print(global.token_of_timeout_timer)
--             Event.remove(Event.facto.on_tick, global.token_of_timeout_timer)
--             global.token_of_timeout_timer = nil
--         end 
--     end)
-- end)

-- Event.on(Event.facto.on_player_mined_entity, function(e)
--     if global.token_of_interval_timer == nil then 
--         global.start_interval_tick = e.tick
--         global.token_of_interval_timer = Event.on(Event.facto.on_tick, function(e)
--             if (e.tick - global.start_interval_tick) % 300 == 0 then 
--                 game.print("300 ticks elapsed")
--                 game.print(global.token_of_interval_timer)
--             end 
--         end)
--     end 
-- end)

-- Event.on(Event.facto.on_player_mined_entity, function(e)
--     Event.createTimeoutTimer(function(e, token)
--         game.print(token)
--     end, 300)
--     Event.createIntervalTimer(function(e, token) 
--         game.print(token)
--     end, 180)
-- end)

Event.on(Event.facto.on_player_mined_entity, function(e)
    Event.createTimeoutTimer(function(e, token)
        game.print(token)
    end, 300)
    if global.interval_token == nil then 
        global.interval_token = Event.createIntervalTimer(function(e, token) 
            game.print(token)
            Event.removeTimer(token)
            global.interval_token = nil
        end, 180)
    end 
end)


Event.register({
    "on_player_joined_game"
})

Event.on(Event.facto.on_player_joined_game, function(e)
    Event.raise(Event.custom.on_player_joined_game, { name = e.name, tick = e.tick, custom_data = "hello" } )
end)

Event.on(Event.custom.on_player_joined_game, function(e)
    game.print(e.custom_data)
end)

