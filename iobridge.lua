local Global = require("global")
local Event = require("event")

--- IOBridges module
-- @mod IOBridges
local IOBridges = {
    objects = {}
}
local loaded = false

Global.register(
    {
        uid = "io_bridges",
        value = IOBridges.objects
    },
    function(tbl)
        IOBridges.objects = tbl
        -- setmetatable(tbl, { __index = IOBridges })
    end 
)

--[[
 input entity unit_number
 output entity unit_number
 connected or disconnected
 bridge_radius 0|20
 is_support_different_surface

]]--
--- IOBridge Class.
-- @classmod IOBridge
-- This class help two entities which has inventory build a bridge to exchange resources, items
-- One acts as output source, one acts as input reciever
local IOBridge = {}

--- Create a new io bridge.
-- @treturn Door
function IOBridge:new(o)
    o = o or {}
    o.stacks_each_exchange = o.stacks_each_exchange or 5
    if o.auto_connect == nil then o.auto_connect = true end
    o.connected = false

    setmetatable(o, self)      
    self.__index = self
    return o
end 

--- Initialize bridge, check if the entities have inventories
-- @todo lazy load ? if entity passed as callback function
-- @treturn bool
function IOBridge:init()        
    if not self:isValid() then return false end 
    -- -- validation for entity
    -- if not self.input_entity  or not self.input_entity.valid then error("Invalid input entity.") end 
    -- if not self.output_entity  or not self.output_entity.valid then error("Invalid output entity.") end 

    -- check if the entity has expected inventory
    IOBridges.getInventory(self.input_entity)
    IOBridges.getInventory(self.output_entity)

    -- if auto_connect is true, then after automatically begin to exchange 
    if self.auto_connect then self:connect() end 

    return true
end 

--- Begin to exchange
function IOBridge:connect()
    self.connected = true
end 

--- Close exchange
function IOBridge:disconnect()
    self.connected = false 
end 

--- Exchange items from output entity to input entity.
-- For example : cargo_wagon and chest in cargo_wagon
function IOBridge:exchange()
    
    if not self:isValid() or not self.connected or self:isOutputEmpty() then return end
   
    local fs = self:getInputFreeSlots()
    -- each exchange, only will transfer N stacks 
    local spe = self.stacks_each_exchange
    -- if input source has no free slots, return at once. 
    -- a perfect way is check whether some stacks still not full, can be inserted more sutffs of the same type
    if fs <= 0 or spe <= 0 then return end 
    local o_inv = self:getOutputInventory()
    local i_inv = self:getInputInventory()
    
    local input_valid_filter_stacks = self:getInputValidRequestStacks()
    -- if stacks not empty
   
    for i = 1, self:getOutputSlots(), 1 do
        local output_stack = o_inv[i]     
        if output_stack.valid_for_read then 
            local count = output_stack.count 
            if next(input_valid_filter_stacks) ~= nil then 
                -- do we consider evenly input items of different type at the same timne ?
                -- if want to precisely output items into input 
                local input_valid_filter_stack = input_valid_filter_stacks[output_stack.name]
                local input_left_count = 0
                if input_valid_filter_stack then 
                    input_left_count = input_valid_filter_stack.count - i_inv.get_item_count(output_stack.name)
                    if input_left_count > 0 then            
                        if input_left_count < count then count = input_left_count end 
                        local insert_count = i_inv.insert({name = output_stack.name, count = count })
                        output_stack.count = output_stack.count - insert_count
                        -- @fixme if insert count does not fullfill the stack, the free slots will not change
                        fs = fs - 1
                        spe = spe - 1
                    end
                end 
            elseif not self:isSupportInputRequestSlots() then 
                local insert_count = i_inv.insert({name = output_stack.name, count = count })
                output_stack.count = output_stack.count - insert_count
                fs = fs - 1
                spe = spe - 1
            end 
        end 
        if fs <= 0 or spe <=0 then return end    
    end
end 

--- Check whether input entity supports request slots
-- @treturn bool 
function IOBridge:isSupportInputRequestSlots()
    return self.input_entity.request_slot_count > 0
end 

--- Safely get input entity.
-- @treturn LuaEntity
function IOBridge:getInputEntity()
    if not self.input_entity or not self.input_entity.valid then error("Invalid input entity.") end 
    return self.input_entity
end 

--- Safely get output entity.
-- @treturn LuaEntity
function IOBridge:getOutputEntity()
    if not self.output_entity or not self.output_entity.valid then error("Invalid output entity.") end 
    return self.output_entity
end 


function IOBridge:getOutputInventory()
    return IOBridges.getInventory(self:getOutputEntity())
end 


function IOBridge:getInputInventory()
    return IOBridges.getInventory(self:getInputEntity())
end 


--- Get input entity valid request stacks which hold request info.
-- @treturn table 
function IOBridge:getInputValidRequestStacks()
    local input_valid_filter_stacks = {}
    for i = 1, self:getInputRequestSlots(), 1 do
        local stack = self:getInputEntity().get_request_slot(i)
        if stack then
            input_valid_filter_stacks[stack.name] = stack
        end
    end 
    return input_valid_filter_stacks
