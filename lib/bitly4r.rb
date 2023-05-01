#Requires all the individual Bitly4R components, in the proper sequence.
#That makes the use of this gem as easy as:
#
#   require 'bitly4r'
#
#See:
#* Bitly4R::Client
#--

#	external
require 'net/http'
require 'cgi'
require 'json'

#	internal, and in the proper sequence
%w{
	bitly4r/objects
	bitly4r/client
	bitly4r/definitions
}.each do |file|
	require File.expand_path(File.join(File.dirname(__FILE__), file))
end
