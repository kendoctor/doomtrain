local Class = require("oop.class")
local Event = require("facto.event")
local AbstractExchanger = require("facto.exchanger.abstractexchanger")

local FluidWagonExchanger = Class.extend({}, AbstractExchanger)
-- @section property members
-- @property string the type of exchanger for factory registration.
FluidWagonExchanger.type = "fluid-wagon-exchanger"

-- @section metatable members
--- Initialization for exchanger.
function FluidWagonExchanger:initialize()
    self.factoobj1 = self.carriage.factoobj
    if self.autoconnect then self.connected = true end 
end 

--- Build exchanger.
-- @tparam LuaPosition position exchanger position
-- @tparam table tiles a reference table for caching tiles
-- @tparam table lazycalls a reference table for caching closures
-- @tparam closure addedcall
function FluidWagonExchanger:build(position, tiles, lazycalls, addedcall)
    lazycalls[#lazycalls+1] = function()
        local factoobj = self.carriage:getTrainSurface().create_entity({
            name = "storage-tank",
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

--- Equalize fluid between wagon and tank inside.
function FluidWagonExchanger:exchange()
    self:equalize(self.factoobj1, self.factoobj2)
    self:equalize(self.factoobj2, self.factoobj1)
end 

--- Equalize fluid.
-- @todo recode, this code copied from comfy.
function FluidWagonExchanger:equalize(source_tank, target_tank)
    if not source_tank.valid then return end
    if not target_tank.valid then return end
    local source_fluid = source_tank.fluidbox[1]
    if not source_fluid then return end
    local target_fluid = target_tank.fluidbox[1]
    local source_fluid_amount = source_fluid.amount
    local amount
    if target_fluid then
        amount = source_fluid_amount - ((target_fluid.amount + source_fluid_amount) * 0.5)
    else
        amount = source_fluid.amount * 0.5
    end
    if amount <= 0 then return end
    local inserted_amount =
        target_tank.insert_fluid({name = source_fluid.name, amount = amount, temperature = source_fluid.temperature})
    if inserted_amount > 0 then
        source_tank.remove_fluid({name = source_fluid.name, amount = inserted_amount})
    end
end

-- @export
return FluidWagonExchanger