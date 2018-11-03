require 'readline'

class Token

	# creates a new Token with the given kind and value
	def initialize(kind, value)
		@kind = kind
		@value = value
	end

	# returns the token kind
	# possible values:
	#    EOF  ($)
	#    CLEAR  (clear)
	#    LIST   (list)
	#    QUIT   (quit)
	#    EXIT   (exit)
	#    SQRT   (sqrt)
	#    PLUS   (+)
	#    MINUS  (-)
	#    POWER  (**)
	#    MULT   (*)
	#    DIV    (/)
	#    OPENPAR  '('
	#    CLOSEPAR  ')'
	#    EQUAL    (=)
	#    SEMICOLON(;)
	#    ID       (any id starting with a letter or _ )
	#    NUM      (any integer or float number)
	#    ERROR    (anything else)
	def kind() 
		return @kind
	end

	# returns the token value
	def value()
		return @value
	end

	# converts token to string	
	def to_s()
		s = @kind
		if @value != "" then
			s = s + ": " + @value
		end
		return s
	end
end

# scanner class
class Scanner

	# str is the input string to be scanner
	def initialize(str)
		@str = str.split

		# this table contains all the regular expressions and token kinds
		# for all the possible tokens
		@tokens_table = [[/^clear\b/, "CLEAR", false],
		                 [/^list\b/,  "LIST",  false],
		                 [/^quit\b/,  "QUIT",  false],
		                 [/^exit\b/,  "EXIT",  false],
		                 [/^sqrt\b/,  "SQRT",  false],
		                 [/^sin\b/,  "SIN",  false],
		                 [/^cos\b/,  "COS",  false],
		                 [/^log\b/,  "LOG",  false],
		                 [/^tan\b/,  "TAN",  false],
		                 [/^exp\b/,  "EXP",  false],
		                 [/^\+/,    "PLUS", false],
		                 [/^\-/,    "MINUS", false],
		                 [/^\*\*/,    "POWER", false],
		                 [/^\*/,    "MULT", false],
		                 [/^\//,    "DIV", false],
		                 [/^;/,    "SEMICOLON", false],
		                 [/^\(/,    "OPENPAR", false],
		                 [/^\)/,    "CLOSEPAR", false],
		                 [/^\=/,    "EQUAL", false],
		                 [/^[a-zA-Z_]\w*/,    "ID", true],  # an id starts with a letter or _
		                 [/^\d+(\.\d*)?(e[-\+]?\d+)?/,    "NUM", true]   # integer or float
		                ]

		@pToken = nil
		@pToken2 = nil
		@usePToken = false
		@usePToken2 = false

		@eof_reached = false
	end

	def prev_token()
		@usePToken2 = true if @usePToken
		@usePToken = true
	end

	# computes the next token from the string and returns it
	def next_token()
		if @eof_reached
			return Token.new("EOF", "")
		end

		if @usePToken2
			@usePToken2 = false
			return @pToken2
		end

		if @usePToken
			@usePToken = false
			return @pToken
		end

		@pToken2 = @pToken

		# if string is empty, we reached the EOF
		if @str.length==0
			#@eof_reached = true
			@pToken = Token.new("EOF", "")
			return @pToken 
		end

		token = @str.shift

		@tokens_table.each {
			| case_info |
			re = case_info[0]
			token_kind = case_info[1]
			has_value = case_info[2]

			value = re.match(token)
			if value != nil
				value = value.to_s
				token = token[value.length...token.length]
				if token.length > 0
					@str.unshift(token)
				end
				if not has_value
					value = ""
				end
				@pToken = Token.new(token_kind, value)
				return @pToken
			end
		}

		token = token[1...token.length]  # remove first symbol
		@str.unshift(token) if token.length > 0
		@pToken = Token.new("ERROR", "")
		return @pToken

	end
end

