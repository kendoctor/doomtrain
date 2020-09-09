local Class = require("facto.class")
local Logger = Class.create()
local stdlog = log 
local stderror = error

Logger.LEVEL_DEBUG = 1
Logger.LEVEL_INFO = 2
Logger.LEVEL_NOTICE = 3
Logger.LEVEL_WARNING = 4
Logger.LEVEL_ERROR = 5
Logger.LEVEL_DESC = { "DEBUG", "INFO", "NOTICE", "WARNING", "ERROR" }

local logs  = {}

function Logger:__constructor(min_level, persisted)
    -- self.min_level = min_level
    -- self.persisted = persisted
end 

function Logger.output(log)
    if game then game.print(log[1]) end 
    stdlog(log[1])
end 

function Logger.log(level, message, ...)
    if select('#', ...) > 0 then message = string.format(message, ...) end 
    local log = { string.format("[%s] %s", Logger.LEVEL_DESC[level], message), level, 0 or game and game.tick }
    logs[level] = logs[level] or {}
    table.insert(logs[level], log)    
    Logger.output(log)
    return log
end 

function Logger.debug(message, ...)
    Logger.log(Logger.LEVEL_DEBUG, message, ...)
end

function Logger.info(message, ...)
    Logger.log(Logger.LEVEL_INFO, message, ...)
end 

function Logger.notice(message, ...)
    Logger.log(Logger.LEVEL_NOTICE, message, ...)
end 

function Logger.warning(message, ...)
    Logger.log(Logger.LEVEL_WARNING, message, ...)
end 

function Logger.error(message, ...)
    local log = Logger.log(Logger.LEVEL_ERROR, message, ...)
    stderror(log[1])
end 

function Logger.api()
    return Logger.debug, Logger.info, Logger.notice, Logger.warning, Logger.error
end 

-- @export
return Logger