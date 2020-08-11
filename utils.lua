-- debug function 
local n_uid = 0

function debug(message)
    game.print(string.format('UID#%s --> %s', n_uid, message))
    n_uid = n_uid + 1
end

function explode(d, p)
    local t, ll, l
    t = {}
    ll = 0
    if (#p == 1) then
        return {p}
    end
    while true do
        l = string.find(p, d, ll, true) -- find the next d in the string
        if l ~= nil then -- if "not not" found then..
            table.insert(t, string.sub(p, ll, l - 1)) -- Save it in our array.
            ll = l + 1 -- save just after where we found it for searching next time.
        else
            table.insert(t, string.sub(p, ll)) -- Save what's left in our array.
            break -- Break at end, as it should be, according to the lua manual.
        end
    end
    return t
end

function ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

function camelize(str)
    local tokens = {}
    for i, v in pairs(explode("-", str)) do
        tokens[i] = ucfirst(v)
    end
    return table.concat(tokens, "")
end

--- merge source table into origin table.
-- shallow merge
-- @tparam table origin
-- @tparma table source
-- @treturn table 
function table_merge(origin, source)
    for k, v in pairs(source) do
        origin[k] = v
    end
    return origin
end



--- Count table when table is not an array.
-- @treturn uint
function table_count(t)
    local c = 0
    for _, v in pairs(t) do
        c = c + 1
    end
    return c
end

local dumped = {}

function table_reference(t)
    if type(t) ~= "table" then
        error("Must be a table.")
    end
    local ret = tostring(t)
    local i = string.find(ret, ":")
    if i == ni then return ret end 
    return string.sub(ret, string.find(ret, ":") + 2)
end

--- Dump variable into string
-- Metatable info will only be dumped in the first depth
-- @param v any type of variable
-- @tparam boolean dump_meta if true, will dump its metatable if it is a metatable.
-- @tparam uint depth SHOULD not pass any value manually
---@treturn string 
function var_dump(v,dump_meta,depth)
    local dump = {}
    local meta
    depth = depth or 0
    if type(v) == "table" then 
        if not dumped[v] then
            dumped[v] = v
            local t = string.rep("", depth).."{"
            for k, d in pairs(v) do 
                local h = ""
                if type(d) == "table" then h = ":"..table_reference(d) end
                if dumped[d] then 
                    t = string.format("%s\n%s%s:%s(%s%s)",t,string.rep("   ", depth + 1),k,"reference",type(d),h)
                else
                    t = string.format("%s\n%s%s:%s(%s%s)",t,string.rep("   ", depth + 1),k,var_dump(d, false, depth + 1),type(d),h)
                    if type(d) == "table" then dumped[d] = d end
                end 
            end 
            t = t.."\n"..string.rep("   ", depth).."}"
            dump[#dump+1] = t
        end
    elseif type(v) == "nil" then
        dump[#dump+1] = "nil"
    elseif type(v) == "function" then
        dump[#dump+1] = "function"
    elseif type(v) == "userdata" then
        dump[#dump+1] = "userdata"
    elseif type(v) == "thread" then
        dump[#dump+1] = "thread" 
    elseif type(v) == "boolean" then
        if v then 
            dump[#dump+1] = "true" 
        else
            dump[#dump+1] = "false" 
        end
    else
        dump[#dump+1] = v
    end
   
    local ret = table.concat(dump, ",")
    local meta_ret 
    if type(v) == "table" and dump_meta then
        meta = getmetatable(v)
        if meta then meta_ret = var_dump(meta) end
    end 
    if depth == 0 then 
        local h = ""
        if type(v) == "table" then h = ":"..table_reference(v) end
        ret = string.format("%s(%s%s)",ret,type(v),h)
        if meta_ret then 
            ret = string.format("%s\n---meta table---\n%s\n", ret, meta_ret)
        end 
        dumped = {}
    end
    
    return ret
end 


