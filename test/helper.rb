#
#	Thank you masked man.  Or, rather, Hpricot.
#
$LOAD_PATH.unshift File.dirname(File.dirname(__FILE__)) + "/../lib"

['rubygems', 'bitly4r', 'test/unit'].each {|lib| require lib }

#	if we're lucky...
begin
	require 'ruby-debug'
rescue Object => e
end
