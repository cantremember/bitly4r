#--

require 'test_helper'



class ClientTest < Test::Unit::TestCase #:nodoc: all
	def test_construction
		any = 'any'

		assert_raises Bitly4R::Error do
			#	no token
			Bitly4R::Client.new
		end

		Bitly4R::Client.new(:token => any)
	end

	def test_shorten
		#	shorten with a full Client
		client = new_client
		response = client.shorten LONG_URL

        assert (Bitly4R::Response === response)

		#	we get back what we provided
		assert_equal LONG_URL, response.long_url

		#	no assumption as to the value, just how they inter-relate
		id = response.id
		assert id && (! id.empty?)
		link = response.link
		assert_equal "https://#{id}", link
        assert_equal response.to_s, link

        #   shorten with a SimpleClient
        simple_client = new_simple_client
        simple_response = simple_client.shorten LONG_URL
        assert (String === simple_response)
        assert_equal link, simple_response
	end

	def test_expand
		#	shorten with a full Client
		client = new_client
		response = client.shorten(LONG_URL)

		id = response.id
		short = response.to_s

		#	... and re-expand
        #   no assumption as to the value, just how they inter-relate
		response = client.expand(short)

		assert_equal LONG_URL, response.to_s
        assert_equal LONG_URL, response.long_url

        #   expand with a SimpleClient
        simple_client = new_simple_client
        simple_response = simple_client.expand short
        assert (String === simple_response)
        assert_equal LONG_URL, simple_response
	end

	def test_info
        #   shorten with a full Client
		client = new_client
		response = client.shorten(LONG_URL)

		short = response.to_s

		#	now, its info ...
		response = client.info(short)

        assert_equal LONG_URL, response.to_s
        assert_equal LONG_URL, response.long_url

        #   a few other accessable properties
        #   no assumption as to the value, just how they inter-relate
        assert_equal "https://#{response.id}", response.link
        assert_equal false, response.archived

        #   info with a SimpleClient
        #   which for this method is not "simple"; it provides a full Response
        simple_client = new_simple_client
        simple_response = simple_client.info short
        assert (Bitly4R::Response === response)
        assert_equal LONG_URL, simple_response.long_url
        assert_equal false, response.archived
	end
end
