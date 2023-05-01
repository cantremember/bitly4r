#Supporting objects for Bitly4R.
#
#See:
#* Bitly4R::Error
#* Bitly4R::Params
#* Bitly4R::Response

module Bitly4R

	#= Error
	#
	#A Module-specific Exception class
	#
	#--
	# i would have called it Bitly4R::Exception
	# except that i don't know how to access Kernel::Exception within the initialize logic
	#++
	class Error < Exception
		#The propagated cause of this Exception, if appropriate
		attr_accessor :cause

		#Provide a message and an optional 'causing' Exception.
		#
		#If no message is passed -- eg. only an Exception -- then this Exception inherits its message.
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

	#= Params
	#
	#Extends the Hash class to provide simply composition of a URL-encoded string.
	#
	#Could have extended Hash, but chose instead to 'leave no trace'.
	class Params < Hash
		#	An encoded composite of the parameters, ready for use in a URL
		def to_s
			(self.to_a.collect do |k, v|
				"#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
			end).join('&')
		end
	end



	#= Response
	#
	#A response from the bit.ly API.
	#
	#The to_s method should always return the 'likely' value, assuming that there is a likely one.
	#For example:
	#* <tt>shorten => shortUrl</tt>
	#* <tt>expand => longUrl</tt>
	#
	#All other response values can be retrieved via method_missing.
	#
	#<b>NOTE:</b> This is <i>not</i> a sophisticated XML parser.  It's just Regexp's, with handling for CDATA blocks.
	class Response
		#The body of the bit.ly API response, as XML
		attr_reader :body

		#Constructs a bit.ly API response wrapper.
		#
		#<i>response</i> can be:
		#* a JSON String, which becomes the body
		#* a Net::HTTPResponse, in which case its body is extracted and expected to be in JSON format
		#
		#<i>to_s_sym</i> is optional, and it references the property which will become the `#to_s` value of this Response.
		#It can be either camel-case or underscored.
		#See method_missing.
		def initialize(response, to_s_sym=nil)
			response = response.body if Net::HTTPResponse === response
			@body = response
			@to_s_sym = to_s_sym
		end

		#Provides access to the other properties of the response body via camel-case or underscored names.
		#For example, <tt>longUrl</tt> and <tt>long_url</tt> are equivalent.
		#If no such property exists, you'll get nil.
		def method_missing(sym, *args)
            begin
                json = JSON.parse(@body || '{}')
            rescue JSON::ParserError => e
                return nil
            end

            # their 'v4/*' JSON convention is snake_case
            sym = Utility::decamelize(sym.to_s)
			return json[sym]
		end

		#Provides the 'likely' value from the response.
		def to_s
			@to_s_sym  ? self.__send__(@to_s_sym)  : super
		end
		alias :to_str :to_s

		#Provides the 'likely' value from the response, as a symbol.
		def to_sym
            return super unless @to_s_sym
            value = self.to_s
            return value.nil? ? value : value.to_sym
		end
	end

	class Utility #:nodoc: all
		class << self
			def camelize(string)
				((string || '').to_s.split(/_/).inject([]) do |a, s|
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
