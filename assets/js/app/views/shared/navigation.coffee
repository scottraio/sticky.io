App.Views.Shared or= {}

class App.Views.Shared.Navigation extends Backbone.View

	events: click_or_tap {
		"ul.list a"			: "load_snaplink"
		"ul.sidebar-nav a"	: "load_navlink"
	}		

	initialize: => 
		@link = $(".nav a[rel*=#{ this.options.type }]")
		@type	= this.options.type
		@render()
		return this		

	load_navlink: (e) ->
		$(".sidebar-nav li").removeClass("active")
		$(e.currentTarget).parent("li").addClass("active")

		push_url $(e.currentTarget).attr("href")
		return false

	load_snaplink: (e) =>
		$(".list li").removeClass("active")
		$(e.currentTarget).parent("li").addClass("active")

		href = $(e.currentTarget).attr("href")

		if $(e.currentTarget).attr("target") is "_blank"
			window.open "/public" + href
		else
			navigate href
		return false
		
	render: () =>
		self = this
		_counter 	= 0
		size 			= this.options.items.length
		$("#sidebar-list-lander").html ich.navlist
			account_id: current_user('account_id')
			type: 			this.options.type
			items: 			this.options.items
			title: 			this.options.title
			alt_color: 		() -> return if _counter++ % 2 == 0 then 'light' else 'dark'
			last:			() -> return if _counter is size then "last" else ""
			is_external: 	() -> return true if this.account_id isnt current_user('account_id')
			is_empty: 		() -> return true if size is 0

		$('ul.list li').tipsy({delayIn: 1500, gravity: 'w', offset: -10});
			