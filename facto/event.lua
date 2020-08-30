--- Event Class
-- If consider priority handlers, needs an array table to hold handlers, otherwise needs sorting before call
-- do we need coroutine to guarrantee on_loaded event which will be registered and triggered first ?
-- @classmod Event 

local Event = {}
Event.facto = defines.events
Event.custom = {}
Event.LIFECYCLE_CONTROLE_INIT = 0
Event.LIFECYCLE_SCRIPT_INIT = 1
Event.LIFECYCLE_SCRIPT_LOAD = 2
Event.LIFECYCLE_SCRIPT_CONFIGURATION = 4
Event.LIFECYCLE_RUNTIME = 8
Event.LIFECYCLE = Event.LIFECYCLE_CONTROLE_INIT
local facto_valid_raised_events = {
    Event.facto.on_console_chat,
    Event.facto.on_player_crafted_item, 
    Event.facto.on_player_fast_transferred,
    Event.facto.on_biter_base_built, 
    Event.facto.on_market_item_purchased, 
    Event.facto.script_raised_built, 
    Event.facto.script_raised_destroy, 
    Event.facto.script_raised_revive, 
    Event.facto.script_raised_set_tiles
}
local on_init = {}
local on_load = {}
local on_configuration_changed = {}
local on_events = defines.events
local token = 0

local handlers = {} 
local nth_tick_handlers =  {}
local persisted_handlers = {}
local persisted_nth_tick_handlers = {}
local serialize = {
    token = 0,
    persisted_handlers = persisted_handlers,
    persisted_nth_tick_handlers = persisted_nth_tick_handlers
}

local debug = debug

local function get_persisted_handler_token()
    serialize.token = serialize.token + 1
    return serialize.token 
end 

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

local function is_valid_raised_event(event)
    for _, valid_event in pairs(facto_valid_raised_events) do 
        if valid_event == event then return true end 
    end 
    for _, valid_event in pairs(Event.custom) do 
        if valid_event == event then return true end 
    end 
    return false 
end 

local function recover_persisted_handlers(serialized_handlers)
    for event, subhandlers in pairs(serialized_handlers) do 
        for token, serialized_handler in pairs(subhandlers) do 
            Event.on(event, (load or loadstring)(serialized_handler), token)
        end
    end 
end

local function recover_persisted_nth_tick_handlers(serialized_handlers)
    for tick, subhandlers in pairs(serialized_handlers) do 
        for token, serialized_handler in pairs(subhandlers) do 
            Event.on_nth_tick(tick, (load or loadstring)(serialized_handler), token)
        end
    end 
end

local function callHandlersOfSameEvent(event, local_event)
    local key 
    if local_event ~= nil then 
        key = local_event 
        if local_event == on_init then Event.LIFECYCLE = Event.LIFECYCLE_SCRIPT_INIT 
        elseif local_event == on_load then Event.LIFECYCLE = Event.LIFECYCLE_SCRIPT_LOAD 
        elseif local_event == on_configuration_changed then Event.LIFECYCLE = Event.LIFECYCLE_SCRIPT_CONFIGURATION end
    else key = event.name  end 
    if event ~= nil then Event.LIFECYCLE = Event.LIFECYCLE_RUNTIME end 
    for _, h in pairs(handlers[key]) do 
        if event == nil then h() 
        elseif local_event == on_events then 
            h(event)  
            local subhandlers = handlers[event.name] or {}
            for _,sh in pairs(subhandlers) do sh(event) end 
        else
            h(event)
        end 
    end 
    -- if local_event == on_init or local_event == on_load or local_event == on_configuration_changed then 
    --     Event.LIFECYCLE = Event.LIFECYCLE_RUNTIME
    -- end 
end 

--- Call Event.on_nth_tick(...) registered handlers
local function callHandlersOfSameTicks(event)
    Event.LIFECYCLE = Event.LIFECYCLE_RUNTIME
    for _, h in pairs(nth_tick_handlers[event.nth_tick]) do h(event)  end 
end 

--- Equals to script.on_init, but can have multiple handlers
function Event.on_init(handler)
    Event.on(on_init, handler)
end 

--- Equals to script.on_load, but can have multiple handlers
function Event.on_load(handler)
    Event.on(on_load, handler)    
end 

