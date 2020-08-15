local Class = require("oop.Class")


local Map = Class.create()

function Map:__init(tbl)    
    if type(tbl) ~= "table" then error("tbl should be table type.") end 
    for k,v in pairs(tbl) do         
        self[k] = v
    end 
end 

--- Add a new item into map with a key.
-- If you do not want to get old item, just use map[key] = item
-- @treturn return the old item, the key exists, otherwise return nil
function Map:add(key, item)
    local old_item = self[key]
    self[key] = item
    return old_item 
end 

--- Get count of items in the map.
-- @treturn uint
function Map:count()
    -- table_size only exists in facto api
    local table_size = table_size or function() 
        local c = 0
        for _,v in pairs(self) do
            c = c + 1
        end 
        return c
    end 
    return table_size(self)
end 

--- Check whether the item exists in the map
-- @tparam any item
-- @treturn boolean
function Map:contains(item)
    return self:indexOf(item) ~= nil
end 

--- Check whether the map has the key
-- @tparam any key
-- @treturn boolean
function Map:containsKey(key)
    for k,v in pairs(self) do 
        if k == key then return true end 
    end 
    return false
end 

--- Get the first matched key if key's assocated item equals to passed in 
-- @treturn nil or non-nil value
function Map:indexOf(item)
    for k,v in pairs(self) do
        if v == item then return k end 
    end 
    return nil 
end 

--- Remove item by key
-- @param key
-- @treturn if successfully removed, return removed item
function Map:remove(key)
    if key == nil then return nil end
    local remove_item = self[key]
    self[key] = nil
    return remove_item or nil
end 

--- Remove first matched item
-- @treturn nil|any the key assocated with the removed item
function Map:removeItem(item)
    local key = self:indexOf(item)
   self:remove(key)
   return key
end 

--- Check whether the map is empty
-- @treturn boolean
function Map:isEmpty()
    return self:count() == 0
end 

--- Clear all items in the map
function Map:clear()
    for k,v in pairs(self) do 
        self[k] = nil
    end 
end 

-- @export
return Map