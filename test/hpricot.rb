require 'rubygems'
['hpricot', 'builder'].each {|lib| gem lib }
['hpricot', 'builder', 'test/unit'].each {|lib| require lib }
require 'ruby-debug'

debugger
doc = Hpricot.XML '<test />'
puts doc.inspect