--- Equals to script.on_configuration_changed, but can have multiple handlers
function Event.on_configuration_changed(handler)
    Event.on(on_configuration_changed, handler)    
end 

function Event.register(events)
    if type(events) ~= "table" then error("Event.register, events should be table type.") end 
    for _, event_name in pairs(events) do 
        if Event.custom[event_name] == nil then 
            Event.custom[event_name] = script.generate_event_name()
        end 
    end 
end 

function Event.raise(event, data)
    if Event.LIFECYCLE ~= Event.LIFECYCLE_RUNTIME then error("Event.raise, raise event should be at Event.LIFECYCLE_RUNTIME stage.") end
    if not is_valid_raised_event(event) then error(string.format("Event.raise, event(%s) is not a valid raised event.", event)) end 
    script.raise_event(event, data)
end 

--- Add one handler for the specified event.
-- It is allowed to add mulitiple handlers for the same event.
-- @tparam  uint event event name defiend in defines.events or using Event.register registered.
-- @tparam  function handler if in Event.LIFECYCLE_RUNTIME, handler MUST have no upvalues excpet _ENV upvalue,
-- otherwise you can any type closures at other stage.
-- @tparam uint token not allowed pass this value manually, only for deserialization purpose
-- @treturn uint return an unit type token which can be used for hanlder removing.
function Event.add(event, handler, token)    
    if handler == nil then error("Using Event.remove to remove event handler.") end 
    if type(handler) ~= "function" then error("Handler should be callable.") end 
    token = token or get_persisted_handler_token()
    token = tostring(token)
    handlers[event] = handlers[event] or {}
    if Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME then 
        if not is_valid_serialization_function(handler) then error("Event.add, invalid handler for serialization.") end 
        persisted_handlers[event] = persisted_handlers[event] or {}
        -- check handler has matched upvalues(no upvalues or only one _ENV)
        persisted_handlers[event][token] = string.dump(handler)
    end 
    if next(handlers[event]) == nil then 
        if event == on_init then 
            script.on_init(function() callHandlersOfSameEvent(nil, on_init) end)              
        elseif event == on_load then 
            script.on_load(function() callHandlersOfSameEvent(nil, on_load) end)
        elseif event == on_configuration_changed then 
            script.on_configuration_changed(function() callHandlersOfSameEvent(nil, on_configuration_changed) end)
        elseif event == on_events then 
            --- should only be used for debuging
            script.on_event(on_events, function(e) callHandlersOfSameEvent(e, on_events) end)
        else 
            script.on_event(event, callHandlersOfSameEvent)
        end 
    end 
    handlers[event][token] =  handler
    return token
end 

--- A convenient function same with Event.add.
Event.on = Event.add
    
--- Set handler for one event.
-- This will remove other handlers of this event previously added
-- Filters can be applied, but only for one handler of each event 
-- NOTE: recommend not using this function
-- @tparam string|uint event
-- @tparam function handler 
-- @tparam table filters
function Event.set(event, handler, filters)
    if handler == nil then error("Using Event.remove to remove event handler instead of using nil handler.") end 
    if Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME then error("Event.set, not allowed used at runtime stage currently.") end 
    Event.remove(event, nil) 
    if filters then 
        if event == on_init or event == on_load or event == on_configuration_changed then 
            error("Event.set, on_init, on_load, on_configuration_changed events can not apply filters.")
        end 
        script.on_event(event, handler, filters)
    else Event.on(event, handler) end 
end 

--- Remove handler(s) with event name or token.
-- @tparam uint event event name 
-- @tparam uint|nil token a token returned by Event.add, if nil, it will remove all handlers of the event.
-- @treturn function|nil return the handler to be removed, if not found will return nil
function Event.remove(event, token)
    local handler 
    if handlers[event] == nil then return end     
    if token ~= nil then 
        handler = handlers[event][token] 
        if handler == nil then error("Event.remove, handler not found, invalid token.") end
    end 
    if Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME then             
        assert(persisted_handlers[event] ~= nil)
        if token ~= nil then persisted_handlers[event][token] = nil end 
        if token == nil or next(persisted_handlers[event]) == nil then persisted_handlers[event] = nil end 
    end 
    if token ~= nil then handlers[event][token] = nil end 
    if token == nil or next(handlers[event]) == nil then handlers[event] = nil end 
    if handlers[event] == nil then 
        if event == on_init then script.on_init(nil) 
        elseif event == on_load then script.on_load(nil)
        elseif event == on_configuration_changed then script.on_configuration_changed(nil)
        else script.on_event(event, nil) end   
    end 
    return handler
