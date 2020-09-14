local Class = require("facto.class")
local Style = Class.create()

local function match_type(selector, gui)
    return gui.type == selector
end 

local function match_name(selector, gui)
    return "#"..gui.name == selector
end 

local function match_class(selector, gui)
    if gui.options.class == nil then return false end
    return "."..gui.options.class == selector
end 

local function match_type_and_name(selector, gui)
    return gui.type.."#"..gui.name == selector
end

local function match_type_and_class(selector, gui)
    if gui.options.class == nil then return false end
    return gui.type.."."..gui.options.class == selector
end

local function match_name_and_class(selector, gui)
    if gui.options.class == nil then return false end
    return "#"..gui.name.."."..gui.options.class == selector
end

local function match_type_and_name_and_class(selector, gui)
    if gui.options.class == nil then return false end
    return gui.type.."#"..gui.name.."."..gui.options.class == selector
end

function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

Style.SelectorPatterns =  {
    { "^[%w_-]+$", match_type },
    { "^#[%w_-]+$", match_name },
    { "^%.[%w_-]+$", match_class },
    { "^[%w_-]+#[%w_-]+$", match_type_and_name },
    { "^[%w_-]+%.[%w_-]+$", match_type_and_class },
    { "^#[%w_-]+%.[%w_-]+$", match_name_and_class },
    { "^[%w_-]+#[%w_-]+%.[%w_-]+$", match_type_and_name_and_class }
}

function Style:__constructor()
    self.rulesets = {}
end 

function  Style.getPrecedence(selector)
    for precedence, pattern in pairs(Style.SelectorPatterns) do
        if string.match(selector, pattern[1]) then 
           return precedence
        end 
    end 
    return nil
end

function Style.getMatcher(selector)
    for precedence, pattern in pairs(Style.SelectorPatterns) do
        if string.match(selector, pattern[1]) then 
           return pattern[2]
        end 
    end 
    return nil
end

function Style:apply(gui)    
    for selector, ruleset in spairs(self.rulesets, function(t,a,b) return Style.getPrecedence(a) < Style.getPrecedence(b) end) do 
        self:applyRuleSet(selector, ruleset, gui)
    end 
end 

function Style:applyRuleSet(selector, ruleset, gui)
    if self.match(selector, gui) then self.applyRules(ruleset, gui) end 
    -- if gui is container
    if gui.children then             
        for name, subgui in pairs(gui.children) do 
            self:applyRuleSet(selector, ruleset, subgui)
        end 
    end 
end 

function Style.match(selector, gui)
    for precedence, pattern in pairs(Style.SelectorPatterns) do   
        if string.match(selector, pattern[1]) ~= nil then 
           return pattern[2](selector, gui)
        end 
    end 
    return false
end 

function Style.applyRules(ruleset, gui)
    -- margin-left, margin-top will be converted to margin
    for prop, value in pairs(ruleset) do 
        gui:applyRule(prop, value)
    end 
end 

function Style:add(selector, ruleset)
    self.rulesets[selector] = ruleset
end 

function Style:fix(name)
    for selector, ruleset in pairs(self.rulesets) do 
        if selector == "@self" then 
            self.rulesets[selector] = nil 
            self.rulesets["#"..name] =  ruleset
            break
        end
    end 
end 

function Style:merge(style)
    for selector, ruleset in pairs(style.rulesets) do 
        if self.rulesets[selector] == nil then self.rulesets[selector] = ruleset end 
    end 
    return self
end

-- @export
return Style