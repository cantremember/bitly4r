#
#	API Version 2.0.1
#
module Bitly4R
	class Client
		BASE_PARAMS = Params.new
		BASE_PARAMS[:version] = '2.0.1'
		BASE_PARAMS[:format] = 'xml'

		attr_reader :login, :password, :api_key

		def initialize(ops={})
			#	for the readers
			#	not necessary, but polite
			ops.each do |k, v|
				instance_variable_set "@#{k}".to_sym, v
			end

			#	now, a client-izec set of parameters
			@client_params = BASE_PARAMS.clone.merge(ops)
		end



		def shorten(long_url)
			return nil unless long_url
			assert_codes(execute(:shorten, :short_url) do |params|
				params[:longUrl] = long_url
			end)
		end

		def expand(short_url)
			return nil unless short_url
			assert_codes(execute(:expand, :long_url) do |params|
				params[:shortUrl] = short_url
			end)
		end

		def info(param_type, param, ops={})
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

		def stats(param_type, param)
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

		def execute(command, to_s_sym=nil)
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

		def assert_error_code(response)
			raise Error.new("errorCode #{response.errorCode} : #{response.errorMesage}") unless '0' == response.errorCode
			response
		end

		def assert_status_code(response)
			raise Error.new("status #{response.statusCode}") unless 'OK' == response.statusCode
			response
		end

		def assert_codes(response)
			assert_error_code(assert_status_code(response))
		end
	end
end
