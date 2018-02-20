--[[
	DESCRIPTION:
		Module contains implementation of indented output facilities:
			IndentedStringOutput - handles the internal table that contains all
				provided values in order of arrival. Converts to string on explicit
				call to toString method or implicitly via tostring() function.
			IndentedOutputWrapper - wraps any output facility that provides raw output
				method (like file:write) with provided indenter. The indenter is 
				invoked only on calls to print method.
	AUTHOR:
		Mikhail Demchenko
		mailto:dev.echo.mike@gmail.com
		https://github.com/echo-Mike
	FILE:
		This file is a part of next repository:
			https://github.com/echo-Mike/LuaSnippets
		Please refer to LICENSE file from repository above for legals
	DEPENDENCIES:
		indent.lua
]]
--[[
	Usage guide:
	
		-- Include require expression: 
		-- table with two functions and two tables returned as a result
		ind_out = require "indented_output"
		
	Use case: Output Lua table
		
		params = {
			-- Initial value for internal table
			initial = {},
			-- The indent facility
			indenter = indent:SimpleIndent{}
		}
		-- Default parameters are same as in "params" table
		table_as_str = ind_out:IndentedStringOutput(params)
		-- or ind_out:IndentedStringOutput{}
		-- or ind_out:IndentedStringOutput{ initial = {}, indenter = indent:SimpleIndent{} }
		
		table_as_str:print("{")
		table_as_str:add()
			table_as_str:print("value = ", 123, ",")
			table_as_str:print("internal_table = {")
			table_as_str:add()
				table_as_str:print("other_value = ", 321, ",")
			table_as_str:sub()
			table_as_str:print("},")
			table_as_str:print("string_value = \"string\"")
		table_as_str:sub()
		table_as_str:print("}")
		
		print(tostring(table_as_str)) --> Prints:
		"{
			value = 123,
			internal_table = {
				other_value = 321,
			},
			string_value = "string"
		}
		"
		
	Use case: Output Lua table to file
	
		params = {
			output = io.open("file.txt", "w+"),
			-- The indent facility
			indenter = indent:SimpleIndent{}
		}
		table_to_file = ind_out:IndentedOutputWrapper(params)
		-- or ind_out:IndentedOutputWrapper{}
		-- or ind_out:IndentedOutputWrapper{ output = io.open("file.txt", "w+"), indenter = indent:SimpleIndent{} }
		
		table_to_file:print("{")
		table_to_file:add()
			table_to_file:print("value = ", 123, ",")
			table_to_file:print("internal_table = {")
			table_to_file:add()
				table_to_file:print("other_value = ", 321, ",")
			table_to_file:sub()
			table_to_file:print("},")
			table_to_file:print("string_value = \"string\"")
		table_to_file:sub()
		table_to_file:print("}")
		
		table_to_file:getOutput():close() --> File content:
		"{
			value = 123,
			internal_table = {
				other_value = 321,
			},
			string_value = "string"
		}
		"
]]

local indent = require "indent"

local indented_output_module = {}

indented_output_module.IndentedStringOutput_metatabel = {
	-- Remembers provided arguments inside internal table.
	-- Order of arguments is respected.
	write = function(self, ...)
		local t = { ... }
		if self.string_repr:len() ~= 0 then
			self.string_repr = ""
		end
		if #t > 0 then
			for _,v in ipairs(t) do
				table.insert(self.table_repr, v)
			end
		end
	end,
	-- Remembers provided arguments inside internal table.
	-- Prepends arguments with value, returned by internal indenter.
	-- Appends arguments with new line charter.
	-- Order of arguments is respected.
	print = function(self, ...)
		local t = { ... }
		if self.string_repr:len() ~= 0 then
			self.string_repr = ""
		end
		table.insert(self.table_repr, self.indenter:get())
		if #t > 0 then
			for _,v in ipairs(t) do
				table.insert(self.table_repr, v)
			end
		end
		table.insert(self.table_repr, "\n")
	end,
	-- Converts remembered values to string.
	-- String representation stays valid until next output operation.
	-- Order of values is respected.
	toString = function(self)
		if self.string_repr:len() ~= 0 then
			return self.string_repr
		end
		for _,v in ipairs(self.table_repr) do
			self.string_repr = self.string_repr..tostring(v)
		end
		return self.string_repr
	end,
	-- Metamethod to call toString on passing objects to tostring() function.
	__tostring = function(object)
		return object:toString()
	end,
	-- Returns internal table representation
	toTable = function(self)
		return self.table_repr
	end,
	-- Clears table, string representation and internal indenter.
	clear = function(self)
		self.table_repr = {}
		self.string_repr = ""
		self.indenter:clear()
	end
}

indented_output_module.IndentedOutputWrapper_metatabel = {
	-- Wraps up write function of handled output facility.
	-- Order of arguments is respected.
	write = function(self, ...)
		self.output:write(...)
	end,
	-- Executes a print operation on handled output facility.
	-- Prepends provided arguments with value, returned by internal indenter.
	-- Appends arguments with new line charter.
	-- Order of arguments is respected.
	print = function(self, ...)
		self.output:write(self.indenter:get(), ...)
		self.output:write("\n")
	end,
	-- Method for direct access to output facility.
	getOutput = function(self)
		return self.output
	end
}

indented_output_module.IndentedStringOutput_metatabel.__index = function(object, key)
	if indented_output_module.IndentedStringOutput_metatabel[key] then
		return indented_output_module.IndentedStringOutput_metatabel[key]
	else
		return rawget(object, "indenter_methods")[key]
	end
end

indented_output_module.IndentedOutputWrapper_metatabel.__index = function(object, key)
	if indented_output_module.IndentedOutputWrapper_metatabel[key] then
		return indented_output_module.IndentedStringOutput_metatabel[key]
	else
		return rawget(object, "indenter_methods")[key]
	end
end

function indented_output_module:IndentedStringOutput(tab)
	if tab and tab.initial then
		assert(type(tab.initial) == "table", "Initial argument for IndentedStringOutput must be a table.")
	end
	local object = {
		string_repr = "",
		table_repr = tab.initial or {},
		indenter = tab.indenter or indent:SimpleIndent{},
		indenter_methods = {}
	}
	for k,v in pairs(getmetatable(object.indenter)) do
		if type(v) == "function" and not self.IndentedStringOutput_metatabel[k] then
			object.indenter_methods[k] = function(self, ...)
				return self.indenter[k](self.indenter, ...)
			end
		end
	end
	
	return setmetatable(object, self.IndentedStringOutput_metatabel)
end

function indented_output_module:IndentedOutputWrapper(tab)
	assert(tab.output, "Output argument for IndentedOutputWrapper must be a provided.")
	assert(type(tab.output.write) == "function", "Output argument for IndentedOutputWrapper must have function member \"write\".")
	local object = {
		output = tab.output,
		indenter = tab.indenter or indent:SimpleIndent{},
		indenter_methods = {}
	}
	for k,v in pairs(getmetatable(object.indenter)) do
		if type(v) == "function" and not self.IndentedOutputWrapper_metatabel[k] then
			object.indenter_methods[k] = function(self, ...)
				return self.indenter[k](self.indenter,...)
			end
		end
	end
	
	return setmetatable(object, self.IndentedOutputWrapper_metatabel)
end

return indented_output_module