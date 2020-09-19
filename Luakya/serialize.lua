local __types = {string = 's', number = 'i', boolean = 'b'}
sub = string.sub

function __serializeArray(object)
    local serialized = "^"

    for _, v in pairs(object) do
        if type(v) == 'table' then
            v = __serialize(v)
        else
            v = __types[type(v)] .. v
        end

        serialized = serialized .. "'" .. v .. "' AND "
    end

    serialized = sub(serialized, 1, -6)
    serialized = serialized .. "$"

    return serialized
end

function __serializeObject(object)
    local serialized = "<"

    for k, v in pairs(object) do

        if type(v) == 'table' then
            v = __serialize(v)
        else
            v = __types[type(v)] .. v
        end

        if type(k) == 'table' then
            k = __serialize(k)
        else
            k = __types[type(k)] .. k
        end
        
        serialized = serialized .. "'" .. k .. "' IS '" .. v .. "' AND "
    end

    serialized = sub(serialized, 1, -6)
    serialized = serialized .. ">"

    return serialized
end

function __serialize(object)
    if type(object) ~= "table" then return object end

    local serialized

    if __isArray(object) then
        serialized = __serializeArray(object)
    else
        serialized = __serializeObject(object)
    end
    
    return serialized
end

function __isArray(t)
    if type(t)~="table" then return nil end

    local count=0

    for k, _ in pairs(t) do
        if type(k)~="number" then return false else count=count+1 end
    end

    for i=1, count do
        if not t[i] and type(t[i])~="nil" then return false end
    end

    return true
end

exports = __serialize

return exports
