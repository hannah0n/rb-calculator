require_relative 'scan.rb'

# contains an expression
class Expr

	def initialize(args)
		if args[:function]!=nil  # the expression is a function
			init_function(args[:function], args[:expr])
		elsif args[:left]!=nil   # the expression is a binary operator
			init_binary(args[:left], args[:op], args[:right])
		elsif args[:id_num]!=nil    # the expression is either an id or a number
			init_id_num(args[:id_num])
		end

		# dictionary of binary operators
		@@bin_functions = {
			'PLUS' => :+,
			'MINUS' => :-,
			'MULT' => :*,
			'DIV' => :/,
			'POWER' => :**
		}

		# dictionary of functions
		@@functions = {
			'SQRT' => lambda = -> x {Math::sqrt x},
			'SIN' => lambda = -> x {Math::sin x},
			'COS' => lambda = -> x {Math::cos x},
			'LOG' => lambda = -> x {Math::log x},
			'TAN' => lambda = -> x {Math::tan x},
			'EXP' => lambda = -> x {Math::exp x},
			'-' => lambda = -> x {-x}
		}
	end

	# evaluates the expression given a dictionary of variable definitions
	def evaluate(definitions)
		if @type == :num          # a number, simply return it
			return @num
		elsif @type == :id        # an id, return it's value (if it was defined)
			if definitions.key?(@id)         # check if it is defined
				return definitions[@id]
			else
				print(@id + " not defined\n")   # variable not defined!
				return nil   # error id not defined
			end

		elsif @type == :binary    # binary operator
			left = @left.evaluate(definitions)   # compute value of the left side
			right = @right.evaluate(definitions) # compute value of the right side
			return nil if left == nil || right == nil  # check that no side has an error
			return left.send(@@bin_functions[@op], right)  # apply the operator

		elsif @type == :function             # a function
			param = @expr.evaluate(definitions)  # evaluate the function argument
			return nil if param == nil           # return nil if there was an error
			return @@functions[@function].call(param)  # evaluate the function
		end
	end

	# initializes a function
	def init_function(function, expr)
		@type = :function
		@function = function
		@expr = expr
	end

	# initializes a binary operator
	def init_binary(left, op, right)
		@type = :binary
		@left = left
		@op = op
		@right = right
	end

	# initializes an id or number
	def init_id_num(id_num)
		if id_num.kind == "ID"
			@type = :id
			@id = id_num.value
		else
			@type = :num
			@num = id_num.value.to_f
		end
	end

	# converts the expression to a string (for debugging)
	def to_s
		if @type == :id
			return @id
		elsif @type == :num
			return @num.to_s
		elsif @type == :function
			return  @expr.to_s + " " + @function
		else   # binary
			return @left.to_s + " " + @right.to_s + " " + @op
		end			
	end

end

# contains a statement
class Statement

	def initialize(type)
		@type = type      # possible types: :exp :assignment :clear :list  :quit :empty
		@next = nil       # pointer to next statement
		@id = nil
		@expr = nil
	end

	# getters/setters
	def set_id(id)
		@id = id
	end

	def next
		return @next
	end

	def type
		return @type
	end

	def expr
		return @expr
	end

	def id
		return @id
	end

	def set_next(nxt)
		@next = nxt
	end

	def set_expr(expr)
		@expr = expr
	end

	# converts the statement to a string (for debugging)
	def to_s
		if @type == :list
			return "list"
		elsif @type == :quit
			return "quit"
		elsif @type == :empty
			return "empty"
		elsif @type == :clear
			return "clear " + @id
		elsif @type == :exp
			return @expr.to_s
		end
		return "Not implemented yet"
	end	
end

# general function to display an error message
def error(msg)
	print(msg+"\n")
end

# check if the given string is a function
def is_function(str)
	return str == "SQRT" || str == "SIN" || str == "COS" || str == "LOG" || str == "TAN" || str == "EXP"
end