end 

--- Add one handler for the specific nth tick, a capsulation for script.on_nth_tick.
-- It is allowed to add mulitiple handlers for the same event.
-- @tparam  uint tick tick span for trigger the event, Note: game.tick%nth_tick == 0 is the matched condition
-- @tparam  function handler if in Event.LIFECYCLE_RUNTIME, handler MUST have no upvalues excpet _ENV upvalue,
-- otherwise you can any type closures at other stage.
-- @tparam uint token not allowed pass this value manually, only for deserialization purpose
-- @treturn uint return an unit type token which can be used for hanlder removing.
function Event.add_nth_tick(tick, handler, token)   
    if tick == nil then error("Event.add_nth_tick, nil tick not allowed, using Event.remove_nth_tick to remove all handlers.") end 
    if handler == nil then error("Using Event.remove to remove event handler instead of using nil handler.") end 
    if type(handler) ~= "function" then error("Handler should be callable.") end 
    token = token or get_persisted_handler_token()
    token = tostring(token)
    nth_tick_handlers[tick] = nth_tick_handlers[tick] or {}
    if Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME then         
        if not is_valid_serialization_function(handler) then error("Event.add_nth_tick, invalid handler for serialization.") end 
        persisted_nth_tick_handlers[tick] = persisted_nth_tick_handlers[tick] or {}
        -- check handler has matched upvalues(no upvalues or only one _ENV)
        log(serpent.block(persisted_nth_tick_handlers, {comment = true}))
        persisted_nth_tick_handlers[tick][token] = string.dump(handler)
        log(serpent.block(persisted_nth_tick_handlers, {comment = true}))
    end  
    if next(nth_tick_handlers[tick]) == nil then 
        script.on_nth_tick(tick, callHandlersOfSameTicks)
    end 
    nth_tick_handlers[tick][token] = handler
    return token
end 

--- A convenient function same with Event.add_nth_tick.
Event.on_nth_tick = Event.add_nth_tick

--- Remove handler(s) with nth_tick or token.
-- @tparam uint tick nth_tick 
-- @tparam uint|nil token a token returned by Event.add_nth_tick, if nil, it will remove all handlers of the event.
-- @treturn function|nil return the handler to be removed, if not found will return nil
function Event.remove_nth_tick(tick, token)
    local handler 
    if nth_tick_handlers[tick] == nil then return end 
    if token ~= nil then 
        handler = nth_tick_handlers[tick][token] 
        if handler == nil then error("Event.remove_nth_tick, handler not found, invalid token.") end
    end 
    if Event.LIFECYCLE == Event.LIFECYCLE_RUNTIME then 
        -- only can remove handlers registred at runtime stage
        assert(persisted_nth_tick_handlers[tick] ~= nil)
        if token ~= nil then persisted_nth_tick_handlers[tick][token] = nil end 
        if token == nil or next(persisted_nth_tick_handlers[tick]) == nil then persisted_nth_tick_handlers[tick] = nil end 
    end 
    if token ~= nil then nth_tick_handlers[tick][token] = nil end 
    if token == nil or next(nth_tick_handlers[tick]) == nil then nth_tick_handlers[tick] = nil end 
    if nth_tick_handlers[tick] == nil then script.on_nth_tick(tick, nil) end 
    return handler
end

--- Put serialization vars into global.
Event.on_init(function() 
    global.facto = global.facto or {}
    -- @fixme if global.facto.event is not nil
    global.facto.event = serialize    
end)

--- Recover serialization data from global.
Event.on_load(function()
    if not global.facto or not global.facto.event or not global.facto.event.persisted_handlers then 
        error("Event.on_load, Event handlers data broken.")
    end 
    log(serpent.block(global.facto.event, { comment = true }))    
    serialize = global.facto.event
    persisted_handlers = serialize.persisted_handlers
    persisted_nth_tick_handlers = serialize.persisted_nth_tick_handlers
    recover_persisted_handlers(persisted_handlers)
    recover_persisted_nth_tick_handlers(persisted_nth_tick_handlers)
end)

-- @export
return Event