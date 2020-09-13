local Class = require("facto.class")
local Style = require("facto.gui.style")

local StyleBuilder = Class.create()

function StyleBuilder:__constructor()
    self.instance = Style()
end 

--[[
    type
    type    
    type#name.class, type { property:value, ... }
    .class
    :add("button", "color:red;")
]]

function parse_rules(rules)
    local ruleset = {}
    for key, value in rules:gmatch "([%w-_]+)%s*:%s*([%w-_]+)%s*;?" do 
        ruleset[key] = value
    end 
    if next(ruleset) == nil then return nil end
    return ruleset
end 

function parse_selectors(selectors)
    local retval = {}
    for selector in selectors:gmatch "%s*([^,%s]+)%s*,?" do 
       table.insert(retval, selector)
    end 
    if next(retval) == nil then return nil end
    return retval
end 

function StyleBuilder:add(selectors, rules)
    if type(rules) ~= "string" then error("StyleBuilder:add, invalid type of rules.") end 
    rules = parse_rules(rules)
    selectors =  parse_selectors(selectors)
    -- @todo validation
    if selectors == nil or rules == nil then return self end 
    for k, selector in pairs(selectors) do
        self.instance:add(selector, rules)
    end 
    return self
end 

function StyleBuilder:getStyle()
    return self.instance
end 

-- @export
return StyleBuilder