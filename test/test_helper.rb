#--

#
#	Thank you masked man.  Or, rather, Hpricot.
#
$LOAD_PATH.unshift File.dirname(File.dirname(__FILE__)) + "/../lib"

%w{ rubygems bitly4r test/unit }.each {|lib| require lib }

#	if we're lucky...
begin
	require 'debug'
rescue Exception
end



class Test::Unit::TestCase #:nodoc: all
	#	trailing slash makes a difference!  they normalize!
	LONG_URL = 'http://rubyforge.org/'

	#	an Access Token credential is required
	TOKEN = ENV['TOKEN']
    raise Exception.new('You must provide an Access Token (TOKEN) from the environment') if (TOKEN.nil? || TOKEN.empty?)


    def new_client
        Bitly4R::Client.new(:token => TOKEN)
    end

	def new_simple_client
		Bitly4R.Token(TOKEN)
	end
end
