require 'helper'



class ObjectsTest < Test::Unit::TestCase
	def test_decamelize
		u = Bitly4R::Utility

		assert_equal '', u.decamelize(nil)
		assert_equal '', u.decamelize('')
		assert_equal 'a', u.decamelize('a')
		assert_equal 'a', u.decamelize('A')
		assert_equal 'aa', u.decamelize('Aa')
		assert_equal 'a_a', u.decamelize('aA')
		assert_equal 'a_a', u.decamelize('AA')
		assert_equal 'a_a', u.decamelize('a_a')
		assert_equal 'a_a', u.decamelize(:A_A)
	end

	def test_camelize
		u = Bitly4R::Utility

		assert_equal '', u.camelize(nil)
		assert_equal '', u.camelize('')
		assert_equal '', u.camelize('_')
		assert_equal 'a', u.camelize('a_')
		assert_equal 'A', u.camelize('_a')
		assert_equal 'aA', u.camelize('aA')
		assert_equal 'aA', u.camelize('a_a')
		assert_equal 'AA', u.camelize(:A_A)
		assert_equal 'aA1.', u.camelize('a_A_1_.')
	end

	def test_error
		#	string only
		e = Bitly4R::Error.new('message')
		assert_equal 'message', e.message
		assert_nil e.cause

		e = Bitly4R::Error.new(Exception.new('exception'))
		assert_equal 'exception', e.message
		assert_not_nil e.cause

		#	exception
		ee = nil
		begin
			1/0
		rescue ZeroDivisionError => raised
			ee = raised
			e = Bitly4R::Error.new('rescued', raised)
		end
		assert_equal 'rescued', e.message
		assert_not_nil e.cause
		assert_equal ee, e.cause
	end

	def test_params
		params = Bitly4R::Params.new
		assert_equal '', params.to_s

		params[1] = :one
		assert_equal '1=one', params.to_s

		params[:b] = Exception.new('an exception')
		assert_equal ['1=one', 'b=an+exception'], params.to_s.split('&').sort

		params['key is'] = '&escaped'
		assert_equal ['1=one', 'b=an+exception', 'key+is=%26escaped'], params.to_s.split('&').sort
	end

	def test_response
		#	nil response *and* to_s symbol
		response = Bitly4R::Response.new(nil)
		assert_nil response.body
		assert_not_nil response.to_s
		assert_nil response.to_sym

		#	crap
		response = Bitly4R::Response.new('string', :bogus)
		assert_equal 'string', response.body
		assert_nil response.to_s

		#	simple
		response = Bitly4R::Response.new('<a>value</a>', :b)
		assert_equal 'value', response.a
		assert_nil response.to_s

		#	camelization
		response = Bitly4R::Response.new('<uD>down</uD><dU>up</dU>', :d_u)
		assert_equal 'down', response.uD
		assert_equal 'down', response.u_d
		assert_equal 'up', response.dU
		assert_equal 'up', response.to_s

		#	CDATA, plus to_sym
		response = Bitly4R::Response.new('<a><b>b</b><cData><![CDATA[data]]></cData><c>c</c></a>', :c_data)
		assert_equal :data, response.to_sym
	end
end