# parses a factor
def parse_factor(scanner)
	tk = scanner.next_token   # get next token
	if tk.kind == "ID" or tk.kind == "NUM" then  # just a number or id
		return Expr.new({:id_num=>tk})
	elsif tk.kind == "OPENPAR" then  # We have something like (<expr>)
		expr = parse_expression(scanner)     # parse the expression
		if scanner.next_token.kind != "CLOSEPAR" then # check closing parenthesis
			error(") expected")
			return nil
		end
		return expr
	elsif tk.kind == "MINUS" then # we hae -<expr>
		return Expr.new({:function=>'-', :expr=>parse_expression(scanner)})
	elsif is_function(tk.kind) then  # we have a function like sqrt(<expr>)
		if scanner.next_token.kind != "OPENPAR" then # check opening parenthesis
			error(") expected")
			return nil
		end
		expr = parse_expression(scanner)  # parse the expression
		if scanner.next_token.kind != "CLOSEPAR" then  # check closing parenthesis
			error(") expected")
			return nil
		end
		return Expr.new({:function=>tk.kind, :expr=>expr})
	else
		error("ID, number, '(', - or function expected") # anything else is an error
		return nil
	end
end

# the following functions are used to parse an expression. The grammar for expressions was
# re-written to avoid left recursion. We are parsing:
#  exp -> term exp'
#  exp' -> + term exp' | - term exp' | empty
#  term -> pow term'
#  term' -> * pow term' | / pow term' | empty
#  pow -> factor pow'
#  pow' -> ** factor pow' | empty
#  factor remains the same

# parses pow
def parse_pow2(scanner)
	tk = scanner.next_token

	if tk.kind == "POWER"
		factor = parse_factor(scanner)
		pow2 = parse_pow2(scanner)

		if pow2 == nil
			return ['POWER', factor]
		else
			(op, pow2) = pow2
			expr = Expr.new({:left=>factor, :op=>op, :right=>pow2})
			return ['POWER', expr]
		end
	end

	scanner.prev_token
	return nil
end

# parses pow'
def parse_pow(scanner)
	left = parse_factor(scanner)
	right = parse_pow2(scanner)

	return left if right == nil

	(op, right) = right

	return Expr.new({:left=>left, :op=>op, :right=>right})
end

# parses term'
def parse_term2(scanner)
	tk = scanner.next_token
	if tk.kind == "MULT" || tk.kind == "DIV" then
		pow = parse_pow(scanner)
		term2 = parse_term2(scanner)
		if term2 == nil
			return [tk.kind, pow]
		else
			(op, term2) = term2
			expr = Expr.new({:left=>pow, :op=>op, :right=>term2})
			return [tk.kind, expr]
		end
	end

	scanner.prev_token
	return nil
end

# parses term
def parse_term(scanner)
	left = parse_pow(scanner)
	right = parse_term2(scanner)

	return left if right == nil  # no * or /

	(op, right = right)

	return Expr.new({:left=>left, :op=>op, :right=>right})

end

# parses expr'
def parse_expression2(scanner)
	tk = scanner.next_token
	if tk.kind == "PLUS" || tk.kind == "MINUS"
		op = tk.kind
		term = parse_term(scanner)
		expr2 = parse_expression2(scanner)
		if expr2 == nil then
			return [tk.kind, term]
		else
			(op2, expr2) = expr2
			right = Expr.new({:left=>term, :op=>op2, :right=>expr2})
		end
		return [op, right]
	end

	scanner.prev_token
	return nil
end

# parses expr
def parse_expression(scanner)
	left = parse_term(scanner)
	right = parse_expression2(scanner)

	return left if right == nil # no right part

	(op, right) = right

	return Expr.new({:left=>left, :op=>op, :right=>right})
end

# parses a clear statement
def parse_clear(scanner)
	scanner.next_token  # clear
	tk = scanner.next_token  # id

	if tk.kind != "ID"   # ID expected
		error("Expected ID")
		return nil
	end

	stmt = Statement.new(:clear)  # create the new statement
	stmt.set_id(tk.value)

	return stmt
end

