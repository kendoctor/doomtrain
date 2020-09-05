local Class = require("oop.class")
local AbstractType = require("facto.gui.abstracttype")
local ProgressBar = Class.extend({}, AbstractType)
ProgressBar.type = "progressbar"

function ProgressBar:getProps(props)
    props.type = "progressbar"
    props.value = self.data or 0
    return props
end 


-- @export
return ProgressBar