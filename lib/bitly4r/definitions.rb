#Simple constructor methods, so that you don't have to deal directly with Client if you don't want to.
#
#See also:
#* Bitly4R.Keyed
#* Bitly4R.Authed
#
#--
#Many thanks to Hpricot for introducing me to this convention.
#++

#Constructs a SimpleClient with the usual Hash of arguments.
def Bitly4R(ops={})
	#	general options
	Bitly4R::SimpleClient.new(ops)
end

#Constructs a SimpleClient with login and API key credentials.
#
#No password is involved.
#Simple HTTP GETs will be the order of the day.
def Bitly4R.Keyed(login, api_key)
	#	using an API key
	Bitly4R::SimpleClient.new(:login => login, :api_key => api_key)
end

#Constructs a SimpleClient with login and password credentials.
#
#No API key is involved.
#HTTP GETs with HTTP Basic Auth will be the order of the day.
def Bitly4R.Authed(login, password)
	#	using an API key
	Bitly4R::SimpleClient.new(:login => login, :password => password)
end
