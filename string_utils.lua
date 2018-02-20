--[[
	DESCRIPTION:
		Module contains implementation of some useful 
		utilities	for working with strings.
	AUTHOR:
		Mikhail Demchenko
		mailto:dev.echo.mike@gmail.com
		https://github.com/echo-Mike
	FILE:
		This file is a part of next repository:
			https://github.com/echo-Mike/LuaSnippets
		Please refer to LICENSE file from repository above for legals
]]
--[[
	Usage guide:
		
		-- Include require expression - the callable will be returned.
		-- Call it to add features to string type.
		require "string_utils" ()
]]

local string_utils_module = {
	__call = function()
		-- Returns table with groups of input string components that are not space chars
		-- but was separated by them in original string.
		string.split = function(self)
			local t = {}
			for i in string.gmatch(self, "%S+") do
				table.insert(t, i)
			end
			return t
		end
		-- Returns table with groups of input string components that are not satisfy
		-- the pattern but was separated by chars that satisfies pattern in original string.
		string.splitBy = function(self, pat)
			local t = {}
			for i in string.gmatch(self, pat) do
				table.insert(t, i)
			end
			return t
		end
		-- Returns string within which every character from original string is substituted
		-- with its numeric representation in C hexadecimal format.
		string.toHex = function(self)
			local s = ""
			for i = 1,#self do
				if	self:byte(i) < 16 then
					s = s..'\\x0'..string.format('%X', self:byte(i))
				else
					s = s..'\\x'..string.format('%X', self:byte(i))
				end
			end
			return s
		end
		-- Returns table with numeric codes of characters in original string.
		-- Character order is respected.
		string.toByteArray = function(self)
			return table.pack(self:byte(1,-1))
		end
		-- Appends all provided arguments to string one-by-one using operator "..".
		-- Argument order is respected.
		string.append = function(self, ...)
			local t = { ... }
			if #t > 0 then
				for _,v in ipairs(t) do
					self = self..v
				end
			end
			return self
		end
	end
}

return setmetatable(string_utils_module, string_utils_module)