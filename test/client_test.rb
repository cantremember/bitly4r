#--

require 'helper'



class ClientTest < Test::Unit::TestCase #:nodoc: all
	def test_construction
		any = 'any'

		assert_raises Bitly4R::Error do
			#	no login
			Bitly4R::Client.new
		end

		assert_raises Bitly4R::Error do
			#	needs API key or password
			Bitly4R::Client.new(:login => any)
		end

		Bitly4R::Client.new(:login => any, :api_key => any)
		Bitly4R::Client.new(:login => any, :password => any)
	end

	def test_shorten
		#	shorten
		client = new_client
		response = client.shorten LONG_URL

		assert_is_response_ok response

		#	we get back what we provided
		assert_equal LONG_URL, response.node_key

		#	no assumption as to the value, just how they inter-relate
		hash = response.user_hash
		assert hash && (! hash.empty?)
		short = response.short_url
		assert short =~ Regexp.compile(hash + '$')
	end

	def test_expand
		#	shorten ...
		client = new_client

		response = client.shorten(LONG_URL)
		assert_is_response_ok response

		hash = response.user_hash
		short = response.to_s

		#	... and re-expand
		#	again, we don't have to know anything
		response = client.expand(short)
		assert_is_response_ok response

		assert_equal LONG_URL, response.to_s

		#	note sure what purpose it serves
		#	but it will contain a hash-wrapped element
		assert ! response.__send__(hash.to_sym).empty?

		#	... and re-expand
		#	again, we don't have to know anything
		response = client.expand(hash, :hash)
		assert_is_response_ok response

		assert_equal LONG_URL, response.to_s

		#	again...
		assert ! response.__send__(hash.to_sym).empty?
	end

	def test_info
		#	shorten ...
		client = new_client

		response = client.shorten(LONG_URL)
		assert_is_response_ok response

		hash = response.user_hash
		short = response.to_s

		#	short url, with no key limit
		response = client.info(short)
		assert_is_response_ok response

		assert_equal LONG_URL, response.long_url

		#	hash, key limit
		response = client.info(hash, :hash, :keys => [:long_url, :html_title])
		assert_is_response_ok response

		#	well, we're getting non-included keys back
		#	then again, the demo doesn't constrain the keys either
		#		http://code.google.com/p/bitly-api/wiki/ApiDocumentation
		###assert response.thumbnail.empty?
		###assert ! response.html_title.empty?
		assert_equal LONG_URL, response.to_s
	end

	def test_stats
		#	shorten ...
		client = new_client

		response = client.shorten(LONG_URL)
		assert_is_response_ok response

		hash = response.user_hash
		short = response.to_s

		{ :hash => hash, :short_url => short }.each do |param_type, param|
			response = client.info(param, param_type)
			assert_is_response_ok response

			#	we could choose anything
			assert_equal LONG_URL, response.to_s
		end
	end

	def test_errors
		#	errors ...
		client = new_client

		response = client.errors
		assert ! response.results.empty?
		assert ! response.error_code.empty?
		assert ! response.status_code.empty?
	end
end
