module Bitly4R
	#	little exception
	#	would have called it Exception, except that i don't know how to access Kernel::Exception
	class Error < Exception
		attr_accessor :cause

		def initialize(message, cause=nil)
			if (Exception === message)
				super message.to_s
				@cause = message
			else
				super message
				@cause = cause
			end
		end
	end

	#	leave no trace
	class Params < Hash
		def to_s
			(self.to_a.collect do |k, v|
				"#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
			end).join('&')
		end
	end

	class Response
		attr_reader :body

		def initialize(response, to_s_sym=nil)
			response = response.body if Net::HTTPResponse === response
			@body = response
			@to_s_sym = to_s_sym
		end

		def method_missing(sym, *args)
			sym = Utility::camelize(sym.to_s)
			match = (self.body || '').match(%r{<#{sym}>(.*)</#{sym}>})

			unless match
				nil
			else
				match[1].gsub(/^<!\[CDATA\[(.*)\]\]>$/, '\1')
			end
		end

		def to_s
			@to_s_sym  ? self.__send__(@to_s_sym)  : super
		end
		alias :to_str :to_s

		def to_sym
			@to_s_sym  ? self.to_s.to_sym  : super
		end
	end

	class Utility
		class << self
			def camelize(string)
				((string.to_s || '').split(/_/).inject([]) do |a, s|
					s = s[0].chr.upcase + s[1..s.size] unless a.empty?
					a << s
					a
				end).join('')
			end
			def decamelize(string)
				(string.to_s || '').gsub(/([^_])([A-Z])/, '\1_\2').downcase
			end
		end
	end
end