end 

--- Get reqeust slot count 
-- @treturn uint
function IOBridge:getInputRequestSlots()
    return self:getInputEntity().request_slot_count
end 


--- Get free slots of input inventory
-- @treturn uint
function IOBridge:getInputFreeSlots()
   return IOBridges.getFreeSlots(self:getInputInventory())
end 

--- Get slots of output inventory.
-- @tparam bool bar_included if the inventory supports bar, whether bar are included as free slots
-- @treturn uint
function IOBridge:getOutputSlots(bar_included)
    local output_inventory = self:getOutputInventory()
    local c = 0
    if output_inventory.supports_bar() and not bar_included then 
        c = output_inventory.get_bar() - 1 
    else 
        c = #output_inventory
    end  
    return c
end 

--- Check whether output inventory is empty.
-- @treturn bool
function IOBridge:isOutputEmpty()
    return self:getOutputInventory().is_empty()
end 

--- Check whether input inventory is full in every stack.
-- @todo not applied now
-- @treturn bool
function IOBridge:isInputFull()
    return false
end 

--- Check whether bridge is valid due to invalid input or output entity
-- @treturn bool
function IOBridge:isValid()
    if not self.input_entity or not self.input_entity.valid or not self.output_entity or not self.output_entity.valid then return false end 
    return true 
end 

--- Initialize io bridges
function IOBridges.init()
    if not loaded then 
        loaded = true 
        for k, io_bridge in pairs(IOBridges.objects) do
            local new_bridge = IOBridge:new(io_bridge)
            if new_bridge:init() then 
                IOBridges.objects[k] = new_bridge
            else
                IOBridges.objects[k] = nil
            end 
        end 
    end 
end 

--- Create io bridge for exchange items with each other
-- @tparam LuaEntity input_entity
-- @tparam LuaEntity output_entity
-- @treturn IOBridge
function IOBridges.createIOBridge(input_entity,ouput_entity)
    local objects = IOBridges.objects
    local io_bridge = IOBridge:new({
        input_entity = input_entity,
        output_entity = ouput_entity
    })
    io_bridge:init()
    objects[#objects+1] = io_bridge
    return io_bridge
end 

--- Remove bridge by entity(input or output)
function IOBridges.removeIOBridgesByEntity(entity)    
    for k, b in pairs(IOBridges.objects) do 
        if entity == b.input_entity or entity == b.output_entity then 
            IOBridges.objects[k] = nil
            -- @todo b.destory() clear bridgee extra data?
        end 
    end 
end 

function IOBridges.findIOBridgesByEntity(entity)
    -- local to_remove = {}
    -- for k, b in pairs(IOBridges.objects) do 
    --     if entity == b.input_entity or entity == b.output_entity then 
    --         to_remove[#to_remove+1] = b
    --     end 
    -- end 
end 

--- Get inventory of one entity if it supports, otherwise will throw exception
-- @tparam LuaEntity inventory_entity 
function IOBridges.getInventory(inventory_entity)
    local name = inventory_entity.name 
    local mapping_table = {}
    local chests = {  
        "iron-chest",
        "steel-chest" , 
        "wooden-chest", 
        "logistic-chest-active-provider" , 
        "logistic-chest-buffer",
        "logistic-chest-passive-provider",
        "logistic-chest-requester",
        "logistic-chest-storage"
     }
    local wagons = {"cargo-wagon" }

    mapping_table[chests] = defines.inventory.chest
    mapping_table[wagons] = defines.inventory.cargo_wagon

    for t, d in pairs(mapping_table) do 
        for _, v in pairs(t) do 
            if name == v then 
                return inventory_entity.get_inventory(d)
            end 
        end 
    end 

    error(string.format("Unsupported for enitity:%s", name))
end 


--- Get free slots of inventory
-- @tparam LuaInventory inventory
-- @tparam bool bar_included if the inventory supports bar, whether bar are included as free slots
-- @treturn uint
function IOBridges.getFreeSlots(inventory, bar_included)
    local fs = 0
    if not inventory.supports_bar() or bar_included then 
        fs = inventory.count_empty_stacks()
    else
        for i = 1, inventory.get_bar() - 1, 1 do
            if not inventory[i].valid_for_read then fs = fs + 1 end
        end
    end 
    return fs
end 

--- Exchange when game tick reached
-- @tparam LuaEvent e
function IOBridges.on_exchange(e)
    IOBridges.init()
    for k, io_bridge in pairs(IOBridges.objects) do
        io_bridge:exchange()
    end 
end 


function IOBridges.on_removed(e)
    IOBridges.init()
    IOBridges.removeIOBridgesByEntity(e.entity)
end



--- should remove bridges when one entity die or destoryed or mined
Event.on(defines.events.on_player_mined_entity, IOBridges.on_removed)
Event.on(defines.events.on_entity_died, IOBridges.on_removed)

-- @export
return IOBridges, IOBridge