-- Usage: lua tarindexer.lua < foo.tar > foo.tar.txt
-- Usage: lua tarindexer.lua foo.tar > foo.tar.txt

-- https://en.wikipedia.org/wiki/Tar_%28computing%29#File_format
local header_size = 512
local max_filename_length = 100

-- Wrap Lua's substring to C-style offset + length
local function substring (s, offset, length)
	return s:sub (offset + 1, offset + length)
end

local function parse_octal_size (s)
	local sum = 0
	
	for i = 1, #s do
		sum = sum + tonumber (s:sub (i, i)) * math.pow (8, #s - i)
	end
	
	return sum
end

local function round_size (size)
	return math.ceil (size / 512) * 512
end

local offset = 0

local f = io.stdin

if arg [1] then
	f = io.open (arg [1], "rb")
else
	
end

local function read (n)
	local rc = f:read (n)
	offset = offset + n
	return rc
end

while true do
	local header = read (header_size)
	
	-- TODO: Strip trailing \0s from filename
	local filename = substring (header, 0, 100)
	-- Wikipedia lists the size field as 12 bytes but I think the last one is \0
	local octal_size = substring (header, 124, 12 - 1)
	
	if filename:sub (1, 1) == '\0' then
		-- Break on the first empty filename
		break
	end
	
	local exact_size = parse_octal_size (octal_size)
	local rounded_size = round_size (exact_size)
	
	print (string.format ("%s, %i, %i", filename, offset, exact_size))
	
	read (rounded_size)
end
