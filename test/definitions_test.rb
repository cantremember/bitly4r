require 'helper'



class DefinitionsTest < Test::Unit::TestCase
	def test_keyed
		#	shorten ...
		client = new_client
		response = client.shorten(LONG_URL)
		assert_is_response_ok response

		#	... and expand
		assert_equal LONG_URL, Bitly4R.Keyed(LOGIN, API_KEY).expand(response.short_url).to_s
	end

	def test_authed
		#	shorten ...
		client = new_client
		response = client.shorten(LONG_URL)
		assert_is_response_ok response

		#	http://code.google.com/p/bitly-api/wiki/ApiDocumentation
		#		sure, the documentation claims there's HTTP Auth support
		#		but i don't see it yet
		assert_raises Bitly4R::Error do
			#	... and expand
			assert_equal LONG_URL, Bitly4R.Authed(LOGIN, PASSWORD).expand(response.short_url).to_s
		end
	end
end
