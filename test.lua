luakya = require 'Luakya'

local file = io.open('data.kya', 'r')

local obj = file:read("*a")

local parsed = luakya.parse(obj)

local file = io.open('data.kya', 'w')

file:write(luakya.serialize(parsed))