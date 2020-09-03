local Class = require("oop.class")

local StyleBuilder = Class.create()

function StyleBuilder:__constructor(style)
    self.instance = style
end 

--[[
    type
    type    
    type#name.class, type { property:value, ... }
    .class
    :add("button", "color:red;")
]]
function explode(d, p)
    local t, ll, l
    t = {}
    ll = 0
    if (#p == 1) then return {p} end
    while true do
        l = string.find(p, d, ll, true) -- find the next d in the string
        if l ~= nil then table.insert(t, string.sub(p, ll, l - 1)) ll = l + 1 
        else 
            local str = string.sub(p, ll)
            if string.len(str) > 0 then table.insert(t, str) end
            break 
        end
    end
    return t
end

function parse_rules(rules)
    local ruleset = {}
    for match in rules:gmatch "([%w-_]+%s*:%s*[%w-_]+);?" do 
        local token = explode(":", match)
        if #token ~= 2 then error(string.format("parse_rules, invalid rule: %s", match)) end
        ruleset[token[1]] = token[2]
    end 
    return ruleset
end 

function StyleBuilder:add(selector, rules)
    if type(rules) ~= "string" then error("StyleBuilder:add, invalid type of rules.") end 
    self.instance:add(selector, parse_rules(rules))
    return self
end 

function StyleBuilder:getStyle()
    return self.instance
end 

-- @export
return StyleBuilder