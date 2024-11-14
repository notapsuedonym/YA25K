local lib = {}

-- this really needs to be cleaned up..

lib.iter = function(t)
    -- simply iterates over a table
    local i = 1
    local n = #t
    return function()
        if i <= n then
            local value = t[i]
            i = i + 1
            return value
        end
    end
end

lib.iters = function(s)
    -- simply iterates over a string
    local i = 1
    local s = s
    local n = #s
    return function()
        if i <= n then
            local value = s:sub(i, i)
            i = i + 1
            return value
        end
    end
end

lib.switch = function(thing, cases)
    --[[

        thing: the object being evaluated
        cases: a table of functions which will be called on a match, including a default

    ]]
    if cases[thing] then
        return cases[thing]()
    else
        return cases["def"]()
    end
end

--[[
lib.split = function(s, delim)
    local rme = {}
    local token = ""
    local constr = ""
    for x in lib.iters(s) do
        constr = constr .. x
        if constr ~= delim then
            token = token .. x
        else
            table.insert(rme, token)
            token = ""
            constr = ""
        end
    end
    if token ~= "" then
        table.insert(rme, token)
    end
    return rme
end
]]
lib.split = function(s, ddel, delim)
    delim = delim or ddel
    local rme = {}
    local token = ""
    local constr = ""
    for x in u.iters(s) do
        if x ~= ddel then
            token = token .. x
        else
            if delim == ddel then
                table.insert(rme, token)
                token = ""
            else
                if token ~= delim then
                    constr = constr .. token .. x
                    token = ""
                else
                    table.insert(rme, constr)
                    token = ""
                    constr = ""
                end
            end
        end
    end
    if delim == ddel then
        if token ~= "" then
            table.insert(rme, token)
        end
    else
        if constr ~= "" then
            table.insert(rme, constr)
        else
            if token ~= "" then
                table.insert(rme, token)
            end
        end
    end
    return rme
end

lib.prune = function(s, c)
    local fin = ""
    for x in lib.iters(s) do
        if x ~= c then
            fin = fin .. x
        end
    end
    return fin
end

lib.prunes = function(s, c)
    local last = s
    for x in lib.iter(c) do
        last = lib.prune(last, x)
    end
    return last
end

lib.replace = function(s, t)
    local fin = ""
    for x in lib.iters(s) do
        if x ~= t[1] then
            fin = fin .. x
        else
            fin = fin .. t[2]
        end
    end
    return fin
end

lib.replaces = function(s, t)
    -- t format;
    --
    --    {{c_to_r, use}, {c_to_r, use}, ...}
    local last = s
    for x in lib.iter(t) do
        last = replace(last, x)
    end
    return last
end

lib.isin = function(t, c)
    for x in lib.iter(t) do
        if x == c then
            return true
        end
    end
    return false
end

lib.isins = function(t, c)
    for x in lib.iters(t) do
        if x == c then
            return true
        end
    end
    return false
end

-- I/O

lib.getfile = function(fname)
    local file = io.open(fname, "r")
    if file ~= nil then
        local cunt = file:read("*a")
        file:close()
        return cunt
    else
        return false
    end
end

lib.get = function(o)
    io.write(o)
    return io.read()
end

lib.dlog = function(n, v)
    io.write("<")
    io.write(n)
    io.write(">")
    io.write(v)
    io.write("</")
    io.write(n)
    io.write(">")
end

return lib
