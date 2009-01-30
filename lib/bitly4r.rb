# == About bitly4r.rb
#
# Making it easy to use <tt>require 'bitly4r'</tt>, while still componentizing.
#
%w{
	net/http
	cgi

	bitly4r/objects
	bitly4r/client
	bitly4r/definitions
}.each {|lib| require lib }
