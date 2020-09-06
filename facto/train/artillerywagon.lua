local Class = require("facto.class")
local Event = require("facto.event")
local Carriage = require("facto.train.carriage")
local exchangerFactory = require("facto.exchanger.exchangerfactory").getInstance()

--- Artillery wagon implementation.
-- @classmod ArtilleryWagon
local ArtilleryWagon = Class.extend({}, Carriage)
-- @property members
-- @property string the type of carriage which is for factory registration.
ArtilleryWagon.type = "artillery-wagon"

-- @export
return ArtilleryWagon