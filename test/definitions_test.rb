#--

require 'test_helper'



class DefinitionsTest < Test::Unit::TestCase #:nodoc: all
	def test_keyed
		#	shorten ...
		client = Bitly4R(:login => LOGIN, :api_key => API_KEY)
		short = client.shorten(LONG_URL)
		assert short && (! short.empty?)

		#	... and expand
		assert_equal LONG_URL, Bitly4R.Keyed(LOGIN, API_KEY).expand(short)
	end

	def test_authed
		unless PASSWORD
			puts %Q{
NOTE:
	the text login (#{LOGIN}) did not publish a password
	cannot be tested without that private information
			}.strip
			return
		end

		#	http://code.google.com/p/bitly-api/wiki/ApiDocumentation
		#		sure, the documentation claims there's HTTP Auth support
		#		but i don't see it yet
		short = nil
		assert_raises Bitly4R::Error do
			#	shorten ...
			client = Bitly4R(:login => LOGIN, :password => API_KEY)
			short = client.shorten(LONG_URL)
			assert short && (! short.empty?)
		end

		#	alright, let's use the API key
		client = Bitly4R(:login => LOGIN, :api_key => API_KEY)
		short = client.shorten(LONG_URL)
		assert short && (! short.empty?)

		#	same deal.  *sigh*
		assert_raises Bitly4R::Error do
			#	... and expand
			assert_equal LONG_URL, Bitly4R.Authed(LOGIN, PASSWORD).expand(short)
		end
	end
end
