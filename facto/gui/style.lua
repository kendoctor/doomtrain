local Class = require("facto.class")
local Style = Class.create()

function Style:__constructor()
    self.rulesets = {}
end 

function Style:apply(gui)    
    for selector, ruleset in pairs(self.rulesets) do 
        -- if self.match(selector, gui) then self.applyRules(ruleset, gui) end 
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
    if gui.name == selector or gui.type == selector then return true end 
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

-- @export
return Style