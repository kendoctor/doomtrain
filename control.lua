-- control.lua
local GameManager = require("facto.gamemanager")
GameManager.run()

-- local Class = require("oop.class")
-- local serpent = require("serpent")

-- Dog = Class.create()

-- log(serpent.dump(global))


-- require("utils")
-- local GlobalObjectManager = require("oop.globalobjectmanager")
-- local Event = require("event")
-- local Train = require("lib.train.train")

-- GlobalObjectManager.init()



-- local f1 = function(e) game.print("120-1----"..math.random()) end
-- local f2 = function(e) game.print("120-2----"..math.random()) end

-- local tested1  = false 
-- local tested2  = false 
-- local tested3  = false 

-- Event.on(defines.events.on_tick, function(e) 
--     if e.tick % 120 == 0 then 
--         game.print(string.format( "on_tick --- token:%s, tick:%s, nth tick:%s", math.random(), e.tick, e.nth_tick ))
--     end 
-- end )

-- Event.on_nth_tick(1, function(e) 
--     if tested1 then return end 
--     tested1 = true 
--     game.print(string.format( "on_nth_tick --- token:%s, tick:%s, nth tick:%s, event:%s", math.random(), e.tick, e.nth_tick, e.name ))
-- end )


-- Event.on_nth_tick(1, function(e) 
--     if tested2 then return end 
--     tested2 = true 
--     game.print(string.format( "on_nth_tick --- token:%s, tick:%s, nth tick:%s, event:%s", math.random(), e.tick, e.nth_tick, e.name ))
-- end )

-- Event.on_loaded( function(e) 
--     game.print(string.format( "on_loaded1 --- token:%s, tick:%s, nth tick:%s", math.random(), e.tick, e.nth_tick ))
-- end )


-- Event.on_loaded( function(e) 
--     game.print(string.format( "on_loaded2 --- token:%s, tick:%s, nth tick:%s", math.random(), e.tick, e.nth_tick ))
-- end )




-- --test
-- local o = Serializable:new()



-- Event.on(defines.events.on_player_changed_position, trains.on_player_exits_train)
-- Event.on(defines.events.on_player_driving_changed_state, trains.on_player_enters_train)
-- Event.on(defines.events.on_tick, trains.on_init )
-- Event.on(defines.events.on_train_created, trains.on_created)


-- Event.set(defines.events.on_player_mined_entity, trains.on_player_mined_or_destroyed, {{filter="rolling-stock"}})
-- when rolling stock destoryed
-- Event.set(defines.events.on_entity_died, trains.on_player_mined_or_destroyed, {{filter="rolling-stock"}})

-- Event.on(defines.events.on_player_mined_entity, IOBridges.on_removed)
-- Event.on(defines.events.on_entity_died, IOBridges.on_removed)

-- Event.on_nth_tick(60, trains.on_io)



---test
-- Event.on(defines.events.on_player_changed_position, f1)
-- Event.on(defines.events.on_player_changed_position, function(e) game.print("120-1----"..math.random()) end)
-- Event.on(defines.events.on_player_changed_position, function(e) game.print("120-2----"..math.random()) end)
-- Event.on(defines.events.on_player_changed_position, f2)
-- Event.remove(defines.events.on_player_changed_position, f2)
-- Event.set(defines.events.on_player_changed_position, f1)

-- Event.on_nth_tick(120, f1 )
-- Event.on_nth_tick(120, f2 )
-- Event.on_nth_tick(80, function(e) game.print("80-1----"..math.random()) end )
-- Event.on_nth_tick(80, function(e) game.print("80-2----"..math.random()) end )
-- Event.remove_nth_tick(120, f1)
-- Event.remove_nth_tick(80)



-- Event.on_nth_tick(60, IOBridges.on_exchange) 


-- Test 

