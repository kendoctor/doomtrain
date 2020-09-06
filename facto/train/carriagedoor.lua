local Class = require("facto.class")

-- @classmod CarriageDoor
local CarriageDoor = Class.create()

-- function CarriageDoor:__constructor(props)
--     props = props or {}
--     props.doors = props.doors or {}
--     for k,v in pairs(props) do self[k] = v end 
-- end 

-- function CarriageDoor:initialize()
-- end 

function CarriageDoor:build(position, tiles, lazycalls, addedcall)
    local door 
    local main_tile_name = 'black-refined-concrete'
   
    tiles[#tiles+1] =  { name = main_tile_name, position = { position.x, position.y - 1 } }
    tiles[#tiles+1] =  { name = main_tile_name, position = { position.x, position.y } }    
    lazycalls[#lazycalls+1] = function()
        door =
            self.carriage:getTrainSurface().create_entity(
            {
                name = 'player-port',
                position = position,
                force = 'neutral',
                create_build_effect_smoke = false
            }
        )
        door.destructible = false
        door.minable = false
        door.operable = false    
        self.factoobj = door
        addedcall()
    end 
end 

function CarriageDoor:load()
end 

function CarriageDoor:getId()
    return self.factoobj.unit_number
end 

function CarriageDoor:destroy()
    
end 

-- function CarriageDoor:__tostring()
--     return string.format(
--         "Door> unit_number: %s",
--         self:getUnitNumber()
--     )
-- end 

-- @export
return CarriageDoor