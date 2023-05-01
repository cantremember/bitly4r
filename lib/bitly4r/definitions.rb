#Simple constructor methods, so that you don't have to deal directly with Client if you don't want to.
#
#See also:
#* Bitly4R.Token
#
#--
#Many thanks to Hpricot for introducing me to this convention.
#++

#Constructs a SimpleClient with the usual Hash of arguments.
def Bitly4R(ops={})
	#	general options
	Bitly4R::SimpleClient.new(ops)
end

#Constructs a SimpleClient with an Access Token credential
def Bitly4R.Token(token)
    #   just token
	Bitly4R::SimpleClient.new(:token => token)
end
