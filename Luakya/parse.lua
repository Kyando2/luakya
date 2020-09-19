sub = string.sub

function __parse(str)
	local isType = "Unknown"
	if sub(str, 1, 1) == "<" then
		str = sub(string.match(str, "\<.*\>"), 2, -2)
		isType = "dict"
	elseif sub(str, 1, 1) == "^" then
		str = sub(string.match(str, "\^.*\$"), 2, -2)
		isType = "list"
	end
	local parsed = __inParse(str, isType)

	return parsed
end

function __inParse(str, dataType)
	local values = __super(str)
	local nativeObject = {}

	if dataType == "list" then

		for _, v in pairs(values) do
			
			if v[1] == "list" or v[1] == "dict" then
				v = __parse(v[2])
			elseif v[1] == "lit" then
				v = v[2]
			end

			table.insert(nativeObject, v)
		end


	elseif dataType == "dict" then

		for i=1, #values, 2 do
			local k = values[i]
			local v = values[i+1]

			
			if v[1] == "list" or v[1] == "dict" then
				v = __parse(v[2])
			elseif v[1] == "lit" then
				v = v[2]
			end
			if k[1] == "list" or k[1] == "dict" then
				k = __parse(k[2])
			elseif k[1] == "lit" then
				k = k[2]
			end

			nativeObject[k] = v
		end

	end

	return nativeObject
end

function __parseLiteral(string, from, to)
	local lit = sub(string, from, to)
	local char = sub(lit, 1, 1)
	local val = sub(lit, 2)

	if char == "i" or char == "f" then
		return tonumber(val)
	elseif char == "s" then
		return val
	elseif char == "b" then
		if val == "true" or val == "True" then
			return true
		elseif val == "false" or val == "False" then
			return false
		end
	end

	return nil
end

function __super(toParse)
	local toParse = toParse:gsub("'<", "<"):gsub("$'", "$"):gsub(">'", ">"):gsub("'^", "^")
	local opened_lit = 0
	local opened_dicts = {}
	local opened_lists = {}
	local values = {}

	for i=1, #toParse do
		local char = sub(toParse, i, i)
		if (char == '<') then
			table.insert(opened_dicts, i)
		elseif (char == '^') then
			table.insert(opened_lists, i)
		elseif (char == "'") then
			if opened_lit > 0 and #opened_dicts == 0 and #opened_lists == 0 then
				table.insert(values, {'lit', __parseLiteral(toParse, opened_lit+1, i-1)})
				opened_lit = 0
			elseif opened_lit == 0 then
				opened_lit = i
			end
		elseif (char == '>') then
			local lastFrom = table.remove(opened_dicts)
			if #opened_lists == 0 and #opened_dicts == 0 then
				table.insert(values, {'dict', sub(toParse, lastFrom, i)})
			end
		elseif (char == '$') then
			local lastFrom = table.remove(opened_lists)
			if #opened_lists == 0 and #opened_dicts == 0 then
				table.insert(values, {'list', sub(toParse, lastFrom, i)})
			end
		end
	end
	return values
end
exports = __parse

return exports