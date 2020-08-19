local Class = require("oop.class")
local Event = require("facto.event")

local CargoWagonExchanger = Class.create()
CargoWagonExchanger.type = "cargo-wagon-exchanger"
-- Property members
--[[
* LuaObject factoobj1 - carriage
* LuaObject factoobj2 - inside chest
* boolean isoutput, if true, factoobj1 plays as output source, false plays as input destinantion
* boolean autoconnect on exchange or not 
* number the distance out of which will close exchanging, nil means no distance limitation
* uint count_each_tick
* uint count_each_cycle balanced mode or no request slot, the number of each cycle for different type items
* boolean connected whether exchanging is on or off
]]--

CargoWagonExchanger.exchange_count_each_tick = 2000
CargoWagonExchanger.request_mutiply_each_type = 4
CargoWagonExchanger.is_output = true
CargoWagonExchanger.autoconnected = true

-- Constructor.
function CargoWagonExchanger:__constructor(props)
    props = props or {}
    for k,v in pairs(props) do self[k] = v end 
    self:initialize()
end 

--- Initialization for carriage.
function CargoWagonExchanger:initialize()
    self.factoobj1 = self.carriage.factoobj
end 

function CargoWagonExchanger:getId()
    if not self.id then 
        self.id = string.format("%s_%s", self.factoobj1.unit_number, self.factoobj2.unit_number) 
        self.reversed_id = string.format("%s_%s", self.factoobj2.unit_number, self.factoobj1.unit_number) 
    end 
    return self.id
end 

function CargoWagonExchanger:build(position, tiles, lazycalls, addedcall)
    local factoobj 
    local name 
    if self.is_output then name = "logistic-chest-requester"
    else name = "logistic-chest-passive-provider" end 
    -- self.factoobj1 = self.carriage.factoobj    
    lazycalls[#lazycalls+1] = function()
        factoobj = self.carriage:getTrainSurface().create_entity({
            name = name,
            position = position,
            force = 'neutral',
            create_build_effect_smoke = false
        })
        factoobj.destructible = false
        factoobj.minable = false
        self.factoobj2 = factoobj
        addedcall()
    end 
end 

function CargoWagonExchanger:getSourceFactoobj()
    if self.is_output then return self.factoobj1
    else return self.factoobj2 end 
end 

function CargoWagonExchanger:getSource()
    if self.is_output then return self.factoobj1.get_inventory(defines.inventory.cargo_wagon)
    else return self.factoobj2.get_inventory(defines.inventory.chest) end 
end 

function CargoWagonExchanger:getDestinationFactoobj()
    if self.is_output then return self.factoobj2
    else return self.factoobj1 end 
end 

function CargoWagonExchanger:getDestination()
    if self.is_output then return self.factoobj2.get_inventory(defines.inventory.chest)
    else return self.factoobj1.get_inventory(defines.inventory.cargo_wagon) end 
end 

function CargoWagonExchanger:isSourceEmpty()
end 

function CargoWagonExchanger:isDestinationFull()
end 

function CargoWagonExchanger:isValid()
end 

function CargoWagonExchanger:canExchange()
    return not (not self:isValid() or not self.connected or self:isSourceEmpty() or self:isDestinationFull())
end 

-- first step fullfill the slots of destination, only happened for inventory
-- second step fuillfill all the stacks, if there are stacks still not full and there are same type of items in the source
-- different types of item balancing exchange ?
-- Get request 
function CargoWagonExchanger:exchange()
    self:exchangeTypeBalanced()  
end 

function CargoWagonExchanger:buildRequestStackBySource()
    local prototypes = game.item_prototypes
    local source = self:getSource()
    local request_stacks = {}
    for name, count in pairs(source.get_contents()) do 
        -- @todo cfg for mutiply of stack size
        request_stacks[name] = prototypes[name].stack_size * self.request_mutiply_each_type
    end 
    -- limit count for each type
    return request_stacks
end 

function CargoWagonExchanger:getRequestStacks(factoobj)
    local requst_stacks = {}
    for i = 1, factoobj.request_slot_count, 1 do
        local stack = factoobj.get_request_slot(i)
        if stack then requst_stacks[stack.name] = stack.count end
    end 
    return requst_stacks
end 

-- ignore filters slots
function CargoWagonExchanger:buildRequestStack()
    local requst_stacks 
    local destination_factoobj = self:getDestinationFactoobj()

    -- support request slot ? if true, check request_from_buffers is true ?    
    -- if does not support request slots, all types will be transfered or source supppert request slots
    -- if factoobj2.request_slot_count <= 0 and re
    -- support request_slots and request_from_buffers is true
    if destination_factoobj.request_slot_count > 0 and destination_factoobj.request_from_buffers then 
        requst_stacks = self:getRequestStacks(destination_factoobj)
        if next(requst_stacks) == nil then 
            requst_stacks = self:buildRequestStackBySource()
        end 
    elseif  destination_factoobj.request_slot_count == 0 then 
        requst_stacks = self:buildRequestStackBySource()
    end 
    return requst_stacks or {}
end 

function CargoWagonExchanger:exchangeTypeByType()
    local requst_stacks = self:buildRequestStack()
    local source = self.factoobj1.get_inventory(defines.inventory.cargo_wagon)
    local destination = self.factoobj2.get_inventory(defines.inventory.chest)

    local cached = {}
    for name, request_count in pairs(requst_stacks) do 
        local destination_count = destination.get_item_count(name)
        local source_count = source.get_item_count(name)
        if request_count > destination_count and source_count > 0 and  cached[name] == nil then 
            local exchange_count = request_count - destination_count
            if exchange_count > source_count then exchange_count = source_count end 
            local inserted_count = destination.insert({ name = name, count = exchange_count })
            if inserted_count > 0 then source.remove({ name = name, count = inserted_count }) end 
            cached[name] = true
        end 
    end 
end 

require("utils")

function CargoWagonExchanger:exchangeTypeBalanced()
    local requst_stacks = self:buildRequestStack()
    local source = self:getSource()
    local destination = self:getDestination()
    local type_count = table_size(requst_stacks)
    if type_count == 0 then return end 
    local cycle_count_each_type = math.floor(self.exchange_count_each_tick / type_count)
    local source_stacks = source.get_contents()
    local destination_stacks = destination.get_contents()

    for name, request_count in pairs(requst_stacks) do 
        destination_stacks[name] = destination_stacks[name] or 0
        source_stacks[name] = source_stacks[name] or 0
        if destination_stacks[name] ~= "full" then 
            local destination_count = destination_stacks[name] 
            local source_count = source_stacks[name]
            if request_count > destination_count and source_count > 0 then             
                local exchange_count = request_count - destination_count            
                if exchange_count > source_count then exchange_count = source_count end 
                if exchange_count > cycle_count_each_type then exchange_count = cycle_count_each_type end 
                local inserted_count = destination.insert({ name = name, count = exchange_count })
                --- full of this type 
                if exchange_count > inserted_count then destination_stacks[name] = "full" 
                else destination_stacks[name] = destination_stacks[name] + inserted_count end                  
                if inserted_count > 0 then 
                    local removed_count = source.remove({ name = name, count = inserted_count }) 
                    source_stacks[name] = source_stacks[name] - removed_count
                end 
            end 
        end 
    end
end 

function CargoWagonExchanger:destroy()
end 

-- @export
return CargoWagonExchanger