#--

require 'test_helper'



class DefinitionsTest < Test::Unit::TestCase #:nodoc: all
	def test_with_token
		#	shorten ...
		short = Bitly4R(:token => TOKEN).shorten(LONG_URL)
		assert short && (! short.empty?)
        assert (String === short)

		#	... and expand (with another Definition)
        long = Bitly4R.Token(TOKEN).expand(short)
        assert (String === long)
		assert_equal LONG_URL, long
	end

	def test_without_token
		#	alright, let's use the API key
		client = Bitly4R(:token => 'INVALID')

        assert_raises Bitly4R::Error do
    		client.shorten(LONG_URL)
        end

		assert_raises Bitly4R::Error do
            Bitly4R.Token('INVALID').shorten(LONG_URL)
		end
	end
end
