local Class = require("facto.class")
local Event = require("facto.event")
local AbstractExchanger = require("facto.exchanger.abstractexchanger")

local CargoWagonExchanger = Class.extend({}, AbstractExchanger)
-- @section property members
-- @property string The type of this concrete exchanger which will be used for registration in exchanger factory.
CargoWagonExchanger.type = "cargo-wagon-exchanger"
-- @property boolean if true, the first container will act as source.
CargoWagonExchanger.is_output = true
-- @property uint the count limit will be exchanged in one turn for each type.
CargoWagonExchanger.exchange_count_each_type = 50*8
-- @property uint only applied when has no configured requests.
CargoWagonExchanger.request_stack_size_multiply = 8

-- @section metatable members
--- Initialization for exchanger.
function CargoWagonExchanger:initialize()
    self.factoobj1 = self.carriage.factoobj
    if self.autoconnect then self.connected = true end 
end 

--- Build exchanger.
-- @tparam LuaPosition position exchanger position
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
-- @tparam closure addedcall
function CargoWagonExchanger:build(position, tiles, lazycalls, addedcall)
    local name 
    if self.is_output then name = "logistic-chest-requester"
    else name = "logistic-chest-passive-provider" end 
    lazycalls[#lazycalls+1] = function()
        local factoobj = self.carriage:getTrainSurface().create_entity({
            name = name, position = position, force = 'neutral', create_build_effect_smoke = false
        })
        factoobj.destructible = false
        factoobj.minable = false
        self.factoobj2 = factoobj
        addedcall()
    end 
end 

--- Get the source facto object, since source or destination roles could be swapped.
-- @treturn factoobject
function CargoWagonExchanger:getSourceFactoobj()
    if self.is_output then return self.factoobj1
    else return self.factoobj2 end 
end 

--- Get the source, such as inventory of wagon or fluidbox of a tank.
-- @treturn factoobject
function CargoWagonExchanger:getSource()
    if self.is_output then return self.factoobj1.get_inventory(defines.inventory.cargo_wagon)
    else return self.factoobj2.get_inventory(defines.inventory.chest) end 
end 

--- Get the destination facto object, since source or destination roles could be swapped.
-- @treturn factoobject
function CargoWagonExchanger:getDestinationFactoobj()
    if self.is_output then return self.factoobj2
    else return self.factoobj1 end 
end 

--- Get the destination, such as inventory of wagon or fluidbox of a tank.
-- @treturn factoobject
function CargoWagonExchanger:getDestination()
    if self.is_output then return self.factoobj2.get_inventory(defines.inventory.chest)
    else return self.factoobj1.get_inventory(defines.inventory.cargo_wagon) end 
end 

--- Check whether facto object is valid for access.
-- @treturn boolean
function CargoWagonExchanger:isValid()
    if not self.factoobj1 or not self.factoobj1.valid or not self.factoobj2 or not self.factoobj2.valid then return false end 
    return true
end 

function CargoWagonExchanger:canExchange()
    return not (not self:isValid() or not self.connected or self:isSourceEmpty() or self:isDestinationFull())
end 

--- Exchange items between wagon inventory and chests inside.
function CargoWagonExchanger:exchange()
    if not self:isValid() or not self.connected then return end
    self:exchangeTypeBalanced()  
end 

--- Build request stacks by source.
-- If destination has no requests, and request buffer chest is checked.
-- @treturn table
function CargoWagonExchanger:buildRequestStackBySource()
    local prototypes = game.item_prototypes
    local source = self:getSource()
    local request_stacks = {}
    for name, count in pairs(source.get_contents()) do 
        local default_request_count = prototypes[name].stack_size * self.request_stack_size_multiply 
        if count < default_request_count then default_request_count = count end      
        request_stacks[name] = default_request_count
    end 
    return request_stacks
end 

--- Get request stacks from request slots if there has one.
-- @treturn table
function CargoWagonExchanger:getRequestStacks(factoobj)
    local requst_stacks = {}
    for i = 1, factoobj.request_slot_count, 1 do
        local stack = factoobj.get_request_slot(i)
        if stack then requst_stacks[stack.name] = stack.count end
    end 
    return requst_stacks
end 

--- Build request stacks.
-- 1. If destination has requests, using request slots
-- 2. If destination has no requests but request buffers is checked, build request stacks by source
-- 3. If does not support request slots, build request stacks by source
-- @treturn table
function CargoWagonExchanger:buildRequestStack()
    local requst_stacks 
    local destination_factoobj = self:getDestinationFactoobj()

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

--- Exchange items with different types balanced.
-- In one turn, each type of items will be transfered to destination, but a little bit more time consuming.
function CargoWagonExchanger:exchangeTypeBalanced()
    local requst_stacks = self:buildRequestStack()
    local source = self:getSource()
    local destination = self:getDestination()
    local type_count = table_size(requst_stacks)
    if type_count == 0 then return end 
    local cycle_count_each_type = math.floor(self.exchange_count_each_type / type_count)
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

--- Exchange items type by type.
-- @fixme codes not ready to excute.
-- This may cause only type of items to be transfered to destination in one turn.
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

-- @export
return CargoWagonExchanger