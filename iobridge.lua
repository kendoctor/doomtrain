local DataDumper = require("dumper")

local Global = {}
global.data = {}


local IOBridges = {
    objects = {}
}

local loaded = false

function Global.register(data, callback)
    global.data[data.uid] = data.value

    script.on_load(
        function() 
            log(DataDumper(global.data, nil))
            callback(global.data[data.uid]) 
        end 
    )
end 

Global.register(
    {
        uid = "io_bridges",
        value = IOBridges
    },
    function(tbl)
        IOBridges.objects = tbl.objects 
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
    setmetatable(o, self)      
    self.__index = self
    return o
end 

--- Initialize bridge, check if the entities have inventories
function IOBridge:init()

    --@fixme if input or output entity not valid or nil, how to deal with
    if not self.input_entity  or not self.output_entity then error("Invalid input entity or output entity.") end 

    self.i_inv = self.input_entity.get_inventory(defines.inventory.chest)
    self.o_inv = self.output_entity.get_inventory(defines.inventory.chest)
    return self
end 

function IOBridge:connect()
end 

function IOBridge:disconnect()
end 

--- Exchange items from output entity to input entity.
-- For example : cargo_wagon and chest in cargo_wagon
function IOBridge:exchange()

    if self:isOutputEmpty() then return end 
    local fs = self:getInputFreeSlots()
    if fs <= 0 then return end 

    game.print("120-2----"..math.random()..self.input_entity.name..":"..self.output_entity.name)

    local o_inv = self.o_inv
    local i_inv = self.i_inv 
    local spe = self.stacks_each_exchange

    for i = 1, self:getOutputSlots(), 1 do
        if fs <= 0 or spe <= 0 then return end
        if o_inv[i].valid_for_read then
            i_inv.insert(o_inv[i])
            o_inv[i].clear()
            fs = fs - 1
            spe = spe - 1
        end
    end
end 

function IOBridge:getFreeSlots(inventory)
    local fs = 0
    if inventory.supports_bar() then 
        fs = inventory.count_empty_stacks()
    else
        for i = 1, inventory.get_bar() - 1, 1 do
            if not inventory[i].valid_for_read then fs = fs + 1 end
        end
    end 
    return fs
end 

function IOBridge:getInputFreeSlots()
   return self:getFreeSlots(self.i_inv)
end 

function IOBridge:getOutputSlots()
    return #self.o_inv
end 

function IOBridge:getOutputFreeSlots()
    return self:getFreeSlots(self.o_inv)
end 

function  IOBridge:isOutputEmpty()
    return self.o_inv.is_empty()
end 

function IOBridge:isInputFull()
end 

function IOBridge:getInputInventory()
    -- return self.input_entity.get
end 

function IOBridge:getOutputInventory()
end 

function IOBridges.createIOBridge(input_entity,ouput_entity)
    local objects = IOBridges.objects
    local io_bridge = IOBridge:new({
        input_entity = input_entity,
        output_entity = ouput_entity
    })
    io_bridge:init()
    objects[#objects+1] = io_bridge
end 

function IOBridges.init()
    if not loaded then 
        loaded = true 
        for k, io_bridge in pairs(IOBridges.objects) do
            IOBridges.objects[k] = IOBridge:new(io_bridge):init()
        end 
    end 
end 

function IOBridges.on_exchange(e)
    IOBridges.init()
    for k, io_bridge in pairs(IOBridges.objects) do
        io_bridge:exchange()
    end 
end 

return IOBridges, IOBridge