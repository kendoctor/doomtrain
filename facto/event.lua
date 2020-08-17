--- Event Class
-- If consider priority handlers, needs an array table to hold handlers, otherwise needs sorting before call
-- do we need coroutine to guarrantee on_loaded event which will be registered and triggered first ?
-- @classmod Event 

local Event = {}
local handlers = {} 
local nth_tick_handlers =  {}
local loaded_handlers = {}
local loaded_event_triggered = false 
local blank_call = function(e) 
    -- nothing to do, only trigger event == defines.events.on_tick
end 

function Event.on_load(handler)
    script.on_load(handler)
end 

function Event.on_init(handler)
    script.on_init(handler)
end 

--- @todo add debug mode
function Event.callHandlersOfSameEvent(event)
    -- @todo if loaded_handers not empty, trigger on_loaded first, except on_init, on_load...
    if event.name == defines.events.on_tick and not loaded_event_triggered then Event.callHanldersOfLoadedEvent(event) end 
    for _, h in pairs(handlers[event.name]) do h(event)  end 
end 

--- This will be called before handlers which were registered via Event.on(defines.events.on_tick,..)
-- loaded handlers will be only called once, when finished, will be removed at once
function Event.callHanldersOfLoadedEvent(event)
    for k, h in pairs(loaded_handlers) do 
        h(event)  
        loaded_handlers[k] = nil
    end 
    loaded_event_triggered = true
    Event.remove(defines.events.on_tick, blank_call)
end 

--- Call Event.on_nth_tick(...) registered handlers
function Event.callHandlersOfSameTicks(event)
    -- @todo if loaded_handers not empty, trigger on_loaded first
    -- if event.nth_tick == 1 and not loaded_event_triggered then Event.callHanldersOfLoadedEvent(event) end 
    for _, h in pairs(nth_tick_handlers[event.nth_tick]) do h(event)  end 
end 

--- Add one handler to handle one event.
-- can add mulitiple handlers with same event
-- @todo priority feature with same event ?
-- if the event name does not exist, then create a key
-- handlers[event] = { handler, handler ..}
-- @tparam string|uint event
-- @tparam function handler 
function Event.add(event, handler)
    local sub_handlers = handlers[event]

    -- if want to remove handler, should use Event.remove
    if handler == nil then error("Using Event.remove to remove event handler instead of using nil handler.") end 
    if type(handler) ~= "function" then error("Handler should be callable.") end 

    if sub_handlers then 
        sub_handlers[handler] = handler
    else
        handlers[event] = { handler = handler }                
        script.on_event(event, Event.callHandlersOfSameEvent)
    end 
end 

--- Same with Event.add for convenient call.
-- @tparam string|uint event
-- @tparam function handler 
function Event.on(event, handler)
    return Event.add(event, handler)
end 

--- Set handler for one event.
-- This will remove other handlers of this event previously added
-- Filters can be applied, but only for one handler of each event 
-- @tparam string|uint event
-- @tparam function handler 
-- @tparam table filters
function Event.set(event, handler, filters)
    -- local  hf = { handler , filters }
    if handler == nil then error("Using Event.remove to remove event handler instead of using nil handler.") end 

    Event.remove(event, nil) 
    if filters then 
        script.on_event(event, handler, filters)
    else
        Event.on(event, handler) 
    end 
end 

--- Remove handler(s) with event name or id.
-- if handler is nil, will remove all handlers of this event
-- @todo refactor or refine, offical script.on_event can pass array of events
-- @tparam unit|string event
-- @tparam function|nil handler
function Event.remove(event, handler)
    local sub_handlers = handlers[event]
    -- if handler == nil, then clear all handlers of this event

    if sub_handlers then 
        if handler == nil then 
            handlers[event] = nil
        else 
            sub_handlers[handler] = nil
            -- if sub_handlers[handler] then sub_handlers[handler] = nil end 
            -- sub_handlers is not reference of handlers[event]
            -- if sub_handlers is empty then remove this event listening
            if next(sub_handlers) == nil then handlers[event] = nil end 
        end 
    end 

    if handlers[event] == nil then script.on_event(event, nil) end 
end 


--- Register handlers for initialization when game started(new game or load a save).
-- These handlers will be called once, then removed
-- Note: Registered handlers can not be removed manually.
-- @todo Queued in high priority
-- @fixme how to guarrantee handlers will be called before any other defines.events triggered?
function Event.on_loaded(handler)
    if loaded_event_triggered then error("Loaded event already triggered. Not allowed to register on_loaded event in another event handler.") end 
    if handler == nil then error("Handler should not be nil.") end 
    if type(handler) ~= "function" then error("Handler should be callable.") end 

    if next(loaded_handlers) == nil then Event.add(defines.events.on_tick, blank_call) end 
    loaded_handlers[handler] = handler
end 

--- Add one handler for the specific nth tick.
-- can add multiple handlers for the same nth tick
-- @tparam uint tick 
-- @tparam function handler
function Event.add_nth_tick(tick, handler)
    local sub_handlers = nth_tick_handlers[tick]
    
    if handler == nil then error("Using Event.remove to remove event handler instead of using nil handler.") end 
    if type(handler) ~= "function" then error("Handler should be callable.") end 

    if sub_handlers then 
        sub_handlers[handler] = handler
    else
        nth_tick_handlers[tick] = { handler = handler }                
        script.on_nth_tick(tick, Event.callHandlersOfSameTicks)
    end 
end 

--- Same with Event.add_nth_tick for convenient call.
-- if want to remove handler of the specific nth tick, using Event.remove_nth_tick
-- @tparam uint tick 
-- @tparam function handler
function Event.on_nth_tick(tick, handler)
    Event.add_nth_tick(tick, handler)
end 

--- Remove handler or handlers for the nth tick.
-- if handler is nil, will remove all handlers of nth tick, otherwise only remove this handler
-- @tparam uint tick 
-- @tparam function handler|nil
function Event.remove_nth_tick(tick, handler)
    local sub_handlers = nth_tick_handlers[tick]
    -- if handler == nil, then clear all handlers of this event

    if sub_handlers then 
        if handler == nil then 
            nth_tick_handlers[tick] = nil
        else 
            sub_handlers[handler] = nil 
            -- sub_handlers is not reference of handlers[event]
            if next(sub_handlers) == nil then nth_tick_handlers[tick] = nil end 
        end 
    end 
    
    if nth_tick_handlers[tick] == nil then script.on_nth_tick(tick, nil) end 
end

-- @export
return Event