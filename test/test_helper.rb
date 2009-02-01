#--

#
#	Thank you masked man.  Or, rather, Hpricot.
#
$LOAD_PATH.unshift File.dirname(File.dirname(__FILE__)) + "/../lib"

%w{ rubygems bitly4r test/unit }.each {|lib| require lib }

#	if we're lucky...
begin
	require 'ruby-debug'
rescue Object => e
end



class Test::Unit::TestCase #:nodoc: all

	#	trailing slash makes a difference!  they normalize!
	LONG_URL = 'http://rubyforge.org/'

	#	credentials from
	#		http://code.google.com/p/bitly-api/wiki/ApiDocumentation
	#		no password provided
	LOGIN = 'bitlyapidemo'
	API_KEY = 'R_0da49e0a9118ff35f52f629d2d71bf07'
	PASSWORD = nil



	def new_client
		Bitly4R::Client.new(:login => LOGIN, :api_key => API_KEY)
	end

	def assert_is_response_ok(response)
		assert_equal '0', response.error_code
		assert_equal '', response.error_message
		assert_equal 'OK', response.status_code
	end
end
