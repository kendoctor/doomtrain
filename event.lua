--- Event Class
-- @classmod Event 

local Event = {}
local handlers = {}
local nth_tick_handlers = {}

--- @todo add debug mode
function Event.callHandlersOfSameEvent(event)
    for _, h in pairs(handlers[event.name]) do h(event)  end 
end 

function Event.callHandlersOfSameTicks(event)
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

--- Add one handler for the specific nth tick.
-- can add multiple handlers for the same nth tick
-- @tparam uint tick 
-- @tparam function handler
function Event.add_nth_tick(tick, handler)
    local sub_handlers = nth_tick_handlers[tick]
    
    if handler == nil then error("Using Event.remove to remove event handler instead of using nil handler.") end 
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