--[[
	DESCRIPTION:
		Module contains implementation of automatic indenters:
			SimpleIndent - the simple indenter with 
				add, sub, get, set, clear interface.
			Indent - indenter with internal stack.
				Intrface:
					add, sub, get, set, clear,
					push, pop
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
		
		-- Include require expression: 
		-- table with two functions and two tables returned as a result
		indent = require "indent"
	
	Use case: SimpleIndent
	
		params = {
			-- Initial value for indent
			initial = "",
			-- The indent charter
			indenter = "\t"
		}
		-- Default parameters are same as in "params" table
		indenter = indent:SimpleIndent(params)
		-- or indent:SimpleIndent{}
		-- or indent:SimpleIndent{ initial = "", indenter = "\t" }
		
		print(indenter:get()) -- Prints "" (nothing)
		indenter:add()
		print(indenter:get()) -- Prints "	" (the \t char)
		indenter:add()
		print(indenter:get()) -- Prints "		" (the \t\t char)
		...
		print(indenter:get()) -- Prints "		" (the \t\t char)
		indenter:sub()
		print(indenter:get()) -- Prints "	" (the \t char)
		indenter:sub()
		print(indenter:get()) -- Prints "" (nothing)
		
		indenter:set("pre:\t")
		indenter:add()
		print(indenter:get()) -- Prints "pre:		" (pre:\t\t)
		indenter:clear()
		print(indenter:get()) -- Prints "" (nothing)
	
	Use case: Indent
		
		-- Same as for SimpleIndent
		indenter = indent:Indent(params)
		
		-- // -- Everything is same as for SimpleIndent
		
		indenter:set("\t\t\t")
		indenter:add()
		print(indenter:get()) -- Prints "\t\t\t\t"
		indenter:push()
		print(indenter:get()) -- Prints "" (nothing)
		indenter:add()
		print(indenter:get()) -- Prints "\t"
		indenter:pop()
		print(indenter:get()) -- Prints "\t\t\t\t"
		indenter:pop()
		print(indenter:get()) -- Prints "\t\t\t\t"
]]
local indent_module = {}

indent_module.Indent_metatable = {
	-- Add one indenter to current indent value
	add = function(self)
		self.indent = self.indent..self.indenter
	end,
	-- Remove one indenter to current indent value
	sub = function(self)
		self.indent = self.indent:sub(2)
	end,
	-- Get current indent value
	get = function(self)
		return self.indent
	end,
	-- Save current indent value on internal stack and clear current value 
	push = function(self)
		table.insert(self.stack, self.indent)
		self.indent = ""
	end,
	-- If there is something on top of internal stack make it a current indent value
	pop = function(self)
		if #self.stack > 0 then
			self.indent = table.remove(self.stack)
		end
	end,
	-- Set current indent value as provided argument (if it is not nil)
	set = function(self, new_indent)
		if new_indent then
			self.indent = new_indent
		end
	end,
	-- Clear current indent value and internal stack
	clear = function(self)
		self.stack = {}
		self.indent = ""
	end
}

indent_module.SimpleIndent_metatable = {
	-- Add one indenter to current indent value
	add = function(self)
		self.indent = self.indent..self.indenter
	end,
	-- Remove one indenter to current indent value
	sub = function(self)
		self.indent = self.indent:sub(2)
	end,
	-- Get current indent value
	get = function(self)
		return self.indent
	end,
	-- Set current indent value as provided argument (if it is not nil)
	set = function(self, new_indent)
		if new_indent then
			self.indent = new_indent
		end
	end,
	-- Clear current indent value and internal stack
	clear = function(self)
		self.indent = ""
	end
}

indent_module.Indent_metatable.__index = indent_module.Indent_metatable
indent_module.SimpleIndent_metatable.__index = indent_module.SimpleIndent_metatable

function indent_module:Indent(tab)
	local object = {
		-- Current indent value
		indent = tab.initial or "",
		-- Indentation stack
		stack = {},
		-- Indenter char
		indenter = tab.indenter or "\t",
	}
	return setmetatable(object, self.Indent_metatable)
end

function indent_module:SimpleIndent(tab)
	local object = {
		-- Current indent value
		indent = tab.initial or "",
		-- Indenter char
		indenter = tab.indenter or "\t",
	}
	return setmetatable(object, self.SimpleIndent_metatable)
end

return indent_module