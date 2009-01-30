def Bitly4R(ops={})
	#	general options
	Bitly4R::Client.new(ops)
end

def Bitly4R.Keyed(login, api_key)
	#	using an API key
	Bitly4R::Client.new(:login => login, :api_key => api_key)
end

def Bitly4R.Authed(login, password)
	#	using an API key
	Bitly4R::Client.new(:login => login, :password => password)
end
