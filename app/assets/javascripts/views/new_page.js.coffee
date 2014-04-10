class App.Views.NewPage extends Backbone.View
	template: JST['pages/new']

	tagName: 'form'

	events:
		'submit': 'saveModel'

	render: ->
		@$el.html(@template(page: @model))
		this

	saveModel:(e) ->
		@model.save
			title: @$('.page-title').val()
			content: @$('.page-content').val()
		Backbone.history.navigate('/', trigger: true)
		false