window.Wikitest =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  initialize: ->
  	@AllPages = new @Collections.Pages(@pagesJson)
  	view = new App.Views.Pages(collection: App.AllPages)
  	$('#container').html(view.render().el)

window.App = window.Wikitest
$(document).ready ->
  Wikitest.initialize()
