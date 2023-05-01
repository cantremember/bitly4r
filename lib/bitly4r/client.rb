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
    #* This Client uses version 4.0.0 of the API (eg. '/v4/*').
	#* It supports Access Token credentials.
	#
	#See the API documentation:
	#* https://dev.bitly.com/docs/
	class Client
		#The Access Token credential provided at construction.
		attr_reader :token

		#Constructs a new client.
		#
		#Any tuples provided in the optional Hash are injected into instance variables.
		#
		#You must provide an Access Token (<tt>token</tt>).
		def initialize(ops={})
			#	for the readers
			#	not necessary, but polite
			ops.each do |k, v|
				instance_variable_set "@#{k}".to_sym, v
			end

			raise Error.new("you must provide an Access Token") unless self.token
		end


		#Invokes the API's <b>shorten</b> method.
		#That's pretty much what makes bit.ly a valuable service.
        #
        #https://dev.bitly.com/api-reference/#createBitlink
		#
		#A Response is returned.
		#Response.to_s will return the <tt>link</tt> value.
		#
		#You can take the shortened URL and re-expand it.
        #
        #<i>ops</i> allows for additional API parameters
        #<ul>
        #    <li><tt>group_guid</tt></li>
        #    <li><tt>domain</tt></li>
        #</ul>
		def shorten(long_url, ops={})
			return nil unless long_url
            return execute_post('shorten', :link) do |params|
                params[:long_url] = long_url
                params.merge!(ops)
            end
		end

		#Invokes the API's <b>expand</b> method.
		#It reverses a shorten; the original full URL is re-hydrated.
        #
        #https://dev.bitly.com/api-reference/#expandBitlink
		#
		#For <i>url</i>, you can provide a previously-shortened URL from the bit.ly service.
        #
        #The URL must provide both a domain (hostname) and a Bitlink ID (path).
        #A minimum-viable URL would be something along the lines of 'bit.ly/3ADCPDo'.
		#
		#A Response is returned.
		#Response.to_s will return the <tt>long_url</tt> value.
		def expand(url)
			return nil unless url
            uri = URI.parse(url)
            bitlink = "#{uri.host}#{uri.path}"

			return execute_post('expand', :long_url) do |params|
				params[:bitlink_id] = bitlink
			end
		end

		#Invokes the API's <b>info</b> method.
		#Information about the shortened URL is returned by the service.
        #
        #https://dev.bitly.com/api-reference/#getBitlink
		#
        #For <i>url</i>, you can provide a previously-shortened URL from the bit.ly service.
        #
        #The URL must provide both a domain (hostname) and a Bitlink ID (path).
        #A minimum-viable URL would be something along the lines of 'bit.ly/3ADCPDo'.
		#
		#A Response is returned.
		#Response.to_s will return the <tt>long_url</tt> value.
		#
		#There is plenty of other data in the response besides the original full URL.
		#Feel free to access the Response.body and use Response.method_missing to pull out specific element values.
		def info(url)
			return nil unless url
            uri = URI.parse(url)
            bitlink = "#{uri.host}#{uri.path}"

            command = "bitlinks/#{bitlink}"
			return execute_get(command, :long_url)
		end



		#	- - - - -
		protected

        def execute_get(command, to_s_sym=nil) #:nodoc:
            uri = URI.parse('https://api-ssl.bitly.com')

            #   the client-ized set
            params = Params.new

            #   altered in whatever way the caller desires
            yield params if block_given?

            response = Net::HTTP.start(uri.host, uri.port,
                :use_ssl => true,
                :set_debug_output => $stdout,
            ) do |http|
                path = "/v4/#{command}?#{params}"
                request = Net::HTTP::Get.new(path)
                request['Authorization'] = "Bearer #{self.token}"
                request['Accept'] = 'application/json'

                http.request request
            end

            # accept the HTTP 2XX range
            raise Error.new('did not receive HTTP 200 OK') unless (/2\d{2}/ =~ response.code)

            #   a parsing response
            Response.new(response, to_s_sym)
        end

		def execute_post(command, to_s_sym=nil) #:nodoc:
            uri = URI.parse('https://api-ssl.bitly.com')

			#	the client-ized set
			params = Params.new

			#	altered in whatever way the caller desires
			yield params if block_given?

			response = Net::HTTP.start(uri.host, uri.port,
                :use_ssl => true,
                # :set_debug_output => $stdout,
            ) do |http|
				path = "/v4/#{command}"
				request = Net::HTTP::Post.new(path)
                request['Authorization'] = "Bearer #{self.token}"
                request['Content-Type'] = 'application/json'
                request.body = params.to_json

				http.request request
			end

            # accept the HTTP 2XX range
            raise Error.new('did not receive an HTTP 2XX') unless (/2\d{2}/ =~ response.code)

			#	a parsing response
			Response.new(response, to_s_sym)
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
