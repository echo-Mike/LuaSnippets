--[[
	Originally seen as a part of Codea project.
	Project page:
		https://codea.io/
	Rewritten to be Lua module by:
		Mikhail Demchenko
		mailto:dev.echo.mike@gmail.com
		https://github.com/echo-Mike
	Distributed as part of next repository:
		https://github.com/echo-Mike/LuaSnippets
	This file is NOT Distributed under specified repository
	license. 
]]
--[[
	Guide author: Mikhail Demchenko
	
	Usage guide:
	
		-- Include require expression: callable object returned as a result
		class = require "class"
		
	Use case: Create your class
		
		-- Define your class name
		My_Class = class()
		
		-- Definition of class constructor
		function My_Class:init(args...)
			-- Initialization of new object of My_Class
			-- Data members created here
			self.data_member_name = data_member_value
		end
		
		-- Definition of class member funtion
		function My_Class:My_Function(args...)
			-- Do some work here
			-- Data members are accessible in this scope
			self.data_member_name = new_data_member_value
		end
		
		-- Use case: Use your class
		
		-- Create an object of your class
		my_class_object = My_Class(args...)
		
		-- Call class member funtion
		my_class_object:My_Function(args...)
		
	Use case: Inheritance
		
		Base = class()
		
		function Base:init()
			print("Base constructor")
			self.value = 1
			self.base_value = 1
		end
		
		function Base:foo()
			print("Base foo")
		end
		
		function Base:bar()
			print("Base bar")
		end
		
		Derived1 = class(Base)
		
		function Derived1:init()
			print("Derived1 constructor")
			self.value = 2
			self.derived_value = 2
		end
		
		function Derived1:foo()
			print("Derived1 foo")
		end
		
		Derived2 = class(Base)
		
		function Derived2:bar()
			print("Derived2 bar")
		end
		
		d1 = Derived1()
		d2 = Derived2()
		
		-- Base constructor is NOT called implicitly 
		-- unless Derived constructor is not defined
		
		assert(d1.base_value == nil)
		assert(d1.value == 2)
		assert(d1.derived_value == 2)
		
		assert(d2.base_value == 1)
		assert(d2.value == 1)
		
		d1:foo() -- Prints "Derived1 foo"
		d1:bar() -- Prints "Base bar"
		
		d2:foo() -- Prints "Base foo"
		d2:bar() -- Prints "Derived2 bar"
		
	Original authors comments:
	
		-- Class.lua
		-- Compatible with Lua 5.1 (not 5.0).
]]

local class_module = {}
local module_metatable = {
	__call = function(base)
		local c = {}    -- a new class instance
		if type(base) == 'table' then
			-- our new class is a shallow copy of the base class!
			for i,v in pairs(base) do
				c[i] = v
			end
			c._base = base
		end

		-- the class will be the metatable for all its objects,
		-- and they will look up their methods in it.
		c.__index = c

		-- expose a constructor which can be called by <classname>(<args>)
		local mt = {}
		mt.__call = function(class_tbl, ...)
			local obj = {}
			setmetatable(obj,c)
			if class_tbl.init then
				class_tbl.init(obj,...)
			else 
				-- make sure that any stuff from the base class is initialized!
				if base and base.init then
					base.init(obj, ...)
				end
			end
			
			return obj
		end

		c.is_a = function(self, klass)
			local m = getmetatable(self)
			while m do 
				if m == klass then return true end
				m = m._base
			end
			return false
		end

		return setmetatable(c, mt)
	end
}

return setmetatable(class_module, module_metatable)