#Client objects for Bitly4R.
#
#See:
#* Bitly4R::Client
#* Bitly4R::SimpleClient

module Bitly4R
	#= Client
	#
	#A client object for accessing the bit.ly API.
	#
	#* Supports both API key and HTTP Auth credentials (although HTTP Auth / password-based doesn't seem to work)
	#* Works with version 2.0.1 of the API
	#* Uses XML for marshalling, for cheap & easy text parsing.
	#
	#See the API documentation:
	#* http://code.google.com/p/bitly-api/wiki/ApiDocumentation
	#* http://bit.ly
	class Client
		#:nodoc:
		BASE_PARAMS = Params.new
		BASE_PARAMS[:version] = '2.0.1'
		BASE_PARAMS[:format] = 'xml'

		#The login credential provided at construction.
		attr_reader :login
		#The password credential provided at construction.
		attr_reader :password
		#The API key credential provided at construction.
		attr_reader :api_key

		#Constructs a new client.
		#
		#Any tuples provided in the optional Hash are injected into instance variables.
		#
		#You must provide a login, and either an API key (<tt>api_key</tt>) or a password.
		def initialize(ops={})
			#	for the readers
			#	not necessary, but polite
			ops.each do |k, v|
				instance_variable_set "@#{k}".to_sym, v
			end

			raise Error.new("you must provide a login") unless self.login
			raise Error.new("you must provide either an API key or a password") unless (self.api_key or self.password)

			#	now, a client-izec set of parameters
			@client_params = BASE_PARAMS.clone.merge(ops)
		end


		#Invokes the API's <b>shorten</b> method.
		#That's pretty much what makes bit.ly a valuable service.
		#
		#A Response is returned.
		#Response.to_s will return the <tt>shortUrl</tt> / <tt>short_url</tt> value.
		#
		#You can take the shortened URL and re- expand it.
		def shorten(long_url)
			return nil unless long_url
			assert_codes(execute(:shorten, :short_url) do |params|
				params[:longUrl] = long_url
			end)
		end

		#Invokes the API's <b>expand</b> method.
		#It reverses a shorten; the original full URL is re-hydrated.
		#
		#For <i>param</i>, you can provide a previously-shortened URL from the bit.ly service.
		#If so, you do not need to provide <i>param_type</i> (though <tt>:short_url</tt> would be the proper symbol).
		#
		#Alternately, you can provide a hash code returned by the bit.ly service.
		#In this case, provide <tt>:hash</tt> as the <i>param_type</i>.
		#
		#A Response is returned.
		#Response.to_s will return the <tt>longUrl</tt> / <tt>long_url</tt> value.
		def expand(param, param_type=:short_url)
			return nil unless param && param_type
			assert_codes(execute(:expand, :long_url) do |params|
				params[Utility::camelize(param_type).to_sym] = param
			end)
		end

		#Invokes the API's <b>info</b> method.
		#Information about the shortened URL is returned by the service.
		#
		#For <i>param</i>, you can provide a previously-shortened URL from the bit.ly service.
		#If so, you do not need to provide <i>param_type</i> (though <tt>:short_url</tt> would be the proper symbol).
		#
		#Alternately, you can provide a hash code returned by the bit.ly service.
		#In this case, provide <tt>:hash</tt> as the <i>param_type</i>.
		#
		#You can optionally provide an arbitrary Hash of HTTP parameters.
		#The one that bit.ly cares about is called <tt>:key</tt>.
		#It should be an array of camel-cased or underscored element names which you would like to receive.
		#In theory, this should limit the response content, but I haven't seen that work yet.
		#The arbitrary Hash capability is left intact for future re-purposing.
		#
		#A Response is returned.
		#Response.to_s will return the <tt>longUrl</tt> / <tt>long_url</tt> value.
		#
		#There is plenty of other data in the response besides the original full URL.
		#Feel free to access the Response.body and use Response.method_missing to pull out specific element values.
		def info(param, param_type=:short_url, ops={})
			return nil unless param_type && param
			assert_codes(execute(:info, :long_url) do |params|
				params[Utility::camelize(param_type).to_sym] = param

				#	optional keys
				if (keys = ops[:keys])
					keys = [keys] unless Array === keys
					params[:keys] = (keys.inject([]) do |a, key|
						a << Utility::camelize(key)
						a
					end).join(',')
				end
			end)
		end

		#Invokes the API's <b>stats</b> method.
		#Statistics about the shortened URL are returned by the service.
		#
		#For <i>param</i>, you can provide a previously-shortened URL from the bit.ly service.
		#If so, you do not need to provide <i>param_type</i> (though <tt>:short_url</tt> would be the proper symbol).
		#
		#Alternately, you can provide a hash code returned by the bit.ly service.
		#In this case, provide <tt>:hash</tt> as the <i>param_type</i>.
		#
		#A Response is returned.
		#Response.to_s will return the <tt>longUrl</tt> / <tt>long_url</tt> value.
		#
		#There is plenty of other data in the response besides the original full URL.
		#Feel free to access the Response.body and use Response.method_missing to pull out specific element values.
		def stats(param, param_type=:short_url)
			return nil unless param_type && param
			assert_codes(execute(:info, :long_url) do |params|
				params[Utility::camelize(param_type).to_sym] = param
			end)
		end

		def errors
			execute(:errors)
		end



		#	- - - - -
		protected

		def execute(command, to_s_sym=nil) #:nodoc:
			#http://api.bit.ly/shorten?version=2.0.1&longUrl=http://cnn.com&login=bitlyapidemo&apiKey=R_0da49e0a9118ff35f52f629d2d71bf07
			uri = URI.parse('http://api.bit.ly')

			#	the client-izec set
			params = @client_params.clone
			params[:login] = self.login
			params[:apiKey] = self.api_key if self.api_key

			#	altered in whatever way the caller desires
			yield params if block_given?

			response = Net::HTTP.start(uri.host, uri.port) do |http|
				path = "/#{command}?#{params}"
				request = Net::HTTP::Get.new(path)
				if self.password
					#	HTTP auth expected
					request.basic_auth self.login, self.password
				end

				http.request request
			end

			raise Error.new('did not receive HTTP 200 OK') unless Net::HTTPOK === response

			#	a parsing response
			Response.new(response, to_s_sym)
		end

		def assert_error_code(response) #:nodoc:
			raise Error.new("errorCode #{response.errorCode} : #{response.errorMesage}") unless '0' == response.errorCode
			response
		end

		def assert_status_code(response) #:nodoc:
			raise Error.new("status #{response.statusCode}") unless 'OK' == response.statusCode
			response
		end

		def assert_codes(response) #:nodoc:
			assert_error_code(assert_status_code(response))
		end
	end



	#Constructs a new 'simple' client.
	#
	#Just like a standard Client, except that several methods are overridden to provide the 'likely' value, vs. a Response.
	class SimpleClient < Client
		#Same as Client.shorten, except that the shortened URL is returned (vs. a Response)
		def shorten(*args)
			(super *args).to_s
		end

		#Same as Client.expand, except that the long URL is returned (vs. a Response)
		def expand(*args)
			#	just the default value, not the Response
			(super *args).to_s
		end
	end
end
