local Class = require("oop.class")
local Event = require("facto.event")

--- Abstract class for exchanger.
-- Abstract definition: An exchanger acts like a bridge which help two containers exchange their items or fluid with each other.
-- When one container acts as output source, then the other will act as input destination, vice versa.
-- Note: Amount in fluid containers could be equalized which means there are no real source and destination exist.
-- But it could be implemented in this pattern.
local AbstractExchanger = Class.create()

-- @section property members
---@property string type of the exchanger, its only for concrete exchanger, this value should be overwritten.
AbstractExchanger.type = "type_in_concrete_derived_class"
-- @property string a unique key in all exchangers.
AbstractExchanger.id = nil
-- @property string two containers has no order, id and reversed_id will verify the same exchanger already created.
AbstractExchanger.reversed_id = nil
-- @property object the first container.
AbstractExchanger.factoobj1 = nil
-- @property object the second contaienr.
AbstractExchanger.factoobj2 = nil
-- @property boolean status whether the exchanger is on or off.
AbstractExchanger.connected = false 
-- @property boolean if true, when the exchanger created, it will be auto connected.
AbstractExchanger.autoconnect = true 

-- @section metatable members
--- Constructor.
function AbstractExchanger:__constructor(props)
    props = props or {}
    for k,v in pairs(props) do self[k] = v end 
    self:initialize()
end 

--- Initialization for exchanger.
function AbstractExchanger:initialize()
end 

--- Get id of the exchanger.
-- @treturn unit
function AbstractExchanger:getId()
    if not self.id then 
        self.id = string.format("%s_%s", self.factoobj1.unit_number, self.factoobj2.unit_number) 
        self.reversed_id = string.format("%s_%s", self.factoobj2.unit_number, self.factoobj1.unit_number) 
    end 
    return self.id
end 

--- Get the source facto object, since source or destination roles could be swapped.
-- @treturn factoobject
function AbstractExchanger:getSourceFactoobj()
    error("AbstractExchanger:getSourceFactoobj should be overriden.")
end 

--- Get the source, such as inventory of wagon or fluidbox of a tank.
-- @treturn factoobject
function AbstractExchanger:getSource()
    error("AbstractExchanger:getSource should be overriden.")
end 

--- Get the destination facto object, since source or destination roles could be swapped.
-- @treturn factoobject
function AbstractExchanger:getDestinationFactoobj()
    error("AbstractExchanger:getDestinationFactoobj should be overriden.")
end 

--- Get the destination, such as inventory of wagon or fluidbox of a tank.
-- @treturn factoobject
function AbstractExchanger:getDestination()
    error("AbstractExchanger:getDestination should be overriden.")
end

--- Exchange stuffs between two containers, such as items or fluid.
-- This method will be invoked by ExchangerFactory in ticks.
function AbstractExchanger:exchange()
    error("AbstractExchanger:exchange should be overriden.")
end 

--- Swap source and destination roles of two containers.
-- @treturn boolean
function AbstractExchanger:swap()
    error("AbstractExchanger:swap should be overriden.")    
end 

--- Turn exchange on if it is off.
function AbstractExchanger:connect()
    self.connected = true
end 

--- Turn exchange off if it is on.
function AbstractExchanger:disconnect()
    self.connected = false 
end 

--- Clear the data of exchanger which allocated.
function AbstractExchanger:destroy()
end 

-- @export
return AbstractExchanger