# parses an assignment statement
def parse_assignment(scanner)
	id = scanner.next_token.value # id
	scanner.next_token   # =  (we don't need to check it because it is checked outside)
	expr = parse_expression(scanner)  # parse the expression
	stmt = Statement.new(:assignment)  # create the new statement
	stmt.set_id(id)
	stmt.set_expr(expr)
	return stmt
end

# parses an statement
def parse_stmt(scanner)
	tk = scanner.next_token() # check the next token to see the type of statement
	if tk.kind == "CLEAR" then      # clear statement
		scanner.prev_token
		stmt = parse_clear(scanner)
	elsif tk.kind == "LIST" then    # list statement
		stmt = Statement.new(:list)
	elsif tk.kind == "QUIT" or tk.kind == "EXIT" then  # quit statement
		stmt = Statement.new(:quit)
	elsif tk.kind == "SEMICOLON" || tk.kind == "EOF" then  # a semicolon (an empty statement)
		scanner.prev_token
		stmt = Statement.new(:empty)
	elsif tk.kind == "ID" then         # an ID, can be an assignment or an expression
		if scanner.next_token.kind == "EQUAL" then # check the next token to see if it is an assignment
			scanner.prev_token         # we have to take back two tokens! (ID =)
			scanner.prev_token
			stmt = parse_assignment(scanner) # parse the assignment
		else                           # not an assignment, just an expression
			scanner.prev_token         # still, take back two tokens 
			scanner.prev_token
			expr = parse_expression(scanner) # parse the expression
			stmt = Statement.new(:exp)     # create the new statement
			stmt.set_expr(expr)
		end		
	else # expression
		scanner.prev_token
		expr = parse_expression(scanner) # parse the expression
		stmt = Statement.new(:exp)       # create the new statement
		stmt.set_expr(expr)
	end
	return stmt
end

# parses a program (a list of statements separated by semicolons)
def parse_program(scanner)
	stmt = parse_stmt(scanner)  # get next statement
	tk = scanner.next_token()   # next token is either a semicolon or EOF
	if tk.kind == "SEMICOLON" then
		stmt.set_next(parse_program(scanner))  # parse next statement
	elsif tk.kind != "EOF" then   # we either have a semicolon or EOF here
		error("Expected ';'")
		return nil
	end
	return stmt
end

# prints a statement list (for debuggin purposes)
def print_stmt(stmts)
	print stmts.to_s+"\n"
	print_stmt(stmts.next) unless stmts.next == nil
end

# dictionary of definitions
$definitions = { 'PI' => Math::PI}

# evaluates an statement
def evaluate(stmt)
	if stmt.type == :quit  # quit
		$continue = false  # just set continue to false
	elsif stmt.type == :list  # list all definitions
		$definitions.each do |var, value|
			print var+" = "+value.to_s+"\n"
		end
	elsif stmt.type == :clear  # clear a variable from the definitions dictionary
		if $definitions.key?(stmt.id)
			$definitions.delete(stmt.id)
			print stmt.id+" cleared\n"
		else   # trying to clear an non-existent variable
			print "Variable " + stmt.id + " not defined\n"
		end
	elsif stmt.type == :assignment  # assigning a value to a variable
		value = stmt.expr.evaluate($definitions) # evaluate the expression first
		if value != nil   # if expression was valid...
			$definitions[stmt.id] = value     # assign the value
			print stmt.id+" = "+value.to_s+"\n"  # print mesage
        end
	elsif stmt.type == :exp                  # an expression, simply evaluate it
		val = stmt.expr.evaluate($definitions)		
		print val.to_s+"\n" if val != nil
	end

	evaluate(stmt.next) unless stmt.next == nil || !$continue  # evaluate the next statement
end

$continue = true   # flag to iterate until QUIT or EXIT token

while $continue
	line = Readline::readline("Enter expression > ", true).strip  # read input string
	scanner = Scanner.new(line)                                   # create a new scanner

	program = parse_program(scanner)          # parse the program
	evaluate(program) if program != nil       # and evaluate it
end

print "Bye"
