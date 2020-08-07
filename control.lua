--control.lua


local trains = require("train")


script.on_event(defines.events.on_player_changed_position, trains.on_player_exits_train)

script.on_event(defines.events.on_player_driving_changed_state, trains.on_player_enters_train)

script.on_event(defines.events.on_tick, trains.on_init )

script.on_event(defines.events.on_train_created, trains.on_created)

-- register event handlers
-- when players mined rolling stocks
script.on_event(defines.events.on_player_mined_entity, trains.on_player_mined_or_destroyed, {{filter="rolling-stock"}})

-- when rolling stock destoryed
script.on_event(defines.events.on_entity_died, trains.on_player_mined_or_destroyed, {{filter="rolling-stock"}})

-- script.on_event(defines.events.on_player_rotated_entity, function(e) 

--     game.print(math.random() .."-----".. e.previous_direction)

-- end )




-- script.on_event(defines.events.on_entity_died, function(e) debug("cliffs") end, {{filter= "type", type = "cliff" }})

-- script.on_event(defines.events.on_entity_damaged, function(e) game.print("cliffs") end )