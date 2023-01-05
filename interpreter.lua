interpreter = {}
interpreter.keywords={"and", "break" , "do" , "else" , "elseif" , "end" , "false" , "for"  , "if" , "in" , "local" , "nil" , "not" , "or" , "repeat" , "return" , "then" , "true" , "until" , "while"}


function interpreter.parse(code)
	local tokens = {}
	for token in string.gmatch(code,"[^%s]+") do
		if interpreter.keywords[token] then
			table.insert(tokens,{type = "keyword", value=token}) 
		elseif string.match(token,"%w+%(%)") then
			table.insert(tokens,{type = "function", value=token})
		elseif string.match(token,"%,%s*%w+") then
			table.insert(tokens,{type = "arguement", value=token})
		elseif string.match(token,"^%$%w+") then
			table.insert(tokens,{type = "variable", value=token})
		elseif string.match(token,"^%(.+%)$") then
			table.insert(tokens,{type = "condition", value=token})
		elseif tonumber(token) then
			table.insert(tokens,{type = "number", value=tonumber(token)})
		elseif string.match(token,"^\".+\"$") then
			table.insert(tokens,{type = "string", value=string.sub(token,2,-2)})
		elseif type(loadstring(token)) == "function" then
			table.insert(tokens,{type = "CFunction", value=loadstring(token)})
		elseif string.match(token,"^userdata:.+$") then
			table.insert(tokens,{type = "userdata", value=token})
		elseif string.match(token,"^{.+}$") then
			table.insert(tokens,{type = "table", value=token})
		else
			table.insert(token, {type = "word", value=token})
		end
	end
	return tokens;
end


function interpreter.evaluate(parsed_code)
	local stack = {}
	local symbol_table = {}

	for i, token in ipairs(parsed_code) do
		if token.type == "keyword" then
			if token.value == "if" then
				table.insert(stack, { type = "if", condition = false, then_index = 0, else_index = 0 })
			elseif token.value == "then" then
				local context = stack[#stack]
				context.then_index=i
			elseif token.value == "else" then
				local context = stack[#stack]
				context.else_index=if
			elseif token.value == "end" then
				table.remove(stack)
			elseif token.value == "elseif" then
				local context = table.remove(stack)
				table.insert(stack, {type = "elseif", condition = false, then_index = 0, else_index = 0})
			elseif token.value == "or" then
				local left = table.remove(stack)
				local right = table.remove(stack)
				local result = left or right
				table.insert(stack,result)
			elseif token.value == "and" then
				local right = table.remove(stack)
				local left = table.remove(stack)
				local result = left and right
				table.insert(stack,result)
			elseif token.value == "not" then
				local value = table.remove(stack)
				local result = not value
				table.insert(stack,result)
			elseif token.value == "do" then
				table.insert(stack, {type = "do", end_index = 0})
			elseif token.value == "for" then
				table.insert(stack, {type = "for", end_index = 0})
			elseif token.value == "break" then
				while #stack >0 and stack[#stack].type~="for" and stack[#stack].type ~= "while" do
					table.remove(stack)
				end
				if #stack > 0 then
					stack[#stack].break_flag = true
				end
			elseif token.value == "repeat" then
				table.insert(stack, { type = "repeat", condition = false, then_index = 0 })
			end
		elseif token.type == "function" then
			local name = string.match(token.value, "(%w+)%(%)")
			if name == "print" then
				local value = table.remove(stack)
				print(value)
			end
		elseif token.type == "arguement" then
			local argument = string.match(token.value, "%,%s*(%w+)")
			table.insert(stack, argument)
		elseif token.type == "variable" then
      local name = string.sub(token.value, 2)
      if next(stack) ~= nil then
        symbol_table[name] = table.remove(stack)
      else
        table.insert(stack, symbol_table[name])
      end
    elseif token.type == "number" then
      table.insert(stack, token.value)
    elseif token.type == "string" then
      table.insert(stack, token.value)
    elseif token.type == "CFunction" then
      local f = token.value
      local result = f()
      table.insert(stack, result)
    elseif token.type == "userdata" then
      table.insert(stack, token.value)
    elseif token.type == "table" then
      table.insert(stack, token.value)
    end

    if #stack > 0 then
      local context = stack[#stack]
      if context.type == "if" or context.type == "elseif" then
        if context.then_index == 0 then
          context.condition = table.remove(stack)
        else
          local result = context.condition
          if context.else_index > 0 then
            i = context.else_index
          else
            table.remove(stack)
          end
          table.insert(stack, result)
        end
      elseif context.type == "for" then
        if context.index == 0 then
          context.index = table.remove(stack)
        elseif context.limit == 0 then
          context.limit = table.remove(stack)
        elseif context.step == 0 then
          context.step = table.remove(stack)
        else
          context.index = context.index + context.step
          if (context.step > 0 and context.index > context.limit) or
            (context.step < 0 and context.index < context.limit) then
            i = context.then_index
            table.remove(stack)
          end
        end
      elseif context.type == "while" then
        if context.then_index == 0 then
          context.condition = table.remove(stack)
        else
          local result = context.condition
          if not result then
            table.remove(stack)
          end
          table.insert(stack, result)
        end
      elseif context.type == "repeat" then
        if context.then_index == 0 then
          context.then_index = i
        else
          context.condition = table.remove(stack)
          if context.condition then
            i = context.then_index
            table.remove(stack)
          end
        end
      end
    end
  end
end
end
end

function interpreter.run(code)
	local parsed_code = interpreter.parse(code)
	return interpreter.evaluate(parsed_code)
end

return interpreter;
