window.authkey = (service) ->
	return Keys[App.environment()][service]

window.Keys = 
	production:
		google_api: "AIzaSyADJl6E9jk4iavIGXdrRBIJYc5viKU5VUs"
		facebook: "134672389955868"
		linkedin: "4jrgcmnyfh5t"
		twitter: "42133573-5xU4zW5f38Va5YLxNnkdU8ky975p3mnRVynpmMq8U"
	development:
		google_api: "AIzaSyADJl6E9jk4iavIGXdrRBIJYc5viKU5VUs"
		facebook: "182026818537122"
		linkedin: "4jrgcmnyfh5t"
		twitter: "42133573-5xU4zW5f38Va5YLxNnkdU8ky975p3mnRVynpmMq8U"

class window.Facebook 
	find: (email, fn) ->
		FB.api "/search?q=#{email}&type=user", (response) ->
			if response.data isnt undefined and response.data[0] isnt undefined
				FB.api response.data[0].id, (response) ->
					fn(response)
				
class window.GoogleApi
	
	upc: (upc, fn) ->
		$.ajax				
			url: "https://www.googleapis.com/shopping/search/v1/public/products?country=US&condition=new&maxResults=1&restrictBy=gtin=#{upc}&key=#{ authkey("google_api") }"
			type: "GET"
			crossDomain:true
			dataType: 'jsonp'
			success: (data,response) ->
				if data.totalItems isnt 0
					fn(data)
	docs: () ->
		$.ajax				
			url: "https://docs.google.com/feeds/?key=#{ authkey("google_api") }"
			type: "GET"
			crossDomain:true
			dataType: 'jsonp'
			success: (data,response) ->
					console.log(data)
			
		
class window.Twitter
	
	
	
class window.LinkedIn
	
