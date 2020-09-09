local Class = require("facto.class")

local Player = Class.create()
Player.type = "player"

function Player:__constructor(factoobj)
    self.id = tostring(factoobj.index)
    self.factoobj = factoobj
    self.joinedTimes = 0
    self.kickedTimes = 0
    self:initialize()
end 

function Player:initialize()
end 

function Player:getId()
    return self.id
end 

function Player:isValid()
    return self.factoobj and self.factoobj.valid 
end 

function Player:isOnline()
    return self:isValid() and self.factoobj.connected
end 

function Player:hasCharacter()
    return self.isOnline() and self.factoobj.character ~= nil
end 

function Player:incJoinedTimes()
    self.joinedTimes = self.joinedTimes + 1
end 

function Player:isMoving()
    return self.factoobj.walking_state.walking
end 

function Player:isAdmin()
    return self.factoobj.admin
end 

function Player:clearConsle()
    self.factoobj.clear_console()
end 

-- @export
return Player