class App.Models.Page extends Backbone.Model
	# urlRoot: '/pages'
	# no longer needed because part of a collection
	validate: ->
		unless @hasTitle() or @hasContent()
		  title: "Must provide a title or content"

	hasTitle: -> @hasAttribute('title')
	hasContent: -> @hasAttribute('content')
	hasAttribute: (attr) -> @has(attr) && @get(attr).trim() != ""